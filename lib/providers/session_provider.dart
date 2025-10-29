import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Session {
  String id;
  final String datum; 
  int engagemang;
  int kvalitet;
  int uppmarksamhet;
  String anteckning;
  String lastReadTime;

  Session({
    this.id = '',
    required this.datum,
    this.engagemang = 0,
    this.kvalitet = 0,
    this.uppmarksamhet = 0,
    this.anteckning = '',
    this.lastReadTime = '00:00',
  });

//Konverterar Session-objekt till ett Map för Firestore
  Map<String, dynamic> toMap() {
    return {
      'datum': datum, // Formatet yyyy-MM-dd är bra för sortering
      'engagemang': engagemang,
      'kvalitet': kvalitet,
      'uppmarksamhet': uppmarksamhet,
      'anteckning': anteckning,
      'lastReadTime': lastReadTime,
      'timestamp': FieldValue.serverTimestamp(), // Tidsstämpel för sortering
      'userId': FirebaseAuth.instance.currentUser?.uid, // Säkerhetsmässigt bra
    };
  }

  // NY: Skapar ett Session-objekt från ett Firestore Map
  static Session fromMap(Map<String, dynamic> data, String id) {
    return Session(
      id: id,
      datum: data['datum'] ?? '',
      engagemang: data['engagemang'] ?? 0,
      kvalitet: data['kvalitet'] ?? 0,
      uppmarksamhet: data['uppmarksamhet'] ?? 0,
      anteckning: data['anteckning'] ?? '',
      lastReadTime: data['lastReadTime'] ?? '00:00',
    );
  }
}

//Session provder
class SessionProvider extends ChangeNotifier {
  final List<Session> _sessioner = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Session> get sessioner => _sessioner;

//Hjälpfunktion för att få sessionsreferensen
  CollectionReference<Map<String, dynamic>>? _getSessionsCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('sessions');
  }

  //Ladda sessioner från Firestore
  Future<void> loadSessionsFromFirestore() async {
    final sessionRef = _getSessionsCollection();
    if (sessionRef == null) return;

    final snapshot = await sessionRef
        .orderBy('datum', descending: true) // Sortera efter datum
        .get();

    _sessioner.clear();
    for (var doc in snapshot.docs) {
      _sessioner.add(Session.fromMap(doc.data(), doc.id));
    }
    notifyListeners();
  }
  
  Session? getSessionForDate(String datum) {
    try {
      return _sessioner.firstWhere((s) => s.datum == datum);
    } catch (_) {
      return null;
    }
  }

  Future<void> addOrUpdateSession(Session session) async{
    final sessionRef = _getSessionsCollection();
    if (sessionRef == null) return;

    final existing = getSessionForDate(session.datum);

    if (existing != null) {
      existing.engagemang = session.engagemang;
      existing.kvalitet = session.kvalitet;
      existing.uppmarksamhet = session.uppmarksamhet;
      existing.anteckning = session.anteckning;
      existing.lastReadTime = session.lastReadTime;

      await sessionRef.doc(existing.id).update(existing.toMap());

    } else {
      final docRef = await sessionRef.add(session.toMap());
      session.id = docRef.id;
      _sessioner.add(session);
    }
    notifyListeners();
  }
  
  Future<void> taBortSession(int index) async {
    if (index < 0 || index >= _sessioner.length) return;

    final session = _sessioner[index];

    // Ta bort från Firestore
    final sessionRef = _getSessionsCollection();
    if (sessionRef != null && session.id.isNotEmpty) {
      // Använder session.id för att hitta rätt dokument i Firestore
      await sessionRef.doc(session.id).delete();
    }

    // Ta bort lokalt från listan
    _sessioner.removeAt(index);
    notifyListeners();
  }
  
  void clearData() {
    _sessioner.clear();
    notifyListeners();
  }
}
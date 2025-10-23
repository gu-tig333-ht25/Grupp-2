import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Mal {
  String? id; // Firestore document ID
  String titel;
  String typ; // "Dagsmål" eller "Veckomål"
  String anteckning;
  DateTime? datum;
  bool klar;

  Mal({
    this.id,
    required this.titel,
    required this.typ,
    this.anteckning = '',
    this.datum,
    this.klar = false,
  });

  int get vecka => datum != null
      ? ((datum!.difference(DateTime(datum!.year, 1, 1)).inDays) ~/ 7) + 1
      : 0;

  Map<String, dynamic> toMap() {
    return {
      'titel': titel,
      'typ': typ,
      'anteckning': anteckning,
      'datum': datum != null ? Timestamp.fromDate(datum!) : null,
      'klar': klar,
    };
  }

  factory Mal.fromMap(Map<String, dynamic> map, String id) {
    return Mal(
      id: id,
      titel: map['titel'] ?? '',
      typ: map['typ'] ?? 'Dagsmål',
      anteckning: map['anteckning'] ?? '',
      datum: map['datum'] != null ? (map['datum'] as Timestamp).toDate() : null,
      klar: map['klar'] ?? false,
    );
  }
}

class MalProvider with ChangeNotifier {
  final List<Mal> _malLista = [];
  List<Mal> get malLista => _malLista;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hämta mål från Firestore
  Future<void> fetchMal() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('goals')
        .get();

    _malLista.clear();
    _malLista.addAll(snapshot.docs.map((doc) => Mal.fromMap(doc.data(), doc.id)));
    notifyListeners();
  }

  // Lägg till mål
  Future<void> laggTillMal(String titel,
      {required String typ, String anteckning = '', DateTime? datum}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final sattDatum = datum ?? DateTime.now();
    final mal = Mal(titel: titel, typ: typ, anteckning: anteckning, datum: sattDatum);

    // Skapa dokument i Firestore
    final docRef = await _db
        .collection('users')
        .doc(user.uid)
        .collection('goals')
        .add(mal.toMap());

    mal.id = docRef.id;
    _malLista.add(mal);
    notifyListeners();
  }

  // Ta bort mål
  Future<void> taBortMal(int index) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final mal = _malLista[index];
    if (mal.id != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .doc(mal.id)
          .delete();
    }

    _malLista.removeAt(index);
    notifyListeners();
  }

  // Toggle klar/ej klar
  Future<void> toggleKlar(int index) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final mal = _malLista[index];
    mal.klar = !mal.klar;

    if (mal.id != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .doc(mal.id)
          .update({'klar': mal.klar});
    }

    notifyListeners();
  }
}

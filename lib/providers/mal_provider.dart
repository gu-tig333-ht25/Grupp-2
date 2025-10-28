import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// =================================================================
// 1. Mal - Datamodellen (från Kod 2 med Firestore-stöd)
// =================================================================
class Mal {
  String id;
  String titel;
  String typ; // "Dagsmål" eller "Veckomål"
  String anteckning;
  DateTime? datum;
  bool klar;

  Mal({
    this.id = '',
    required this.titel,
    required this.typ,
    this.anteckning = '',
    this.datum,
    this.klar = false,
  });

  // Veckonummer
  int get vecka => datum != null
      ? ((datum!.difference(DateTime(datum!.year, 1, 1)).inDays) ~/ 7) + 1
      : 0;

  Map<String, dynamic> toMap() {
    return {
      'titel': titel,
      'typ': typ,
      'anteckning': anteckning,
      'datum': datum?.toIso8601String(),
      'klar': klar,
    };
  }

  static Mal fromMap(Map<String, dynamic> data, String id) {
    return Mal(
      id: id,
      titel: data['titel'] ?? '',
      typ: data['typ'] ?? 'Dagsmål',
      anteckning: data['anteckning'] ?? '',
      datum: data['datum'] != null ? DateTime.parse(data['datum']) : null,
      klar: data['klar'] ?? false,
    );
  }
}

// =================================================================
// 2. MalProvider - Provider/Service Layer (Kombinerad)
// =================================================================
class MalProvider with ChangeNotifier {
  final List<Mal> _malLista = [];

  // Firestore och Auth instanser (från Kod 2)
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Mal> get malLista => _malLista;

  // --- Firestore Laddning/CRUD (Från Kod 2) ---

  Future<void> loadGoalsFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('goals')
        .get();

    _malLista.clear();
    for (var doc in snapshot.docs) {
      _malLista.add(Mal.fromMap(doc.data(), doc.id));
    }
    notifyListeners();
  }

  Future<void> laggTillMal(String titel,
      {required String typ, String anteckning = '', DateTime? datum}) async {
    final nu = DateTime.now();
    final sattDatum = datum ?? nu;

    final nyttMal = Mal(
      titel: titel,
      typ: typ,
      anteckning: anteckning,
      datum: sattDatum,
    );

    // Lägg till lokalt först
    _malLista.add(nyttMal);
    notifyListeners();

    // Lägg till i Firestore
    final user = _auth.currentUser;
    if (user != null) {
      final ref = _db
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .doc();

      nyttMal.id = ref.id; // Uppdatera ID efter att referensen skapats
      await ref.set(nyttMal.toMap());
    }
  }

  Future<void> taBortMal(int index) async {
    if (index < 0 || index >= _malLista.length) return;

    final mal = _malLista[index];

    // Ta bort från Firestore
    final user = _auth.currentUser;
    if (user != null && mal.id.isNotEmpty) {
      final ref = _db
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .doc(mal.id);
      await ref.delete();
    }

    // Ta bort lokalt
    _malLista.removeAt(index);
    notifyListeners();
  }

  Future<void> toggleKlar(int index) async {
    if (index < 0 || index >= _malLista.length) return;

    final mal = _malLista[index];
    mal.klar = !mal.klar;

    // Uppdatera lokalt
    notifyListeners();

    // Uppdatera i Firestore
    final user = _auth.currentUser;
    if (user != null && mal.id.isNotEmpty) {
      final ref = _db
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .doc(mal.id);

      await ref.update({'klar': mal.klar});
    }
  }

  // --- Automatisk Statusuppdatering (Från Kod 1, modifierad för Firestore) ---

  // 🔢 Hjälpfunktion för att beräkna veckonummer
  int _veckaNummer(DateTime date) {
    // Använder den mer robusta beräkningen från Kod 1's Mal.vecka
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysPassed = date.difference(firstDayOfYear).inDays;
    return ((daysPassed + firstDayOfYear.weekday) / 7).ceil();
  }

  // 🧭 Automatisk uppdatering av målstatus baserat på dagens datum
  Future<void> uppdateraMalsStatus() async {
    final idag = DateTime.now();
    final veckaNu = _veckaNummer(idag);
    bool hasChanged = false;
    final user = _auth.currentUser;

    if (user == null) {
      notifyListeners();
      return;
    }

    // Använd en batch för att skicka flera uppdateringar samtidigt till Firestore
    final batch = _db.batch();
    final userGoalsRef = _db.collection('users').doc(user.uid).collection('goals');


    for (var mal in _malLista) {
      bool malUpdated = false;

      // Logik för att uppgradera Veckomål till Dagsmål
      if (mal.typ == 'Veckomål' && mal.vecka == veckaNu) {
        if (mal.datum != null && !idag.isBefore(mal.datum!)) {
          mal.typ = 'Dagsmål';
          malUpdated = true;
          hasChanged = true;
        }
      }

      // Spara ändringar till Firestore
      if (malUpdated && mal.id.isNotEmpty) {
        final ref = userGoalsRef.doc(mal.id);
        batch.update(ref, {'typ': mal.typ});
      }
    }

    if (hasChanged) {
      await batch.commit();
      notifyListeners();
    }
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Mal {
  String titel;
  String typ; // "Dagsmål" eller "Veckomål"
  String anteckning;
  DateTime? datum;
  bool klar;

  Mal({
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

    static Mal fromMap(Map<String, dynamic> data) {
    return Mal(
      titel: data['titel'] ?? '',
      typ: data['typ'] ?? 'Dagsmål',
      anteckning: data['anteckning'] ?? '',
      datum: data['datum'] != null ? DateTime.parse(data['datum']) : null,
      klar: data['klar'] ?? false,
    );
  }
}

class MalProvider with ChangeNotifier {
  final List<Mal> _malLista = [];

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Mal> get malLista => _malLista;

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
      _malLista.add(Mal.fromMap(doc.data()));
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

    _malLista.add(nyttMal);
    notifyListeners();

    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .add(nyttMal.toMap());
    }
  }

  Future<void> taBortMal(int index) async {
    if (index < 0 || index >= _malLista.length) return;

    final user = _auth.currentUser;
    if (user != null) {
      final mal = _malLista[index];
      final ref = _db.collection('users').doc(user.uid).collection('goals');
      final snapshot = await ref
          .where('titel', isEqualTo: mal.titel)
          .where('anteckning', isEqualTo: mal.anteckning)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }

    _malLista.removeAt(index);
    notifyListeners();
  }

Future<void> toggleKlar(int index) async {
    if (index < 0 || index >= _malLista.length) return;

    _malLista[index].klar = !_malLista[index].klar;
    notifyListeners();

    final user = _auth.currentUser;
    if (user != null) {
      final mal = _malLista[index];
      final ref = _db.collection('users').doc(user.uid).collection('goals');
      final snapshot = await ref
          .where('titel', isEqualTo: mal.titel)
          .where('anteckning', isEqualTo: mal.anteckning)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'klar': mal.klar});
      }
    }
  }
}

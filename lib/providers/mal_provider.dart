import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Mål datamodellen - representerar ett enkilt mål
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

  // Beräknar vilket vecknummer målet tillhör
  int get vecka => datum != null
      ? ((datum!.difference(DateTime(datum!.year, 1, 1)).inDays) ~/ 7) + 1
      : 0;

  //Konverterar Mål-objekt till Map för firestore
  Map<String, dynamic> toMap() {
    return {
      'titel': titel,
      'typ': typ,
      'anteckning': anteckning,
      'datum': datum?.toIso8601String(), //sparar data som sträng
      'klar': klar,
    };
  }

  //Skapar ett Mål-objekt från en firestore map
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

//Målprovider - hanterar målens tillstånd
class MalProvider with ChangeNotifier {
  final List<Mal> _malLista = [];

  // Firestore och Auth instanser 
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Mal> get malLista => _malLista; //Getter för att läsa mållistan

  // Laddar alla mål från firestore för den inloggade användaren
  Future<void> loadGoalsFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    //Hämtar alla mål dokument från användarens sub-samling
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

  //Skapar ett nytt mål och lägger till det lokalt och i firestore
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

      nyttMal.id = ref.id; 
      await ref.set(nyttMal.toMap()); //Sparar målet med det nya id:et
    }
  }

  //Tar bort ett mål lokalt och från firestore
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

  // Växlar status på målet (klar/inte klar)
  Future<void> toggleKlar(int index) async {
    if (index < 0 || index >= _malLista.length) return;

    final mal = _malLista[index];
    mal.klar = !mal.klar;

    notifyListeners();

    // Uppdaterar klar fältet i Firestore
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

  //Updaterar titel och anteckning för ett mål
  Future<void> uppdateraMalDetaljer(int index, String nyTitel, String nyAnteckning) async {
    if (index < 0 || index >= _malLista.length) return;

    final mal = _malLista[index];
    
    mal.titel = nyTitel;
    mal.anteckning = nyAnteckning;

    notifyListeners();

    final user = _auth.currentUser;
    if (user != null && mal.id.isNotEmpty) {
      final ref = _db
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .doc(mal.id);

      await ref.update({
        'titel': nyTitel,
        'anteckning': nyAnteckning,
      });
    }
  }

  //Automatisk Statusuppdatering

  // Hjälpfunktion för att beräkna veckonummer för att jämföra med dagsdatum
  int _veckaNummer(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysPassed = date.difference(firstDayOfYear).inDays;
    return ((daysPassed + firstDayOfYear.weekday) / 7).ceil();
  }

  // Automatisk uppdatering - flyttar veckomål till dagsmål när veckan är inne
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

      // Lägger till uppdatering till batchen om målet ändrades
      if (malUpdated && mal.id.isNotEmpty) {
        final ref = userGoalsRef.doc(mal.id);
        batch.update(ref, {'typ': mal.typ});
      }
    }

    if (hasChanged) {
      await batch.commit(); // Skickar alla uppdateringar till Firestore samtidigt
      notifyListeners();
    }
  }

  //Rensar lokala mål-data (används vid utloggning).
  void clearData() {
    _malLista.clear();
    notifyListeners();
  }
}
import 'package:flutter/material.dart';

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
}

class MalProvider with ChangeNotifier {
  final List<Mal> _malLista = [];

  List<Mal> get malLista => _malLista;

  void laggTillMal(String titel, {required String typ, String anteckning = '', DateTime? datum}) {
    final nu = DateTime.now();
    final sattDatum = datum ?? nu;

    _malLista.add(Mal(
      titel: titel,
      typ: typ,
      anteckning: anteckning,
      datum: sattDatum,
    ));
    notifyListeners();
  }

  void taBortMal(int index) {
    _malLista.removeAt(index);
    notifyListeners();
  }

  void toggleKlar(int index) {
    _malLista[index].klar = !_malLista[index].klar;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class MalProvider with ChangeNotifier {
  final List<String> _malLista = [];

  List<String> get malLista => _malLista;

  void laggTillMal(String mal) {
    _malLista.add(mal);
    notifyListeners();
  }

  void redigeraMal(int index, String nyttMal) {
    _malLista[index] = nyttMal;
    notifyListeners();
  }

  void taBortMal(int index) {
    _malLista.removeAt(index);
    notifyListeners();
  }
}
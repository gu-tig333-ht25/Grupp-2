import 'package:flutter/material.dart';

class Session {
  final String datum; 
  int engagemang;
  int kvalitet;
  int uppmarksamhet;
  String anteckning;
  String lastReadTime;

  Session({
    required this.datum,
    this.engagemang = 0,
    this.kvalitet = 0,
    this.uppmarksamhet = 0,
    this.anteckning = '',
    this.lastReadTime = '00:00',
  });
}

class SessionProvider extends ChangeNotifier {
  final List<Session> _sessioner = [];

  List<Session> get sessioner => _sessioner;

  Session? getSessionForDate(String datum) {
    try {
      return _sessioner.firstWhere((s) => s.datum == datum);
    } catch (_) {
      return null;
    }
  }

  void addOrUpdateSession(Session session) {
    final existing = getSessionForDate(session.datum);
    if (existing != null) {
      existing.engagemang = session.engagemang;
      existing.kvalitet = session.kvalitet;
      existing.uppmarksamhet = session.uppmarksamhet;
      existing.anteckning = session.anteckning;
      existing.lastReadTime = session.lastReadTime;
    } else {
      _sessioner.add(session);
    }
    notifyListeners();
  }
}

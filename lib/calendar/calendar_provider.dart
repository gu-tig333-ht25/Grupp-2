import 'package:flutter/material.dart';

class CalendarProvider extends ChangeNotifier {
  final Map<DateTime, List<String>> _events = {};

  Map <DateTime, List<String>> get events => _events;

  DateTime _normalize(DateTime date) =>
    DateTime(date.year, date.month, date.day);

  List<String> getEventsForDay(DateTime day){
    final normalized = _normalize(day);
    return _events[normalized] ?? [];
  }

  void addEvent(DateTime day, String event) {
    final normalized = _normalize(day);
    if (_events[normalized] == null) {
      _events[normalized] = [];
    } 
    _events[normalized]!.add(event);
    notifyListeners();
  }

  void removeEvent(DateTime day, String event) {
    final normalized = _normalize(day);
    _events[normalized]?.remove(event);
    if (_events[normalized]?.isEmpty ?? false) {
      _events.remove(normalized);
    }
    notifyListeners();

  }
}

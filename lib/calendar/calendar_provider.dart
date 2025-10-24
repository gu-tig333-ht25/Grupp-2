import 'package:flutter/material.dart';

class CalendarEvent {
  final TimeOfDay time;
  final String title;

  CalendarEvent({required this.time, required this.title});
}

class CalendarProvider extends ChangeNotifier {
  final Map<DateTime, List<CalendarEvent>> _events = {};

  Map<DateTime, List<CalendarEvent>> get events => _events;

  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<CalendarEvent> getEventsForDay(DateTime day) {
    final normalized = _normalize(day);
    final list = _events[normalized] ?? [];
    // Sort by time so they appear chronologically
    list.sort((a, b) =>
        a.time.hour * 60 + a.time.minute - (b.time.hour * 60 + b.time.minute));
    return list;
  }

  void addEvent(DateTime day, CalendarEvent event) {
    final normalized = _normalize(day);
    _events.putIfAbsent(normalized, () => []);
    _events[normalized]!.add(event);
    notifyListeners();
  }

  void removeEvent(DateTime day, CalendarEvent event) {
    final normalized = _normalize(day);
    _events[normalized]?.remove(event);
    if (_events[normalized]?.isEmpty ?? false) {
      _events.remove(normalized);
    }
    notifyListeners();
  }
}
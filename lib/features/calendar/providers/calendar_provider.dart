import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import '../services/calendar_service.dart';
import '../services/auth_provider.dart';

class CalendarProvider with ChangeNotifier {
  final CalendarService _calendarService = CalendarService();
  List<calendar.Event> _events = [];

  List<calendar.Event> get events => _events;

  Future<void> loadEvents(AuthProvider auth) async {
    if (!auth.isLoggedIn) return;
    _events = await _calendarService.fetchEvents(auth.user!);
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import '../providers/auth_provider.dart';
import '../services/google_auth_service.dart';

class CalendarProvider extends ChangeNotifier {
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  /// Google events loaded from API
  List<gcal.Event> googleEvents = [];

  /// Local events stored offline
  final Map<DateTime, List<gcal.Event>> _localEvents = {};

  /// ✅ Needed for TableCalendar
  List<gcal.Event> getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _localEvents[normalized] ?? [];
  }

  /// Add offline events
  void addLocalEvent(DateTime date, String title) {
    final normalized = DateTime(date.year, date.month, date.day);
    _localEvents.putIfAbsent(normalized, () => []);
    _localEvents[normalized]!.add(gcal.Event(summary: title));
    notifyListeners();
  }

  /// Load Google events
  Future<void> loadGoogleEvents(AuthProvider auth) async {
    if (!auth.isLoggedIn) return;
    final api = await _googleAuthService.getCalendarApi();
    if (api == null) return;

    try {
      final now = DateTime.now().toUtc();
      final result = await api.events.list(
        "primary",
        timeMin: now.subtract(const Duration(days: 30)),
        timeMax: now.add(const Duration(days: 60)),
        singleEvents: true,
        orderBy: "startTime",
      );
      googleEvents = result.items ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error loading Google events: $e");
    }
  }
}
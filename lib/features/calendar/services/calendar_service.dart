import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarService {
  // Fetch events using a plain HTTP client with Bearer token (web-friendly)
  Future<List<calendar.Event>> fetchEvents(String accessToken) async {
    final url = Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events?singleEvents=true&orderBy=startTime');
    final resp = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    });

    if (resp.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(resp.body);
      final items = (data['items'] as List<dynamic>?) ?? [];
      return items.map((e) => calendar.Event.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch events: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<void> addEvent(String accessToken, String title, DateTime start, DateTime end) async {
    final url = Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events');
    final body = {
      'summary': title,
      'start': {'dateTime': start.toUtc().toIso8601String(), 'timeZone': DateTime.now().timeZoneName},
      'end': {'dateTime': end.toUtc().toIso8601String(), 'timeZone': DateTime.now().timeZoneName},
    };
    final resp = await http.post(url, headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    }, body: json.encode(body));
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Failed to add event: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<void> deleteEvent(String accessToken, String eventId) async {
    final url = Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events/$eventId');
    final resp = await http.delete(url, headers: {
      'Authorization': 'Bearer $accessToken',
    });
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Failed to delete event: ${resp.statusCode} ${resp.body}');
    }
  }
}
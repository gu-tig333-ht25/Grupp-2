import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class CalendarService {
  Future<List<calendar.Event>> fetchEvents(GoogleSignInAccount account) async {
    final authHeaders = await account.authHeaders;
    final httpClient = GoogleAuthClient(authHeaders);
    final calendarApi = calendar.CalendarApi(httpClient);

    final events = await calendarApi.events.list('primary');
    return events.items ?? [];
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
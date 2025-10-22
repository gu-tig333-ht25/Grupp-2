import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

/// A unified Google Auth + Calendar service compatible with google_sign_in 5.x
class GoogleAuthService {
  GoogleSignInAccount? _currentUser;

  // ✅ Initialize Google Sign-In (v5.x uses normal constructor)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar.readonly',
      'https://www.googleapis.com/auth/calendar.events.readonly',
    ],
  );

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  /// Handles Google Sign-In
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signInSilently(); // attempt silent login
      _currentUser ??= await _googleSignIn.signIn(); // fallback to manual login
      debugPrint('✅ Signed in as: ${_currentUser?.email}');
      return _currentUser;
    } catch (e) {
      debugPrint('❌ Sign-in failed: $e');
      return null;
    }
  }

  /// Signs the user out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      debugPrint('🔒 Signed out');
    } catch (e) {
      debugPrint('❌ Sign-out error: $e');
    }
  }

  /// Build Google Calendar API client using the access token
  Future<calendar.CalendarApi?> getCalendarApi() async {
    if (_currentUser == null) {
      debugPrint('⚠️ No user signed in');
      return null;
    }

    try {
      final auth = await _currentUser!.authentication;
      final accessToken = auth.accessToken;
      if (accessToken == null) {
        debugPrint('⚠️ Missing access token');
        return null;
      }

      final client = _GoogleAuthClient(accessToken);
      return calendar.CalendarApi(client);
    } catch (e) {
      debugPrint('❌ Error creating Calendar API: $e');
      return null;
    }
  }
}

/// Custom HTTP client that automatically adds the OAuth token
class _GoogleAuthClient extends http.BaseClient {
  final String token;
  final http.Client _inner = http.Client();

  _GoogleAuthClient(this.token);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $token';
    return _inner.send(request);
  }
}
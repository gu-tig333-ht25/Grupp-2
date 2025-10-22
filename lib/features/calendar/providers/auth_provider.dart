import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/calendar.events.readonly'],
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      notifyListeners();
    } catch (e) {
      debugPrint('Google sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }

  Future<String?> getAccessToken() async {
    if (_currentUser == null) return null;
    final auth = await _currentUser!.authentication;
    // accessToken finns i 5.x på både web och mobil (om scope tillåter)
    return auth.accessToken ?? auth.idToken;
  }
}
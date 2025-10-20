import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/google_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final GoogleAuthService _authService = GoogleAuthService();
  GoogleSignInAccount? _user;

  GoogleSignInAccount? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> signIn() async {
    _user = await _authService.signIn();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
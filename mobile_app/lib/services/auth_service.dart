import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Menyimpan data akun aktif (email, nama, foto profil)
  final ValueNotifier<GoogleSignInAccount?> currentUser =
      ValueNotifier<GoogleSignInAccount?>(null);

  Future<void> init() async {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      currentUser.value = account;
    });
    // Otomatis login jika sebelumnya sudah pernah login
    try {
      await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint("Silent sign-in error: $e");
    }
  }

  // Fungsi Login Google
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      currentUser.value = account;
      return account;
    } catch (e) {
      debugPrint('Error Login Google: $e');
      return null;
    }
  }

  // Fungsi Logout Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      currentUser.value = null;
    } catch (e) {
      debugPrint('Error Logout: $e');
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Login fallito: ${e.message}');
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Registrazione (puoi usarla solo dalla console per admin)
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Registrazione fallita: ${e.message}');
    }
  }

  // Stream per sessione
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

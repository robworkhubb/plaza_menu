import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// AuthService singleton
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Stream dello stato utente
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

// isAdminProvider usando claims
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return false;
  try {
    final idTokenResult = await user.getIdTokenResult(true); // refresh token
    return idTokenResult.claims?['admin'] == true;
  } catch (_) {
    return false;
  }
});

// Auth controller per login/logout
final authControllerProvider = Provider<AuthController>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthController(authService);
});

class AuthController {
  final AuthService authService;
  AuthController(this.authService);

  Future<User?> signIn(String email, String password) async {
    return await authService.signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    await authService.signOut();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plaza_menu/core/providers/auth_provider.dart';
import 'features/costumer/screens/menu_page.dart';
import 'features/admin/screens/admin_menu_screen.dart';
import 'features/admin/screens/admin_login_page.dart';

// Helper to refresh GoRouter when an auth stream emits
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // ignore: deprecated_member_use
  final refresh = GoRouterRefreshStream(ref.watch(authStateProvider.stream));

  return GoRouter(
    initialLocation: '/menu',
    refreshListenable: refresh,
    routes: [
      GoRoute(
        path: '/menu',
        name: 'menu',
        builder: (_, __) => const MenuPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const AdminLoginPage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (_, __) => const AdminMenuScreen(),
      ),
    ],
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final user = auth.asData?.value;
      final isAdminAsync = ref.read(isAdminProvider);

      final goingAdmin = state.matchedLocation == '/admin';
      final goingLogin = state.matchedLocation == '/login';

      if (user == null) {
        if (goingAdmin) return '/login';
        return null;
      }

      if (isAdminAsync.isLoading) return null; // evita redirect prematuri

      final isAdmin = isAdminAsync.asData?.value ?? false;
      if (!isAdmin && goingAdmin) return '/menu';
      if (isAdmin && goingLogin) return '/admin';
      return null;
    },
  );
});

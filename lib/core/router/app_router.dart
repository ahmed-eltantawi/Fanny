import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/offers/presentation/pages/offers_page.dart';
import '../../features/requests/domain/entities/request_entity.dart';
import '../../features/requests/presentation/pages/create_request_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../shared/pages/main_scaffold.dart';

class AppRouter {
  AppRouter._();

  static GoRouter router(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: _AuthChangeNotifier(authCubit.stream),
      redirect: (context, state) {
        final isLoggedIn = authCubit.state is AuthAuthenticated;
        final loc = state.matchedLocation;

        // Splash manages its own navigation — never redirect it
        if (loc == '/splash') return null;

        final isAuthRoute = loc == '/login' || loc == '/register';
        if (!isLoggedIn && !isAuthRoute) return '/login';
        if (isLoggedIn && isAuthRoute) return '/main';
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/main',
          builder: (context, state) => const MainScaffold(),
        ),
        GoRoute(
          path: '/create-request',
          builder: (context, state) => const CreateRequestPage(),
        ),
        GoRoute(
          path: '/offers',
          builder: (context, state) {
            final request = state.extra as RequestEntity;
            return OffersPage(request: request);
          },
        ),
      ],
    );
  }
}

/// Bridges a BLoC stream to GoRouter's [Listenable] for redirect triggering.
class _AuthChangeNotifier extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;

  _AuthChangeNotifier(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

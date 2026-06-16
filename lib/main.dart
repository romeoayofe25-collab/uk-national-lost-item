import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/theme.dart';
import 'core/services/auth_provider.dart';
import 'core/services/items_service.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/suspended_screen.dart';
import 'features/owner/dashboard_screen.dart';
import 'features/owner/report_wizard_screen.dart';
import 'features/owner/details_screen.dart';
import 'features/owner/verification_screen.dart';
import 'features/owner/collection_screen.dart';
import 'features/owner/chat_screen.dart';
import 'features/finder/dashboard_screen.dart';
import 'features/intermediary/dashboard_screen.dart';
import 'features/admin/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: _authProvider,
      redirect: (context, state) {
        final isAuthenticated = _authProvider.isAuthenticated;
        final isSuspended = _authProvider.isSuspended;
        final user = _authProvider.currentUser;

        final isLoggingIn = state.matchedLocation == '/';
        final isRegistering = state.matchedLocation == '/register';

        if (!isAuthenticated && !isSuspended) {
          if (isLoggingIn || isRegistering) return null;
          return '/';
        }

        if (isSuspended) {
          if (state.matchedLocation == '/suspended') return null;
          return '/suspended';
        }

        if (isAuthenticated) {
          if (isLoggingIn || isRegistering || state.matchedLocation == '/suspended') {
            return _rolePath(user?.role);
          }
          final path = state.matchedLocation;
          if (path.startsWith('/owner') && user?.role != 'owner') return _rolePath(user?.role);
          if (path.startsWith('/finder') && user?.role != 'finder') return _rolePath(user?.role);
          if (path.startsWith('/intermediary') && user?.role != 'intermediary') return _rolePath(user?.role);
          if (path.startsWith('/admin') && user?.role != 'admin') return _rolePath(user?.role);
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/suspended',
          builder: (context, state) => const SuspendedScreen(),
        ),
        GoRoute(
          path: '/owner',
          builder: (context, state) => const OwnerDashboardScreen(),
          routes: [
            GoRoute(
              path: 'report',
              builder: (context, state) => const ReportWizardScreen(),
            ),
            GoRoute(
              path: 'details/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return LostItemDetailsScreen(itemId: id);
              },
            ),
            GoRoute(
              path: 'verify/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return OwnerVerificationScreen(itemId: id);
              },
            ),
            GoRoute(
              path: 'collection/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return CollectionDetailsScreen(itemId: id);
              },
            ),
            GoRoute(
              path: 'chat/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return OwnerAdminChatScreen(itemId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/finder',
          builder: (context, state) => const FinderDashboardScreen(),
        ),
        GoRoute(
          path: '/intermediary',
          builder: (context, state) => const IntermediaryDashboardScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],
    );
  }

  String _rolePath(String? role) {
    switch (role) {
      case 'owner':
        return '/owner';
      case 'finder':
        return '/finder';
      case 'intermediary':
        return '/intermediary';
      case 'admin':
        return '/admin';
      default:
        return '/';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<ItemsService>(create: (_) => ItemsService()),
      ],
      child: MaterialApp.router(
        title: 'UK National Lost-Item',
        theme: AppTheme.darkTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

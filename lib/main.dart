import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_routes.dart';
import 'theme/app_theme.dart';

import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/event_provider.dart';
import 'providers/guest_provider.dart';
import 'providers/invitation_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/public_rsvp_provider.dart';

import 'screens/auth/auth_gate.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/rsvp/public_rsvp_screen.dart';
import 'screens/invitations/public_invitation_preview_screen.dart';

import 'services/socket_service.dart';

void main() {
  runApp(const EventHubApp());
}

class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const AuthGate()),

      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: AppRoutes.verifyCode,
        builder: (context, state) => const VerificationScreen(),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      GoRoute(
        path: '/invitation-preview/:previewToken',
        builder: (context, state) {
          final previewToken = state.pathParameters['previewToken']!;
          final guestToken = state.uri.queryParameters['guest'];

          return PublicInvitationPreviewScreen(
            previewToken: previewToken,
            guestToken: guestToken,
          );
        },
      ),

      GoRoute(
        path: '/rsvp/:token',
        builder: (context, state) {
          final token = state.pathParameters['token']!;

          return PublicRsvpScreen(token: token);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkLoginStatus(),
        ),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => GuestProvider()),
        ChangeNotifierProvider(create: (_) => InvitationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => PublicRsvpProvider()),
        Provider<SocketService>(
          create: (_) => SocketService(),
          dispose: (_, socketService) => socketService.disconnect(),
        ),
      ],
      child: MaterialApp.router(
        title: 'EventHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/events/event_details_screen.dart';
import 'providers/profile_provider.dart';
import 'providers/event_provider.dart';
import 'providers/guest_provider.dart';
import 'providers/invitation_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/public_rsvp_provider.dart';
import 'screens/rsvp/public_rsvp_screen.dart';
import 'screens/invitations/public_invitation_screen.dart';

void main() {
  runApp(const EventHubApp());
}

class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key});

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
      ],
      child: MaterialApp(
        title: 'EventHub',
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.signup: (context) => const SignupScreen(),
          AppRoutes.verifyCode: (context) => const VerificationScreen(),
          AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
          AppRoutes.resetPassword: (context) => const ResetPasswordScreen(),
        },
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '');
          if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'invite') {
            final previewToken = uri.pathSegments[1];
            final guestToken = uri.queryParameters['guest'];

            return MaterialPageRoute(
              builder: (_) => PublicInvitationScreen(
                previewToken: previewToken,
                guestToken: guestToken,
              ),
            );
          }

          if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'rsvp') {
            final token = uri.pathSegments[1];

            return MaterialPageRoute(
              builder: (_) => PublicRsvpScreen(token: token),
            );
          }

          return null;
        },
      ),
    );
  }
}

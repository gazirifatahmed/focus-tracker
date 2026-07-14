import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/registration_state_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final registrationState = Provider.of<RegistrationStateProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    // Loading during registration
    if (registrationState.inProgress) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Loading app data
    if (appProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // User logged in? show HomeScreen else LoginScreen
    if (appProvider.currentUser != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
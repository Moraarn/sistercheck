import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/app_provider.dart';

class AuthWrapper extends ConsumerWidget {
  final Widget child;
  final bool requireAuth;

  const AuthWrapper({
    super.key,
    required this.child,
    this.requireAuth = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final appState = ref.watch(appNotifierProvider);
    final isPatientAuthenticated = appState.isPatientAuthenticated;

    // Debug print
    print('AuthWrapper: isAuthenticated=$isAuthenticated, isPatientAuthenticated=$isPatientAuthenticated, requireAuth=$requireAuth');
    print('AuthWrapper: Current route: ${ModalRoute.of(context)?.settings.name}');

    // Show loading indicator while checking authentication
    if (appState.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check if user is authenticated (either as doctor/nurse or patient)
    final userIsAuthenticated = isAuthenticated || isPatientAuthenticated;
    print('AuthWrapper: userIsAuthenticated=$userIsAuthenticated');

    // Get current route name
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isLoginRoute = currentRoute == '/login' || currentRoute == '/patient_login';
    final isSignupRoute = currentRoute == '/signup' || currentRoute == '/signup_user' || currentRoute == '/patient_signup';

    print('AuthWrapper: isLoginRoute=$isLoginRoute, isSignupRoute=$isSignupRoute');

    // If authentication is required and user is not authenticated
    if (requireAuth && !userIsAuthenticated) {
      // Redirect to appropriate login based on context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          // Check if this is a patient-related route
          final route = ModalRoute.of(context)?.settings.name;
          if (route?.contains('patient') == true) {
            Navigator.of(context).pushReplacementNamed('/patient_login');
          } else {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      });
      
      // Show a temporary screen while redirecting
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Redirecting to login...'),
            ],
          ),
        ),
      );
    }

    // If user is authenticated but trying to access login/signup pages
    // Only redirect if we're actually on a login/signup route
    if (userIsAuthenticated && !requireAuth && (isLoginRoute || isSignupRoute)) {
      print('AuthWrapper: User is authenticated but trying to access login/signup page, redirecting...');
      
      // Redirect to appropriate dashboard based on user type
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          if (isPatientAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/patient_dashboard');
          } else {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      });
      
      // Show a temporary screen while redirecting
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Redirecting to dashboard...'),
            ],
          ),
        ),
      );
    }

    // User is authenticated and accessing protected route, or not authenticated and accessing public route
    print('AuthWrapper: Rendering child widget');
    return child;
  }
} 
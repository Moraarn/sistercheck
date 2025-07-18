import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart' as splash;
import 'screens/onboarding_screen.dart' as onboarding;
import 'screens/home_dashboard_screen.dart';
import 'screens/risk_quiz_screen.dart';
import 'screens/risk_result_screen.dart';
import 'screens/cycle_calendar_screen.dart';
import 'screens/cystal_chat_screen.dart';
import 'screens/chat_sessions_screen.dart';
import 'screens/meet_my_sister_screen.dart';
import 'screens/sister_chat_screen.dart';
import 'screens/lessons_library_screen.dart';
import 'screens/red_flag_alerts_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/signup_user_screen.dart';
import 'screens/clinic_map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/symptoms_screen.dart';
import 'screens/symptoms_history_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/patient_login_screen.dart';
import 'screens/patient_signup_screen.dart';
import 'screens/patient_dashboard_screen.dart';
import 'screens/care_templates_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/risk_assessment_screen.dart';
import 'screens/cost_estimation_screen.dart';
import 'plugins/theme/theme_provider.dart';
import 'plugins/app_provider.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SisterCheckApp()));
}

class SisterCheckApp extends ConsumerWidget {
  const SisterCheckApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final appState = ref.watch(appNotifierProvider);
    
    // Determine initial route based on authentication status
    String initialRoute = '/splash';
    
    // If app is not loading and we have authentication state
    if (!appState.isLoading) {
      if (isAuthenticated || appState.isPatientAuthenticated) {
        initialRoute = '/home';
      } else {
        initialRoute = '/onboarding';
      }
    }

    return MaterialApp(
      title: 'SisterCheck',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,    
      initialRoute: initialRoute,
      routes: {
        '/splash': (context) => splash.SplashScreen(),
        '/onboarding': (context) => onboarding.OnboardingScreen(),
        '/login': (context) => AuthWrapper(
          requireAuth: false,
          child: LoginScreen(),
        ),
        '/signup': (context) => AuthWrapper(
          requireAuth: false,
          child: SignupScreen(),
        ),
        '/signup_user': (context) => AuthWrapper(
          requireAuth: false,
          child: SignupUserScreen(),
        ),
        '/home': (context) => AuthWrapper(
          requireAuth: true,
          child: HomeDashboardScreen(),
        ),
        '/riskquiz': (context) => AuthWrapper(
          requireAuth: true,
          child: RiskQuizScreen(),
        ),
        '/riskresult': (context) => AuthWrapper(
          requireAuth: true,
          child: RiskResultScreen(),
        ),
        '/cyclecalendar': (context) => AuthWrapper(
          requireAuth: true,
          child: CycleCalendarScreen(),
        ),
        '/cystalchat': (context) => AuthWrapper(
          requireAuth: true,
          child: CystalChatScreen(),
        ),
        '/chat_sessions': (context) => AuthWrapper(
          requireAuth: true,
          child: ChatSessionsScreen(),
        ),
        '/meetsister': (context) => AuthWrapper(
          requireAuth: true,
          child: MeetColleaguesScreen(),
        ),
        '/colleagues': (context) => AuthWrapper(
          requireAuth: true,
          child: MeetColleaguesScreen(),
        ),
        '/patients': (context) => AuthWrapper(
          requireAuth: true,
          child: PatientsScreen(),
        ),
        '/caretemplates': (context) => AuthWrapper(
          requireAuth: true,
          child: CareTemplatesScreen(),
        ),
        '/inventory': (context) => AuthWrapper(
          requireAuth: true,
          child: InventoryScreen(),
        ),
        '/riskassessment': (context) => AuthWrapper(
          requireAuth: true,
          child: RiskAssessmentScreen(),
        ),
        '/costestimation': (context) => AuthWrapper(
          requireAuth: true,
          child: CostEstimationScreen(),
        ),
        '/sisterchat': (context) => AuthWrapper(
          requireAuth: true,
          child: SisterChatScreen(),
        ),
        '/lessons': (context) => AuthWrapper(
          requireAuth: true,
          child: LessonsLibraryScreen(),
        ),
        '/redflagalert': (context) => AuthWrapper(
          requireAuth: true,
          child: RedFlagAlertsScreen(),
        ),
        '/clinicmap': (context) => AuthWrapper(
          requireAuth: true,
          child: ClinicMapScreen(),
        ),
        '/profile': (context) => AuthWrapper(
          requireAuth: true,
          child: ProfileScreen(),
        ),
        '/symptoms': (context) => AuthWrapper(
          requireAuth: true,
          child: SymptomsScreen(),
        ),
        '/symptoms_history': (context) => AuthWrapper(
          requireAuth: true,
          child: SymptomsHistoryScreen(),
        ),
        '/patient_login': (context) => AuthWrapper(
          requireAuth: false,
          child: PatientLoginScreen(),
        ),
        '/patient_signup': (context) => AuthWrapper(
          requireAuth: false,
          child: PatientSignupScreen(),
        ),
        '/patient_dashboard': (context) => AuthWrapper(
          requireAuth: true,
          child: PatientDashboardScreen(),
        ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('This is the $title page.')),
    );
  }
}

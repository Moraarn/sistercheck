import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';
import '../plugins/app_provider.dart';
import '../services/patient_dashboard_service.dart';
import '../models/patient_model.dart';

class PatientDashboardScreen extends ConsumerStatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  ConsumerState<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends ConsumerState<PatientDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Patient? _patient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
    _loadPatientProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientProfile() async {
    try {
      print('PatientDashboardScreen: Starting to load patient profile');
      
      // Check current authentication state
      final appState = ref.read(appNotifierProvider);
      print('PatientDashboardScreen: Current auth state - isPatientAuthenticated: ${appState.isPatientAuthenticated}');
      print('PatientDashboardScreen: Current auth state - patient: ${appState.patient?.id}');
      print('PatientDashboardScreen: Current auth state - patientToken: ${appState.patientToken != null ? 'exists' : 'null'}');
      
      // If not authenticated, try to use the current patient from app state
      if (!appState.isPatientAuthenticated && appState.patient != null) {
        print('PatientDashboardScreen: Using patient from app state');
        setState(() {
          _patient = appState.patient;
          _isLoading = false;
        });
        return;
      }
      
      final patientDashboardService = ref.read(patientDashboardServiceProvider);
      final result = await patientDashboardService.getPatientProfile();
      
      print('PatientDashboardScreen: Profile load result: $result');
      
      if (result['success']) {
        setState(() {
          _patient = result['patient'] as Patient;
          _isLoading = false;
        });
        print('PatientDashboardScreen: Patient profile loaded successfully: ${_patient?.id}');
      } else {
        setState(() {
          _isLoading = false;
        });
        print('PatientDashboardScreen: Failed to load profile: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('PatientDashboardScreen: Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      // For now, we'll use the app notifier to logout
      // In a real implementation, you might want to add a logout method to PatientDashboardService
      ref.read(appNotifierProvider.notifier).logout();
      Navigator.pushReplacementNamed(context, '/onboarding');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider) == ThemeMode.dark
        ? AppColors.dark
        : AppColors.light;
    final appState = ref.watch(appNotifierProvider);

    print('PatientDashboardScreen: _patient is null? ${_patient == null} id: ${_patient?.id}');

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Patient Dashboard',
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: colors.text),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.card,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.secondaryText,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Risk Assessment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Crystal AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Cycle Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) async {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              // Use the same endpoint as home dashboard for risk assessment
              try {
                final patientDashboardService = ref.read(patientDashboardServiceProvider);
                Navigator.pushNamed(context, '/riskassessment');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error accessing risk assessment: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              break;
            case 2:
              Navigator.pushNamed(context, '/cystalchat');
              break;
            case 3:
              Navigator.pushNamed(context, '/cyclecalendar');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cyclecalendar');
            },
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            heroTag: "cycle_calendar",
            child: Icon(Icons.calendar_today),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () async {
              // Use the same endpoint as home dashboard
              try {
                final patientDashboardService = ref.read(patientDashboardServiceProvider);
                // For now, navigate to risk assessment screen
                Navigator.pushNamed(context, '/riskassessment');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error accessing risk assessment: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            heroTag: "risk_assessment",
            icon: Icon(Icons.health_and_safety),
            label: Text('Risk Assessment'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your profile...',
                    style: TextStyle(color: colors.text),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.primary.withOpacity(0.1),
                              colors.primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: colors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back!',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: colors.text,
                                        ),
                                      ),
                                      Text(
                                        'Patient ${_patient?.id ?? 'Unknown'}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: colors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // // Health Information Section
                      // Text(
                      //   'Health Information',
                      //   style: TextStyle(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.bold,
                      //     color: colors.text,
                      //   ),
                      // ),
                      // const SizedBox(height: 16),
                      
                      // // Health Info Cards
                      // _buildHealthInfoCard(
                      //   'Age',
                      //   '${_patient?.age ?? 'N/A'} years',
                      //   Icons.calendar_today,
                      //   colors,
                      // ),
                      // const SizedBox(height: 12),
                      
                      // _buildHealthInfoCard(
                      //   'Region',
                      //   _patient?.region ?? 'N/A',
                      //   Icons.location_on,
                      //   colors,
                      // ),
                      // const SizedBox(height: 12),
                      
                      if (_patient != null && _patient!.cystSize != null) ...[
                        _buildHealthInfoCard(
                          'Cyst Size',
                          '${_patient!.cystSize} cm',
                          Icons.straighten,
                          colors,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      if (_patient != null && _patient!.ca125Level != null) ...[
                        _buildHealthInfoCard(
                          'CA-125 Level',
                          '${_patient!.ca125Level} U/mL',
                          Icons.science,
                          colors,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      if (_patient != null && _patient!.riskLevel != PatientRiskLevel.unknown) ...[
                        _buildHealthInfoCard(
                          'Risk Level',
                          _patient!.riskLevel.value,
                          Icons.warning,
                          colors,
                          riskColor: _patient!.riskLevel.color,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Quick Actions Section
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Action Buttons - First Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Risk Assessment',
                              Icons.health_and_safety,
                              () async {
                                // Use the same endpoint as home dashboard
                                try {
                                  final patientDashboardService = ref.read(patientDashboardServiceProvider);
                                  // For now, navigate to risk assessment screen
                                  // In a real implementation, you might want to show a loading state
                                  Navigator.pushNamed(context, '/riskassessment');
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error accessing risk assessment: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              colors,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              'Talk to Crystal',
                              Icons.chat,
                              () {
                                Navigator.pushNamed(context, '/cystalchat');
                              },
                              colors,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Action Buttons - Second Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Cost Estimation',
                              Icons.calculate,
                              () async {
                                // Use the same endpoint as home dashboard
                                try {
                                  final patientDashboardService = ref.read(patientDashboardServiceProvider);
                                  // For now, navigate to cost estimation screen
                                  // In a real implementation, you might want to show a loading state
                                  Navigator.pushNamed(context, '/costestimation');
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error accessing cost estimation: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              colors,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              'Find My Clinic',
                              Icons.location_on,
                              () {
                                Navigator.pushNamed(context, '/clinicmap');
                              },
                              colors,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Action Buttons - Third Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Cycle Calendar',
                              Icons.calendar_today,
                              () {
                                Navigator.pushNamed(context, '/cyclecalendar');
                              },
                              colors,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              'Track Symptoms',
                              Icons.healing,
                              () {
                                Navigator.pushNamed(context, '/symptoms');
                              },
                              colors,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Action Buttons - Fourth Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Update Profile',
                              Icons.edit,
                              () {
                                // TODO: Navigate to profile update
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Profile update feature coming soon!'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                              colors,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(), // Empty container to maintain layout
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Health Insights Section
                      Text(
                        'Health Insights',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            _buildInsightItem(
                              'Regular Check-ups',
                              'Schedule your next appointment',
                              Icons.calendar_today,
                              Colors.blue,
                              colors,
                            ),
                            const SizedBox(height: 12),
                            _buildInsightItem(
                              'Risk Monitoring',
                              'Track your health indicators',
                              Icons.trending_up,
                              Colors.green,
                              colors,
                            ),
                            const SizedBox(height: 12),
                            _buildInsightItem(
                              'Medication Reminders',
                              'Stay on track with your treatment',
                              Icons.medication,
                              Colors.orange,
                              colors,
                            ),
                            const SizedBox(height: 12),
                            _buildInsightItem(
                              'Cycle Tracking',
                              'Monitor your menstrual cycle',
                              Icons.calendar_today,
                              Colors.pink,
                              colors,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Recent Activity Section
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            _buildActivityItem(
                              'Profile created',
                              'Your patient profile was successfully created',
                              Icons.person_add,
                              colors,
                            ),
                            const SizedBox(height: 12),
                            _buildActivityItem(
                              'Risk assessment completed',
                              'Your health risk has been evaluated',
                              Icons.health_and_safety,
                              colors,
                            ),
                            const SizedBox(height: 12),
                            _buildActivityItem(
                              'Crystal AI consultation',
                              'You had a helpful chat with Crystal',
                              Icons.chat,
                              colors,
                            ),
                            const SizedBox(height: 12),
                            _buildActivityItem(
                              'Cost estimation viewed',
                              'You checked treatment costs',
                              Icons.calculate,
                              colors,
                            ),
                            const SizedBox(height: 12),
                            _buildActivityItem(
                              'Cycle tracked',
                              'You updated your cycle calendar',
                              Icons.calendar_today,
                              colors,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHealthInfoCard(String title, String value, IconData icon, AppColors colors, {Color? riskColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (riskColor ?? colors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: riskColor ?? colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed, AppColors colors) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.card,
        foregroundColor: colors.text,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: colors.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, AppColors colors) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colors.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(String title, String subtitle, IconData icon, Color iconColor, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
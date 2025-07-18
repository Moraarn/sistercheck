import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';
import '../plugins/app_provider.dart';
import '../models/user_model.dart';
import '../models/patient_model.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _selectedIndex = 0;

  List<Map<String, dynamic>> get dashboardItems {
    final appState = ref.watch(appNotifierProvider);
    final isPatient = appState.patient != null;
    
    if (isPatient) {
      // Patient dashboard items
      return [
        {
          'icon': Icons.shield,
          'label': 'Risk Assessment',
          'route': '/riskassessment',
          'color': Colors.orange[100]!,
          'description': 'Check your risk level',
        },
        {
          'icon': Icons.chat_bubble,
          'label': 'Talk to Crystal',
          'route': '/cystalchat',
          'color': Colors.indigo[100]!,
          'description': 'AI health assistant',
        },
        {
          'icon': Icons.map,
          'label': 'Find My Clinic',
          'route': '/clinicmap',
          'color': Colors.lime[100]!,
          'description': 'Nearby clinics',
        },
        {
          'icon': Icons.attach_money,
          'label': 'Cost Estimation',
          'route': '/costestimation',
          'color': Colors.green[100]!,
          'description': 'Treatment costs',
        },
        {
          'icon': Icons.healing,
          'label': 'Symptoms',
          'route': '/symptoms',
          'color': Colors.red[100]!,
          'description': 'Track symptoms',
        },
        {
          'icon': Icons.calendar_today,
          'label': 'Cycle Calendar',
          'route': '/cyclecalendar',
          'color': Colors.pink[100]!,
          'description': 'Track your cycle',
        },
      ];
    } else {
      // Doctor/Healthcare provider dashboard items
      return [
        {
          'icon': Icons.people,
          'label': 'Patients',
          'route': '/patients',
          'color': Colors.blue[100]!,
          'description': 'View and manage patients',
        },
        {
          'icon': Icons.assignment,
          'label': 'Care Templates',
          'route': '/caretemplates',
          'color': Colors.teal[100]!,
          'description': 'AI-driven care plans',
        },
        {
          'icon': Icons.shield,
          'label': 'Risk Assessment',
          'route': '/riskassessment',
          'color': Colors.orange[100]!,
          'description': 'Guideline-based risk analysis',
        },
        {
          'icon': Icons.attach_money,
          'label': 'Cost Estimation',
          'route': '/costestimation',
          'color': Colors.green[100]!,
          'description': 'Detailed cost breakdowns',
        },
        {
          'icon': Icons.inventory,
          'label': 'Inventory Status',
          'route': '/inventory',
          'color': Colors.purple[100]!,
          'description': 'Real-time inventory',
        },
        {
          'icon': Icons.groups,
          'label': 'Meet Colleagues',
          'route': '/colleagues',
          'color': Colors.brown[100]!,
          'description': 'Network with doctors',
        },
      ];
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    final appState = ref.read(appNotifierProvider);
    final isPatient = appState.patient != null;
    
    if (isPatient) {
      // Patient navigation
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/riskassessment');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/cystalchat');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/clinicmap');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    } else {
      // Doctor navigation
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/patients');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/caretemplates');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/colleagues');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    }
  }

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;
    final appState = ref.watch(appNotifierProvider);
    final isPatient = appState.patient != null;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'SisterCheck Dashboard',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.card,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: colors.text),
          onPressed: () {
            // Add menu functionality here
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6, color: colors.text),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.primary.withOpacity(0.1),
                  colors.scaffoldBackground,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.border.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: colors.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPatient ? 'Welcome back, Patient!' : 'Welcome back, Doctor!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isPatient ? 'How can we help you today?' : 'Manage your patients and care plans',
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
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Risk Level',
                          'Low',
                          Icons.shield,
                          Colors.green,
                          colors,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Last Check',
                          '2 days ago',
                          Icons.calendar_today,
                          colors.primary,
                          colors,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Services grid
                  Text(
                    isPatient ? 'Patient Services' : 'Healthcare Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: dashboardItems.length,
                    itemBuilder: (context, index) {
                      final item = dashboardItems[index];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, item['route']),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colors.border.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: item['color'],
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Icon(
                                    item['icon'],
                                    size: 28,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item['label'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colors.text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['description'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent activity
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.border.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history, color: colors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          'Completed risk assessment',
                          '2 days ago',
                          Icons.check_circle,
                          Colors.green,
                          colors,
                        ),
                        _buildActivityItem(
                          'Tracked symptoms',
                          '1 week ago',
                          Icons.healing,
                          colors.primary,
                          colors,
                        ),
                        _buildActivityItem(
                          'Read health article',
                          '1 week ago',
                          Icons.article,
                          Colors.blue,
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
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.card,
          boxShadow: [
            BoxShadow(
              color: colors.border.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
          selectedItemColor: colors.primary,
          unselectedItemColor: colors.secondaryText,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: colors.card,
          elevation: 0,
          items: isPatient ? [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Risk Assessment'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Crystal AI'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Find Clinic'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ] : [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Care Templates'),
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Colleagues'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.border.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 16),
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
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
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
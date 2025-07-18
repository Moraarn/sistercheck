import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';
import '../services/risk_assessment_service.dart';
import '../models/risk_assessment.dart';

class RiskResultScreen extends ConsumerStatefulWidget {
  final RiskAssessment? assessment;

  const RiskResultScreen({super.key, this.assessment});

  @override
  ConsumerState<RiskResultScreen> createState() => _RiskResultScreenState();
}

class _RiskResultScreenState extends ConsumerState<RiskResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  late Map<String, dynamic> riskData;

  @override
  void initState() {
    super.initState();
    _initializeRiskData();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
  }

  void _initializeRiskData() {
    if (widget.assessment != null) {
      // Use data from backend assessment
      final assessment = widget.assessment!;
      final riskLevel = assessment.riskLevel;
      
      // Determine color based on risk level
      Color riskColor;
      String description;
      
      switch (riskLevel.toLowerCase()) {
        case 'low':
          riskColor = Colors.green;
          description = 'Your risk level is low. Continue maintaining a healthy lifestyle and regular check-ups.';
          break;
        case 'moderate':
          riskColor = Colors.orange;
          description = 'Consider talking to a Sister for support, or visit a clinic if you have concerns.';
          break;
        case 'high':
          riskColor = Colors.red;
          description = 'Please schedule an appointment with a healthcare provider as soon as possible.';
          break;
        default:
          riskColor = Colors.orange;
          description = 'Consider talking to a Sister for support, or visit a clinic if you have concerns.';
      }

      riskData = {
        'level': riskLevel,
        'score': assessment.score,
        'color': riskColor,
        'description': description,
        'recommendations': assessment.recommendations,
        'nextSteps': [
          {
            'title': 'Learn More',
            'description': 'Understand your risk factors better',
            'icon': Icons.menu_book,
            'route': '/learnmore',
            'color': Colors.blue,
          },
          {
            'title': 'Talk to a Sister',
            'description': 'Get peer support and guidance',
            'icon': Icons.volunteer_activism,
            'route': '/talksister',
            'color': Colors.purple,
          },
          {
            'title': 'Find a Clinic',
            'description': 'Locate nearby healthcare facilities',
            'icon': Icons.local_hospital,
            'route': '/findclinic',
            'color': Colors.green,
          },
        ],
      };
    } else {
      // Fallback to default data
      riskData = {
        'level': 'Moderate',
        'score': 65,
        'color': Colors.orange,
        'description': 'Consider talking to a Sister for support, or visit a clinic if you have concerns.',
        'recommendations': [
          'Schedule a consultation with a healthcare provider',
          'Track your symptoms regularly',
          'Consider lifestyle changes',
          'Join support groups for additional guidance',
        ],
        'nextSteps': [
          {
            'title': 'Learn More',
            'description': 'Understand your risk factors better',
            'icon': Icons.menu_book,
            'route': '/learnmore',
            'color': Colors.blue,
          },
          {
            'title': 'Talk to a Sister',
            'description': 'Get peer support and guidance',
            'icon': Icons.volunteer_activism,
            'route': '/talksister',
            'color': Colors.purple,
          },
          {
            'title': 'Find a Clinic',
            'description': 'Locate nearby healthcare facilities',
            'icon': Icons.local_hospital,
            'route': '/findclinic',
            'color': Colors.green,
          },
        ],
      };
    }
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

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Risk Assessment Result',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.card,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: colors.primary),
            onPressed: () {
              // Add share functionality
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
                  // Risk level card
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
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
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: riskData['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              Icons.health_and_safety,
                              size: 40,
                              color: riskData['color'],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            riskData['level'],
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: riskData['color'],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Risk Level',
                            style: TextStyle(
                              fontSize: 16,
                              color: colors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.inputFieldBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: riskData['score'] / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: riskData['color'],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Score: ${riskData['score']}/100',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
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
                            Icon(Icons.info, color: colors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'What This Means',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          riskData['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.text,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recommendations
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
                            Icon(Icons.lightbulb, color: colors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Recommendations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...riskData['recommendations'].map((rec) => _buildRecommendationItem(rec, colors)).toList(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Next steps
                  Text(
                    'Next Steps',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ...riskData['nextSteps'].map((step) => _buildNextStepCard(step, colors)).toList(),
                  
                  const SizedBox(height: 24),
                  
                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.inputFieldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This assessment is for informational purposes only and should not replace professional medical advice.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.secondaryText,
                            ),
                          ),
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
    );
  }

  Widget _buildRecommendationItem(String recommendation, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: TextStyle(
                fontSize: 14,
                color: colors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepCard(Map<String, dynamic> step, AppColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, step['route']),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: step['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  step['icon'],
                  color: step['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: colors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
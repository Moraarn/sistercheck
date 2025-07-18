import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistercheck/plugins/app_provider.dart';
import 'package:sistercheck/plugins/theme/colors.dart';
import 'package:sistercheck/services/care_template_service.dart';

class CareTemplateScreen extends ConsumerStatefulWidget {
  final CareTemplate? careTemplate;

  const CareTemplateScreen({super.key, this.careTemplate});

  @override
  ConsumerState<CareTemplateScreen> createState() => _CareTemplateScreenState();
}

class _CareTemplateScreenState extends ConsumerState<CareTemplateScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  CareTemplate? careTemplate;
  bool _isLoading = false;
  
  ProviderListenable? get authProvider => null;

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
    
    // If no care template is passed, load the latest one
    if (widget.careTemplate == null) {
      _loadLatestCareTemplate();
    } else {
      careTemplate = widget.careTemplate;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestCareTemplate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = ref.read(authProvider!).token;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to view care templates')),
        );
        return;
      }

      final service = ref.read(careTemplateServiceProvider);
      final result = await service.getUserLatestCareTemplate(token: token);

      if (result['success']) {
        setState(() {
          careTemplate = result['careTemplate'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'No care template found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getTreatmentPlanColor(String treatmentPlan) {
    switch (treatmentPlan.toLowerCase()) {
      case 'surgery':
        return Colors.red;
      case 'medication':
        return Colors.orange;
      case 'observation':
        return Colors.blue;
      case 'referral':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ref.watch(themeModeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Care Template',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.primary),
            onPressed: _loadLatestCareTemplate,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: colors.primary))
              : careTemplate == null
                  ? _buildNoTemplateView(colors)
                  : _buildCareTemplateView(colors),
        ),
      ),
    );
  }

  Widget _buildNoTemplateView(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: colors.icon,
          ),
          const SizedBox(height: 16),
          Text(
            'No Care Template Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a symptom assessment or risk assessment\nto generate your personalized care template.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildCareTemplateView(AppColors colors) {
    final template = careTemplate!;
    final prediction = template.prediction;
    final carePlan = template.carePlan;
    final patientData = template.patientData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
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
                Icon(
                  Icons.medical_services,
                  size: 48,
                  color: colors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Care Template',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(template.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(template.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    template.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(template.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Treatment Plan Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
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
                    Icon(
                      Icons.psychology,
                      color: colors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI Treatment Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getTreatmentPlanColor(prediction['treatmentPlan']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getTreatmentPlanColor(prediction['treatmentPlan']),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        prediction['treatmentPlan'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getTreatmentPlanColor(prediction['treatmentPlan']),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Confidence: ${((prediction['confidence'] ?? 0) * 100).toStringAsFixed(1)}%',
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

          const SizedBox(height: 20),

          // Patient Data Card
          if (patientData.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
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
                      Icon(
                        Icons.person,
                        color: colors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Patient Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...patientData.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value?.toString() ?? 'N/A',
                            style: TextStyle(color: colors.secondaryText),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Recommendations Card
          if (carePlan['recommendations'] != null && (carePlan['recommendations'] as List).isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
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
                      Icon(
                        Icons.lightbulb,
                        color: colors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recommendations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...(carePlan['recommendations'] as List).map((recommendation) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: colors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recommendation,
                            style: TextStyle(color: colors.text),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Next Steps Card
          if (carePlan['nextSteps'] != null && (carePlan['nextSteps'] as List).isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
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
                      Icon(
                        Icons.arrow_forward,
                        color: colors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Next Steps',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...(carePlan['nextSteps'] as List).map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.arrow_right,
                          color: colors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step,
                            style: TextStyle(color: colors.text),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Cost Information Card
          if (carePlan['costInfo'] != null && carePlan['costInfo'] != 'Not Available') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
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
                      Icon(
                        Icons.attach_money,
                        color: colors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cost Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (carePlan['costInfo']['service'] != null)
                    Text(
                      'Service: ${carePlan['costInfo']['service']}',
                      style: TextStyle(color: colors.text),
                    ),
                  if (carePlan['costInfo']['baseCost'] != null)
                    Text(
                      'Base Cost: KES ${carePlan['costInfo']['baseCost']}',
                      style: TextStyle(color: colors.text),
                    ),
                  if (carePlan['costInfo']['outOfPocket'] != null)
                    Text(
                      'Out of Pocket: KES ${carePlan['costInfo']['outOfPocket']}',
                      style: TextStyle(color: colors.text),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Created Date
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Generated on: ${template.createdAt.toString().split('.')[0]}',
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 
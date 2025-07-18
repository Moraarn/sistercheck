import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistercheck/plugins/app_provider.dart';
import 'package:sistercheck/plugins/theme/colors.dart';
import 'package:sistercheck/services/care_template_service.dart';
import 'care_template_screen.dart';

class CareTemplateHistoryScreen extends ConsumerStatefulWidget {
  const CareTemplateHistoryScreen({super.key});

  @override
  ConsumerState<CareTemplateHistoryScreen> createState() => _CareTemplateHistoryScreenState();
}

class _CareTemplateHistoryScreenState extends ConsumerState<CareTemplateHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<CareTemplate> careTemplates = [];
  bool _isLoading = false;
  String _selectedStatus = 'all';
  
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
    _loadCareTemplates();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCareTemplates() async {
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
      final result = await service.getUserCareTemplates(token: token);

      if (result['success']) {
        setState(() {
          careTemplates = result['careTemplates'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to load care templates')),
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

  Future<void> _loadCareTemplatesByStatus(String status) async {
    if (status == 'all') {
      await _loadCareTemplates();
      return;
    }

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
      final result = await service.getCareTemplatesByStatus(token: token, status: status);

      if (result['success']) {
        setState(() {
          careTemplates = result['careTemplates'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to load care templates')),
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
          'Care Template History',
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
            onPressed: _loadCareTemplates,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Status Filter
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip(colors, 'all', 'All'),
                      const SizedBox(width: 8),
                      _buildStatusChip(colors, 'pending', 'Pending'),
                      const SizedBox(width: 8),
                      _buildStatusChip(colors, 'approved', 'Approved'),
                      const SizedBox(width: 8),
                      _buildStatusChip(colors, 'in_progress', 'In Progress'),
                      const SizedBox(width: 8),
                      _buildStatusChip(colors, 'completed', 'Completed'),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: colors.primary))
                    : careTemplates.isEmpty
                        ? _buildEmptyState(colors)
                        : _buildCareTemplatesList(colors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(AppColors colors, String status, String label) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : colors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
        });
        _loadCareTemplatesByStatus(status);
      },
      backgroundColor: colors.card,
      selectedColor: colors.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(color: colors.border),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
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
            'No Care Templates Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a symptom assessment or risk assessment\nto generate your first care template.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareTemplatesList(AppColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: careTemplates.length,
      itemBuilder: (context, index) {
        final template = careTemplates[index];
        final prediction = template.prediction;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CareTemplateScreen(careTemplate: template),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Care Template #${template.id.substring(template.id.length - 8)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Generated: ${template.createdAt.toString().split('.')[0]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(template.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
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
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getTreatmentPlanColor(prediction['treatmentPlan']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getTreatmentPlanColor(prediction['treatmentPlan']),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.psychology,
                            color: _getTreatmentPlanColor(prediction['treatmentPlan']),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              prediction['treatmentPlan'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getTreatmentPlanColor(prediction['treatmentPlan']),
                              ),
                            ),
                          ),
                          Text(
                            '${((prediction['confidence'] ?? 0) * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getTreatmentPlanColor(prediction['treatmentPlan']),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: colors.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to view details',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 
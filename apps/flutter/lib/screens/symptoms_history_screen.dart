import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';
import '../services/symptoms_service.dart'; 

class SymptomsHistoryScreen extends ConsumerStatefulWidget {
  const SymptomsHistoryScreen({super.key});

  @override
  ConsumerState<SymptomsHistoryScreen> createState() => _SymptomsHistoryScreenState();
}

class _SymptomsHistoryScreenState extends ConsumerState<SymptomsHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  List<String> _getActiveSymptoms(Map<String, dynamic> symptoms) {
    final activeSymptoms = <String>[];
    symptoms.forEach((key, value) {
      if (value == true && key != 'otherSymptoms') {
        // Convert camelCase to readable format
        final readableName = key.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)?.toLowerCase()}',
        ).trim();
        activeSymptoms.add(readableName.split(' ').map((word) => 
          word[0].toUpperCase() + word.substring(1)
        ).join(' '));
      }
    });
    return activeSymptoms;
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
          'Symptoms History',
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
            icon: Icon(Icons.refresh, color: colors.primary),
            onPressed: () {
              ref.refresh(userSymptomsProvider);
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
            child: Consumer(
              builder: (context, ref, child) {
                final symptomsAsync = ref.watch(userSymptomsProvider);
                
                return symptomsAsync.when(
                  data: (symptoms) {
                    if (symptoms.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: colors.secondaryText,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No symptoms recorded yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: colors.text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start tracking your symptoms to see your history here',
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.secondaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/symptoms');
                              },
                              icon: Icon(Icons.add),
                              label: Text('Add Symptoms'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: symptoms.length,
                      itemBuilder: (context, index) {
                        final symptom = symptoms[index];
                        final activeSymptoms = _getActiveSymptoms(symptom.symptoms);
                        final severityColor = _getSeverityColor(symptom.severity);

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
                          child: ExpansionTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: severityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.health_and_safety,
                                color: severityColor,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              symptom.severity,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: severityColor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Duration: ${symptom.duration}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.secondaryText,
                                  ),
                                ),
                                Text(
                                  '${_formatDate(symptom.createdAt)} at ${_formatTime(symptom.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.expand_more,
                              color: colors.text,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (activeSymptoms.isNotEmpty) ...[
                                      Text(
                                        'Symptoms:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colors.text,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: activeSymptoms.map((symptomName) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colors.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              symptomName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colors.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    if (symptom.symptoms['otherSymptoms'] != null && 
                                        symptom.symptoms['otherSymptoms'].toString().isNotEmpty) ...[
                                      Text(
                                        'Additional Symptoms:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colors.text,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        symptom.symptoms['otherSymptoms'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colors.text,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    if (symptom.notes != null && symptom.notes!.isNotEmpty) ...[
                                      Text(
                                        'Notes:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colors.text,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        symptom.notes!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colors.text,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            // TODO: Implement edit functionality
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Edit functionality coming soon'),
                                                backgroundColor: Colors.blue,
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.edit, size: 16),
                                          label: Text('Edit'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: colors.primary,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () async {
                                            // Show delete confirmation
                                            final shouldDelete = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Delete Symptom Entry'),
                                                content: Text('Are you sure you want to delete this symptom entry?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (shouldDelete == true) {
                                              try {
                                                final service = ref.read(symptomsServiceProvider);
                                                final success = await service.deleteSymptom(symptom.id);
                                                if (success) {
                                                  ref.refresh(userSymptomsProvider);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Symptom entry deleted successfully'),
                                                      backgroundColor: Colors.green,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error deleting symptom entry: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          icon: Icon(Icons.delete, size: 16),
                                          label: Text('Delete'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading symptoms history...',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading symptoms',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.refresh(userSymptomsProvider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
} 
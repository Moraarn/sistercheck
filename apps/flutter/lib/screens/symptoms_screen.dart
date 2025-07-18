import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistercheck/plugins/app_provider.dart';
import 'package:sistercheck/plugins/theme/colors.dart';
import 'package:sistercheck/services/symptoms_service.dart'; 

class SymptomsScreen extends ConsumerStatefulWidget {
  const SymptomsScreen({super.key});

  @override
  ConsumerState<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends ConsumerState<SymptomsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> commonSymptoms = [
    {
      'name': 'Bloating',
      'key': 'bloating',
      'icon': Icons.air,
      'severity': 0,
      'color': Colors.yellow[100]!,
    },
    {
      'name': 'Pelvic Pain',
      'key': 'pelvicPain',
      'icon': Icons.healing,
      'severity': 0,
      'color': Colors.red[100]!,
    },
    {
      'name': 'Irregular Periods',
      'key': 'irregularPeriods',
      'icon': Icons.calendar_today,
      'severity': 0,
      'color': Colors.pink[100]!,
    },
    {
      'name': 'Heavy Bleeding',
      'key': 'heavyBleeding',
      'icon': Icons.water_drop,
      'severity': 0,
      'color': Colors.red[200]!,
    },
    {
      'name': 'Fatigue',
      'key': 'fatigue',
      'icon': Icons.bedtime,
      'severity': 0,
      'color': Colors.orange[100]!,
    },
    {
      'name': 'Mood Swings',
      'key': 'moodSwings',
      'icon': Icons.psychology,
      'severity': 0,
      'color': Colors.purple[100]!,
    },
    {
      'name': 'Breast Tenderness',
      'key': 'breastTenderness',
      'icon': Icons.favorite,
      'severity': 0,
      'color': Colors.pink[100]!,
    },
    {
      'name': 'Back Pain',
      'key': 'backPain',
      'icon': Icons.accessibility,
      'severity': 0,
      'color': Colors.green[100]!,
    },
    {
      'name': 'Nausea',
      'key': 'nausea',
      'icon': Icons.sick,
      'severity': 0,
      'color': Colors.teal[100]!,
    },
    {
      'name': 'Weight Gain',
      'key': 'weightGain',
      'icon': Icons.monitor_weight,
      'severity': 0,
      'color': Colors.blue[100]!,
    },
  ];

  final TextEditingController _notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool _isSaving = false;
  final String _selectedSeverity = 'Mild';

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
    _notesController.dispose();
    super.dispose();
  }

  void _updateSymptomSeverity(int index, int severity) {
    setState(() {
      commonSymptoms[index]['severity'] = severity;
    });
  }

  String _calculateOverallSeverity() {
    final totalSeverity = commonSymptoms.fold<int>(0, (sum, symptom) => sum + (symptom['severity'] as int));
    final averageSeverity = totalSeverity / commonSymptoms.length;
    
    if (averageSeverity <= 1) return 'Mild';
    if (averageSeverity <= 3) return 'Moderate';
    return 'Severe';
  }

  String _calculateDuration() {
    final now = DateTime.now();
    final difference = now.difference(selectedDate);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return '1 day';
    if (difference.inDays < 7) return '${difference.inDays} days';
    if (difference.inDays < 14) return '${(difference.inDays / 7).round()} week${(difference.inDays / 7).round() == 1 ? '' : 's'}';
    return '${(difference.inDays / 7).round()} weeks';
  }

  Future<void> _saveSymptoms() async {
    // Check if any symptoms are selected
    final hasSymptoms = commonSymptoms.any((symptom) => symptom['severity'] > 0);
    if (!hasSymptoms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one symptom'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Convert symptoms to backend format
      final symptomsData = <String, dynamic>{};
      String otherSymptoms = '';
      
      for (final symptom in commonSymptoms) {
        final key = symptom['key'] as String;
        final severity = symptom['severity'] as int;
        
        if (severity > 0) {
          symptomsData[key] = true;
          if (severity >= 4) {
            otherSymptoms += '${symptom['name']} (Severe: $severity/5), ';
          }
        } else {
          symptomsData[key] = false;
        }
      }

      // Remove trailing comma and space
      if (otherSymptoms.isNotEmpty) {
        otherSymptoms = otherSymptoms.substring(0, otherSymptoms.length - 2);
      }

      // Add other symptoms if any
      if (otherSymptoms.isNotEmpty) {
        symptomsData['otherSymptoms'] = otherSymptoms;
      }

      final service = ref.read(symptomsServiceProvider);
      final result = await service.createSymptom(
        symptoms: symptomsData,
        severity: _calculateOverallSeverity(),
        duration: _calculateDuration(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Symptoms saved successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to save symptoms'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
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
          'Track Symptoms',
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
            icon: Icon(Icons.save, color: colors.primary),
            onPressed: _isSaving ? null : _saveSymptoms,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selector
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          child: Text(
                            'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.text,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Symptoms Section
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rate the severity of each symptom (0 = None, 5 = Very Severe)',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryText,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Symptoms Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: commonSymptoms.length,
                  itemBuilder: (context, index) {
                    final symptom = commonSymptoms[index];
                    return Container(
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            symptom['icon'],
                            size: 32,
                            color: symptom['severity'] > 0 
                                ? colors.primary 
                                : colors.icon,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            symptom['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (i) {
                              return GestureDetector(
                                onTap: () => _updateSymptomSeverity(index, i),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: i <= symptom['severity'] 
                                        ? colors.primary 
                                        : colors.border,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Notes Section
                Text(
                  'Additional Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colors.inputFieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.inputFieldBorder),
                  ),
                  child: TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add any additional notes about your symptoms...',
                      hintStyle: TextStyle(color: colors.secondaryText),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: TextStyle(color: colors.text),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSymptoms,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: _isSaving
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Saving...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save),
                              const SizedBox(width: 8),
                              Text(
                                'Save Symptoms',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
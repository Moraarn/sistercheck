import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';
import '../services/doctor_dashboard_service.dart';
import '../models/risk_assessment.dart';
import 'risk_result_screen.dart';

class RiskAssessmentScreen extends ConsumerStatefulWidget {
  const RiskAssessmentScreen({super.key});

  @override
  ConsumerState<RiskAssessmentScreen> createState() => _RiskAssessmentScreenState();
}

class _RiskAssessmentScreenState extends ConsumerState<RiskAssessmentScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _cystSizeController = TextEditingController();
  final _ca125Controller = TextEditingController();
  final _cystGrowthController = TextEditingController();
  
  String _menopauseStage = 'Pre-menopausal';
  String _ultrasoundFeatures = 'Simple cyst';
  String _reportedSymptoms = '';
  
  bool _isLoading = false;
  RiskAssessment? _assessmentResult;

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
    _ageController.dispose();
    _cystSizeController.dispose();
    _ca125Controller.dispose();
    _cystGrowthController.dispose();
    super.dispose();
  }

  Future<void> _submitAssessment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final patientData = {
        'Age': int.parse(_ageController.text),
        'Menopause Stage': _menopauseStage,
        'SI Cyst Size cm': double.parse(_cystSizeController.text),
        'Cyst Growth': double.parse(_cystGrowthController.text),
        'fca 125 Level': int.parse(_ca125Controller.text),
        'Ultrasound Fe': _ultrasoundFeatures,
        'Reported Sym': _reportedSymptoms,
      };

      final result = await ref.read(doctorDashboardServiceProvider).createRiskAssessment(patientData);

      if (result['success']) {
        setState(() {
          _assessmentResult = RiskAssessment.fromJson(result['risk_assessment']);
        });
        
        // Show result popup
        _showAssessmentResultPopup(result['risk_assessment']);
      } else {
        _showErrorDialog(result['message'] ?? 'Failed to create risk assessment');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAssessmentResultPopup(Map<String, dynamic> assessmentResult) {
    final colors = ref.read(themeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;
    final riskAssessment = RiskAssessment.fromJson(assessmentResult);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 40,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Assessment Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Your risk assessment has been completed successfully',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Risk Level Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getRiskColor(assessmentResult['risk_level']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getRiskColor(assessmentResult['risk_level']).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            color: _getRiskColor(assessmentResult['risk_level']),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Risk Level: ${assessmentResult['risk_level']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getRiskColor(assessmentResult['risk_level']),
                            ),
                          ),
                        ],
                      ),
                      if (assessmentResult['risk_score'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Score: ${assessmentResult['risk_score']}/10',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Risk Factors
                if ((assessmentResult['risk_factors'] as List?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.inputFieldBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Risk Factors:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(assessmentResult['risk_factors'] as List).map((factor) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: _getRiskColor(assessmentResult['risk_level']),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  factor.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: colors.primary),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RiskResultScreen(
                                assessment: riskAssessment,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    final colors = ref.read(themeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Assessment Failed',
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(color: colors.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(color: colors.primary),
              ),
            ),
          ],
        );
      },
    );
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
          'Risk Assessment',
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
      ),
      body: Stack(
        children: [
          FadeTransition(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                        padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.primary.withOpacity(0.1),
                              colors.primary.withOpacity(0.05),
                            ],
                          ),
                      color: colors.card,
                          borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors.border.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                          Icons.shield,
                                size: 40,
                          color: colors.primary,
                        ),
                            ),
                            const SizedBox(height: 20),
                        Text(
                          'Patient Risk Assessment',
                          style: TextStyle(
                                fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                          textAlign: TextAlign.center,
                        ),
                            const SizedBox(height: 12),
                        Text(
                          'Enter patient data to assess ovarian cyst risk based on Kenyan guidelines',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.secondaryText,
                                height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: colors.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI-Powered Assessment',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Assessment Form
                  Container(
                        padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: colors.card,
                          borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                              color: colors.border.withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: colors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.person_add,
                                      color: colors.primary,
                                      size: 20,
                                    ),
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
                              const SizedBox(height: 8),
                              Text(
                                'Fill in the details below to assess the patient\'s risk level',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 24),
                          
                          // Age
                          TextFormField(
                            controller: _ageController,
                                style: TextStyle(color: getInputText(context, Theme.of(context).brightness == Brightness.dark), fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: 'Age',
                                  hintText: 'Enter patient age',
                                  labelStyle: TextStyle(color: getLabelText(context, Theme.of(context).brightness == Brightness.dark)),
                                  hintStyle: TextStyle(color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  prefixIcon: Icon(Icons.person, color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  filled: true,
                                  fillColor: getInputBg(context, Theme.of(context).brightness == Brightness.dark),
                              border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: getBorderColor(context, Theme.of(context).brightness == Brightness.dark)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter age';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid age';
                              }
                              return null;
                            },
                          ),
                              const SizedBox(height: 24),
                          
                          // Menopause Stage
                          DropdownButtonFormField<String>(
                            value: _menopauseStage,
                                style: TextStyle(color: getInputText(context, Theme.of(context).brightness == Brightness.dark), fontWeight: FontWeight.w600),
                                dropdownColor: getInputBg(context, Theme.of(context).brightness == Brightness.dark),
                                iconEnabledColor: colors.primary,
                            decoration: InputDecoration(
                              labelText: 'Menopause Stage',
                                  labelStyle: TextStyle(color: getLabelText(context, Theme.of(context).brightness == Brightness.dark)),
                                  hintStyle: TextStyle(color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  prefixIcon: Icon(Icons.woman, color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  filled: true,
                                  fillColor: getInputBg(context, Theme.of(context).brightness == Brightness.dark),
                              border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: getBorderColor(context, Theme.of(context).brightness == Brightness.dark)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                            ),
                            items: [
                              'Pre-menopausal',
                              'Peri-menopausal',
                              'Post-menopausal',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                    child: Text(value, style: TextStyle(color: getInputText(context, Theme.of(context).brightness == Brightness.dark))),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _menopauseStage = newValue!;
                              });
                            },
                          ),
                              const SizedBox(height: 24),
                          
                          // Cyst Size
                          TextFormField(
                            controller: _cystSizeController,
                                style: TextStyle(color: getInputText(context, Theme.of(context).brightness == Brightness.dark), fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: 'Cyst Size (cm)',
                                  hintText: 'Enter cyst size in centimeters',
                                  labelStyle: TextStyle(color: getLabelText(context, Theme.of(context).brightness == Brightness.dark)),
                                  hintStyle: TextStyle(color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  prefixIcon: Icon(Icons.straighten, color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  filled: true,
                                  fillColor: getInputBg(context, Theme.of(context).brightness == Brightness.dark),
                              border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: getBorderColor(context, Theme.of(context).brightness == Brightness.dark)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter cyst size';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid size';
                              }
                              return null;
                            },
                          ),
                              const SizedBox(height: 24),
                          
                          // CA-125 Level
                          TextFormField(
                            controller: _ca125Controller,
                                style: TextStyle(color: getInputText(context, Theme.of(context).brightness == Brightness.dark), fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: 'CA-125 Level (U/mL)',
                                  hintText: 'Enter CA-125 level',
                                  labelStyle: TextStyle(color: getLabelText(context, Theme.of(context).brightness == Brightness.dark)),
                                  hintStyle: TextStyle(color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  prefixIcon: Icon(Icons.science, color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  filled: true,
                                  fillColor: getInputBg(context, Theme.of(context).brightness == Brightness.dark),
                              border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: getBorderColor(context, Theme.of(context).brightness == Brightness.dark)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter CA-125 level';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid level';
                              }
                              return null;
                            },
                          ),
                              const SizedBox(height: 24),
                          
                          // Cyst Growth
                          TextFormField(
                            controller: _cystGrowthController,
                                style: TextStyle(color: getInputText(context, Theme.of(context).brightness == Brightness.dark), fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: 'Cyst Growth (cm/month)',
                                  hintText: 'Enter growth rate per month',
                                  labelStyle: TextStyle(color: getLabelText(context, Theme.of(context).brightness == Brightness.dark)),
                                  hintStyle: TextStyle(color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  prefixIcon: Icon(Icons.trending_up, color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  filled: true,
                                  fillColor: getInputBg(context, Theme.of(context).brightness == Brightness.dark),
                              border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: getBorderColor(context, Theme.of(context).brightness == Brightness.dark)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter cyst growth';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid growth rate';
                              }
                              return null;
                            },
                          ),
                              const SizedBox(height: 24),
                          
                          // Ultrasound Features
                          DropdownButtonFormField<String>(
                            value: _ultrasoundFeatures,
                                style: TextStyle(color: getInputText(context, Theme.of(context).brightness == Brightness.dark), fontWeight: FontWeight.w600),
                                dropdownColor: getInputBg(context, Theme.of(context).brightness == Brightness.dark),
                                iconEnabledColor: colors.primary,
                            decoration: InputDecoration(
                              labelText: 'Ultrasound Features',
                                  labelStyle: TextStyle(color: getLabelText(context, Theme.of(context).brightness == Brightness.dark)),
                                  hintStyle: TextStyle(color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  prefixIcon: Icon(Icons.medical_services, color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  filled: true,
                                  fillColor: getInputBg(context, Theme.of(context).brightness == Brightness.dark),
                              border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: getBorderColor(context, Theme.of(context).brightness == Brightness.dark)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                            ),
                            items: [
                              'Simple cyst',
                              'Complex cyst',
                              'Solid mass',
                              'Hemorrhagic cyst',
                              'Septated cyst',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                    child: Text(value, style: TextStyle(color: getInputText(context, Theme.of(context).brightness == Brightness.dark))),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _ultrasoundFeatures = newValue!;
                              });
                            },
                          ),
                              const SizedBox(height: 24),
                          
                          // Symptoms
                          TextFormField(
                            onChanged: (value) {
                              _reportedSymptoms = value;
                            },
                                style: TextStyle(color: getInputText(context, Theme.of(context).brightness == Brightness.dark), fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: 'Reported Symptoms',
                              hintText: 'e.g., Pelvic pain, bloating, irregular periods',
                                  labelStyle: TextStyle(color: getLabelText(context, Theme.of(context).brightness == Brightness.dark)),
                                  hintStyle: TextStyle(color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  prefixIcon: Icon(Icons.healing, color: getHintText(context, Theme.of(context).brightness == Brightness.dark)),
                                  filled: true,
                                  fillColor: getInputBg(context, Theme.of(context).brightness == Brightness.dark),
                              border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: getBorderColor(context, Theme.of(context).brightness == Brightness.dark)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                            ),
                            maxLines: 3,
                          ),
                              const SizedBox(height: 32),
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                                height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitAssessment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                ),
                                    elevation: 8,
                                    shadowColor: colors.primary.withOpacity(0.25),
                              ),
                              child: _isLoading
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
                                              'Assessing Risk...',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.assessment,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                      'Assess Risk',
                                      style: TextStyle(
                                        color: Colors.white,
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
                  
                  // Results Section
                ],
              ),
            ),
          ),
        ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssessmentResult(Map<String, dynamic> result, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: colors.primary),
              const SizedBox(width: 12),
              Text(
                'Assessment Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Risk Level
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getRiskColor(result['risk_level']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getRiskColor(result['risk_level'])),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: _getRiskColor(result['risk_level']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Level: ${result['risk_level']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(result['risk_level']),
                        ),
                      ),
                      if (result['risk_factors'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Risk Factors:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        ...(result['risk_factors'] as List).map((factor) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text(
                            '• $factor',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.secondaryText,
                            ),
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Guidelines Compliance
          if (result['guidelines'] != null) ...[
            Text(
              'Guidelines Compliance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            ...result['guidelines'].entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          
          const SizedBox(height: 16),
          
          // Recommendations
          if (result['recommendations'] != null) ...[
            Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            ...result['recommendations'].entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Modern color helpers (override for white background)
  Color getInputBg(BuildContext context, bool isDark) => Colors.white;
  Color getInputText(BuildContext context, bool isDark) => Colors.black;
  Color getLabelText(BuildContext context, bool isDark) => Colors.grey[800]!;
  Color getHintText(BuildContext context, bool isDark) => Colors.grey[600]!;
  Color getBorderColor(BuildContext context, bool isDark) => Colors.grey[300]!;
}

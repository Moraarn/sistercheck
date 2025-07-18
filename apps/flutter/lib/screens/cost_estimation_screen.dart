import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';
import '../services/doctor_dashboard_service.dart';

class CostEstimationScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? patientData;
  
  const CostEstimationScreen({super.key, this.patientData});

  @override
  ConsumerState<CostEstimationScreen> createState() => _CostEstimationScreenState();
}

class _CostEstimationScreenState extends ConsumerState<CostEstimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _cystSizeController = TextEditingController();
  final _ca125Controller = TextEditingController();
  final _symptomsController = TextEditingController();
  
  String _treatmentType = 'Conservative';
  String _facilityType = 'Public';
  bool _hasInsurance = false;
  bool _isLoading = false;
  CostEstimation? _costEstimate;

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
    
    // Pre-fill form if patient data is provided
    if (widget.patientData != null) {
      _prefillForm();
    }
  }

  void _prefillForm() {
    final data = widget.patientData!;
    _ageController.text = data['Age']?.toString() ?? '';
    _cystSizeController.text = data['SI Cyst Size cm']?.toString() ?? '';
    _ca125Controller.text = data['fca 125 Level']?.toString() ?? '';
    _symptomsController.text = data['Reported Sym']?.toString() ?? '';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ageController.dispose();
    _cystSizeController.dispose();
    _ca125Controller.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _estimateCost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fix the data structure to match backend expectations
      final patientData = {
        'Age': int.parse(_ageController.text),
        'SI Cyst Size cm': double.parse(_cystSizeController.text), // Fixed field name
        'fca 125 Level': int.parse(_ca125Controller.text), // Fixed field name
        'Reported Sym': _symptomsController.text, // Fixed field name
        'Cyst Growth': 0.0, // Add missing required field
        'Menopause Stage': 'Pre-menopausal', // Add missing required field
        'Ultrasound Fe': 'Simple cyst', // Add missing required field
        'Treatment Type': _treatmentType,
        'Facility Type': _facilityType,
      };

      final result = await ref.read(doctorDashboardServiceProvider).getCostEstimation(patientData);

      if (result['success']) {
        setState(() {
          _costEstimate = result['cost_estimation'];
        });
        
        // Show popup with cost estimation results
        _showCostEstimationPopup(result['cost_estimation'], result['recommended_treatment']);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cost estimation completed'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to estimate cost'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCostEstimationPopup(CostEstimation costEstimate, String recommendedTreatment) {
    final colors = ref.watch(themeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header - Fixed at top
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: colors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cost Estimation Results',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: colors.secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Scrollable Content
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recommended Treatment
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.primary),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.medical_services, color: colors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Recommended: $recommendedTreatment',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colors.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Total Cost
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.primary),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Estimated Cost',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colors.text,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${costEstimate.currency} ${costEstimate.riskAdjustedCost.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Base Cost: ${costEstimate.currency} ${costEstimate.baseCost.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Additional Costs
                          if (costEstimate.additionalCosts.isNotEmpty) ...[
                            Text(
                              'Additional Costs',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...costEstimate.additionalCosts.entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.key.replaceAll('_', ' ').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colors.text,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${costEstimate.currency} ${entry.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                            const SizedBox(height: 16),
                          ],
                          
                          // Financing Options
                          if (costEstimate.financingOptions.isNotEmpty) ...[
                            Text(
                              'Financing Options',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...costEstimate.financingOptions.entries.map((entry) {
                              final option = entry.value as Map<String, dynamic>;
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colors.inputFieldBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key.replaceAll('_', ' ').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      option['description'] ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colors.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Amount: ${costEstimate.currency} ${option['amount']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Close Button - Fixed at bottom
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          'Cost Estimation',
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 48,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Treatment Cost Estimation',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Estimate treatment costs based on patient data and facility type',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Patient Data Form
                  Container(
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Age
                          TextFormField(
                            controller: _ageController,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Age',
                              labelStyle: TextStyle(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(Icons.person, color: colors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              filled: true,
                              fillColor: colors.card,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          const SizedBox(height: 16),
                          
                          // Cyst Size
                          TextFormField(
                            controller: _cystSizeController,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Cyst Size (cm)',
                              labelStyle: TextStyle(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(Icons.straighten, color: colors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              filled: true,
                              fillColor: colors.card,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          const SizedBox(height: 16),
                          
                          // CA-125 Level
                          TextFormField(
                            controller: _ca125Controller,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'CA-125 Level (U/mL)',
                              labelStyle: TextStyle(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(Icons.science, color: colors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              filled: true,
                              fillColor: colors.card,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          const SizedBox(height: 16),
                          
                          // Symptoms
                          TextFormField(
                            controller: _symptomsController,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Symptoms',
                              labelStyle: TextStyle(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: 'e.g., Pelvic pain, bloating, irregular periods',
                              hintStyle: TextStyle(
                                color: colors.secondaryText.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(Icons.healing, color: colors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              filled: true,
                              fillColor: colors.card,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter symptoms';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Treatment Type
                          DropdownButtonFormField<String>(
                            value: _treatmentType,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Treatment Type',
                              labelStyle: TextStyle(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(Icons.medical_services, color: colors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              filled: true,
                              fillColor: colors.card,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            items: [
                              'Conservative',
                              'Surgical',
                              'Minimally Invasive',
                              'Emergency',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: colors.text,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _treatmentType = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Facility Type
                          DropdownButtonFormField<String>(
                            value: _facilityType,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Facility Type',
                              labelStyle: TextStyle(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(Icons.local_hospital, color: colors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.border, width: 1.5),
                              ),
                              filled: true,
                              fillColor: colors.card,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            items: [
                              'Public',
                              'Private',
                              'Mission',
                              'Specialized',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: colors.text,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _facilityType = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Insurance
                          // SwitchListTile(
                          //   title: Text(
                          //     'Has Insurance',
                          //     style: TextStyle(
                          //       color: colors.text,
                          //       fontSize: 16,
                          //     ),
                          //   ),
                          //   subtitle: Text(
                          //     'Patient has health insurance coverage',
                          //     style: TextStyle(
                          //       color: colors.secondaryText,
                          //       fontSize: 14,
                          //     ),
                          //   ),
                          //   value: _hasInsurance,
                          //   onChanged: (bool value) {
                          //     setState(() {
                          //       _hasInsurance = value;
                          //     });
                          //   },
                          //   activeColor: colors.primary,
                          // ),
                          
                          // const SizedBox(height: 24),
                          
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _estimateCost,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Estimating...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Estimate Cost',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Cost Estimate Results
                  if (_costEstimate != null) ...[
                    const SizedBox(height: 24),
                    _buildCostEstimate(_costEstimate!, colors),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCostEstimate(CostEstimation estimate, AppColors colors) {
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
              Icon(Icons.calculate, color: colors.primary),
              const SizedBox(width: 12),
              Text(
                'Cost Estimate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Service Name
          if (estimate.serviceName.isNotEmpty) ...[
            Text(
              'Service: ${estimate.serviceName}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Risk Adjusted Cost
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Estimated Cost',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${estimate.currency} ${estimate.riskAdjustedCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Base Cost: ${estimate.currency} ${estimate.baseCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Additional Costs
          if (estimate.additionalCosts.isNotEmpty) ...[
            Text(
              'Additional Costs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 12),
            ...estimate.additionalCosts.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.text,
                    ),
                  ),
                  Text(
                    '${estimate.currency} ${entry.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            )).toList(),
          const SizedBox(height: 16),
          ],
          
          // Financing Options
          if (estimate.financingOptions.isNotEmpty) ...[
            Text(
              'Financing Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 12),
            ...estimate.financingOptions.entries.map((entry) {
              final option = entry.value as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.inputFieldBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      entry.key.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                    ),
                  ),
                    const SizedBox(height: 4),
                    Text(
                      option['description'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Amount: ${estimate.currency} ${option['amount']?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                    ),
                  ),
                ],
              ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}

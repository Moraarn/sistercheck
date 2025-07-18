import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';
import '../services/doctor_dashboard_service.dart';
import '../services/patient_auth_service.dart';
import '../plugins/network_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'cost_estimation_screen.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  String _searchQuery = '';
  final String _searchType = 'id'; // 'id' or 'region'

  List<Patient> _patients = [];
  String? _selectedFileName;

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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
    _loadPatients();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ref
          .read(doctorDashboardServiceProvider)
          .getPatients(page: _currentPage, limit: 10);

      if (result['success']) {
        setState(() {
          _patients = result['patients'] ?? [];
          _totalPages = (result['total'] / 10).ceil();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load patients'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading patients: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _searchPatients() async {
    if (_searchQuery.isEmpty) {
      _loadPatients();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ref
          .read(doctorDashboardServiceProvider)
          .searchPatients(query: _searchQuery, type: _searchType);

      if (result['success']) {
        setState(() {
          _patients = result['patients'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to search patients'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching patients: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onPatientTap(Patient patient) {
    _showPatientDetailsModal(patient);
  }

  void _showPatientDetailsModal(Patient patient) {
    final colors = ref.read(themeProvider) == ThemeMode.dark
        ? AppColors.dark
        : AppColors.light;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: colors.card.withOpacity(0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: colors.primary, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Patient ${patient.id}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: colors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${patient.age} years',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.secondaryText,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Icon(
                          Icons.location_on,
                          color: colors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          patient.region,
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (patient.cystSize != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.straighten,
                            color: colors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Cyst: ${patient.cystSize}cm',
                            style: TextStyle(
                              fontSize: 16,
                              color: colors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (patient.ca125Level != null) ...[
                      Row(
                        children: [
                          Icon(Icons.science, color: colors.primary, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'CA-125: ${patient.ca125Level}',
                            style: TextStyle(
                              fontSize: 16,
                              color: colors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (patient.riskLevel.isNotEmpty &&
                        patient.riskLevel != 'Unknown') ...[
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: _getRiskColor(patient.riskLevel),
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Risk: ${patient.riskLevel}',
                            style: TextStyle(
                              fontSize: 16,
                              color: _getRiskColor(patient.riskLevel),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (patient.previousRecommendation != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.recommend,
                            color: colors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Recommendation: ${patient.previousRecommendation}',
                              style: TextStyle(
                                fontSize: 16,
                                color: colors.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Add more fields as needed
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showCarePlanModal(patient),
                            icon: Icon(Icons.assignment, color: Colors.white),
                            label: Text('View Care Plan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCarePlanModal(Patient patient) async {
    final colors = ref.read(themeProvider) == ThemeMode.dark
        ? AppColors.dark
        : AppColors.light;
    // Fetch care template from backend
    final result = await ref
        .read(doctorDashboardServiceProvider)
        .getPatientCareTemplate(patient.id);
    final careTemplate = result['success'] ? result['care_template'] : null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: colors.card.withOpacity(0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: careTemplate == null
                    ? Center(
                        child: Text(
                          'No care template found for this patient.',
                          style: TextStyle(color: colors.secondaryText),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Care Template',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._buildCareTemplateSections(careTemplate, colors),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCareTemplateSections(
    dynamic careTemplate,
    AppColors colors,
  ) {
    // Show all available maps in the CareTemplate
    final List<Widget> sections = [];
    final sectionMap = {
      'Patient Summary': careTemplate.patientSummary,
      'AI Recommendation': careTemplate.aiRecommendation,
      'Treatment Protocol': careTemplate.treatmentProtocol,
      'Follow Up Plan': careTemplate.followUpPlan,
      'Cost Estimation': careTemplate.costEstimation,
      'Inventory Status': careTemplate.inventoryStatus,
      'Kenyan Guidelines Compliance': careTemplate.kenyanGuidelinesCompliance,
      'Comparison': careTemplate.comparison,
    };
    sectionMap.forEach((title, map) {
      if (map != null && map is Map && map.isNotEmpty) {
        sections.add(
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
        );
        sections.add(const SizedBox(height: 8));
        sections.addAll(
          map.entries.map<Widget>(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: colors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: TextStyle(fontSize: 15, color: colors.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        sections.add(const SizedBox(height: 16));
      }
    });
    if (sections.isEmpty) {
      sections.add(
        Text(
          'No care template details available.',
          style: TextStyle(color: colors.secondaryText),
        ),
      );
    }
    return sections;
  }

  void _showAddPatientDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPatientDialog(
        onPatientAdded: () {
          _loadPatients(); // Refresh the list
        },
      ),
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
          'Patients',
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file, color: colors.primary),
            tooltip: 'Upload Dataset',
            onPressed: _showFileUploadDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPatientDialog,
        icon: Icon(Icons.person_add),
        label: Text('Add Patient'),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  colors.primary.withOpacity(0.08),
                  colors.scaffoldBackground,
                ],
              ),
            ),
            child: Column(
              children: [
                // Modern search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(24),
                    color: colors.card.withOpacity(0.9),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search patients by name, ID, or region...',
                        hintStyle: TextStyle(
                          color: colors.secondaryText.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(Icons.search, color: colors.primary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: colors.secondaryText,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _loadPatients();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                        if (value.isEmpty) {
                          _searchQuery = '';
                          _loadPatients();
                        }
                      },
                      onSubmitted: (value) {
                        _searchQuery = value;
                        _searchPatients();
                      },
                    ),
                  ),
                ),
                // Patients table
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colors.primary,
                                ),
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Loading patients...',
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please wait while we fetch your patient data',
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _patients.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 80,
                                color: colors.primary.withOpacity(0.6),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No patients found for "$_searchQuery"'
                                    : 'No patients found',
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Try adjusting your search criteria or check spelling'
                                    : 'Add your first patient to get started with risk assessment',
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_searchQuery.isEmpty) ...[
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _showAddPatientDialog,
                                  icon: Icon(Icons.person_add),
                                  label: Text('Add First Patient'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _patients.length,
                          itemBuilder: (context, index) {
                            final patient = _patients[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
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
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _onPatientTap(patient),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
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
                                                    'Patient ${patient.id}',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: colors.text,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_today,
                                                        color: colors.secondaryText,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${patient.age} years',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: colors.secondaryText,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Icon(
                                                        Icons.location_on,
                                                        color: colors.secondaryText,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        patient.region,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: colors.secondaryText,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (patient.riskLevel.isNotEmpty && patient.riskLevel != 'Unknown')
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal:8),
                                                decoration: BoxDecoration(
                                                  color: _getRiskColor(patient.riskLevel).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: _getRiskColor(patient.riskLevel).withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  patient.riskLevel,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getRiskColor(patient.riskLevel),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            if (patient.cystSize != null) ...[
                                              _buildInfoChip(
                                                Icons.straighten,
                                                'Cyst: ${patient.cystSize}cm',
                                                colors,
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            if (patient.ca125Level != null) ...[
                                              _buildInfoChip(
                                                Icons.science,
                                                'CA-125: ${patient.ca125Level}',
                                                colors,
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () => _showCarePlanModal(patient),
                                                icon: Icon(Icons.assignment, size: 16),
                                                label: Text('Care Plan'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: colors.primary,
                                                  side: BorderSide(color: colors.primary),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _showPatientDetailsModal(patient),
                                                icon: Icon(Icons.info_outline, size: 16),
                                                label: Text('Details'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: colors.primary,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                ),
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
                        ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildInfoChip(IconData icon, String text, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: colors.primary,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: colors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFileUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFileUploadDialog(),
    );
  }

  Widget _buildFileUploadDialog() {
    final colors = ref.watch(themeProvider) == ThemeMode.dark
        ? AppColors.dark
        : AppColors.light;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: colors.scaffoldBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.upload_file,
                    color: colors.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Dataset',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Upload Excel or PDF files to enhance AI training',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: colors.secondaryText),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File type selection
                  Text(
                    'Supported File Types',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Excel option
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.table_chart, color: Colors.green),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Excel Files (.xlsx, .xls)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.text,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Patient data with columns: Age, Cyst Size, CA-125, Symptoms',
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
                  SizedBox(height: 12),
                  // PDF option
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.picture_as_pdf, color: Colors.red),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PDF Files (.pdf)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.text,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Medical reports and clinical documentation',
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
                  SizedBox(height: 24),
                  // File requirements
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colors.primary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'File Requirements',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildRequirementItem(
                          'Maximum file size: 50MB',
                          colors,
                        ),
                        _buildRequirementItem(
                          'Excel: Patient data with proper headers',
                          colors,
                        ),
                        _buildRequirementItem(
                          'PDF: Medical reports and clinical notes',
                          colors,
                        ),
                        _buildRequirementItem(
                          'Data will be used to improve AI accuracy',
                          colors,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Upload button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _uploadFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: colors.primary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file),
                          SizedBox(width: 8),
                          Text(
                            'Browse & Upload File',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: colors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
        });

        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(child: Text('Uploading file...')),
              ],
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Upload file to Python backend
        final response = await ref.read(networkProvider).uploadFileToPython(
          path: '/upload-dataset',
          filePath: result.files.single.path!,
          fileName: result.files.single.name,
          additionalFields: {
            'file_type': result.files.single.extension ?? 'unknown',
            'upload_timestamp': DateTime.now().toIso8601String(),
          },
        );

        if (response.success) {
          // Show success message with data summary
          final uploadedData = response.data;
          String message = 'Dataset uploaded successfully!';
          
          if (uploadedData != null) {
            final processedRecords = uploadedData['processed_records'] ?? 0;
            final totalRecords = uploadedData['total_records'] ?? 0;
            final fileType = uploadedData['file_type'] ?? 'Unknown';
            
            message = 'Uploaded $fileType file with $processedRecords/$totalRecords records processed';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: 'View Data',
                textColor: Colors.white,
                onPressed: () => _showUploadedDataDialog(response.data),
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text(response.message ?? 'Upload failed')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        // User canceled the picker, do nothing
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Error uploading file: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showUploadedDataDialog(Map<String, dynamic>? uploadedData) {
    final colors = ref.read(themeProvider) == ThemeMode.dark
        ? AppColors.dark
        : AppColors.light;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.upload_file, color: colors.primary),
              SizedBox(width: 12),
              Text(
                'Uploaded Data Summary',
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (uploadedData != null) ...[
                  _buildDataRow('File Type', uploadedData['file_type'] ?? 'Unknown', colors),
                  _buildDataRow('Total Records', '${uploadedData['total_records'] ?? 0}', colors),
                  _buildDataRow('Processed Records', '${uploadedData['processed_records'] ?? 0}', colors),
                  _buildDataRow('Failed Records', '${uploadedData['failed_records'] ?? 0}', colors),
                  if (uploadedData['sample_data'] != null) ...[
                    SizedBox(height: 16),
                    Text(
                      'Sample Data:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        uploadedData['sample_data'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.secondaryText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  Text(
                    'No data available',
                    style: TextStyle(color: colors.secondaryText),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: colors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataRow(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// Add Patient Dialog
class AddPatientDialog extends ConsumerStatefulWidget {
  final VoidCallback onPatientAdded;

  const AddPatientDialog({super.key, required this.onPatientAdded});

  @override
  ConsumerState<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends ConsumerState<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _regionController = TextEditingController();
  final _cystSizeController = TextEditingController();
  final _ca125Controller = TextEditingController();
  final _symptomsController = TextEditingController();

  String _menopauseStage = 'Pre-menopausal';
  String _ultrasoundFeatures = 'Simple cyst';
  bool _isLoading = false;

  @override
  void dispose() {
    _ageController.dispose();
    _regionController.dispose();
    _cystSizeController.dispose();
    _ca125Controller.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _addPatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First, create the patient data for prediction
      final patientData = {
        'Age': int.parse(_ageController.text),
        'Menopause Stage': _menopauseStage,
        'SI Cyst Size cm': double.parse(_cystSizeController.text),
        'Cyst Growth': 0.0, // Default value
        'fca 125 Level': int.parse(_ca125Controller.text),
        'Ultrasound Fe': _ultrasoundFeatures,
        'Reported Sym': _symptomsController.text,
      };

      // Save patient to Node.js backend
      final patientAuthService = ref.read(PatientAuthService.provider);
      final saveResult = await patientAuthService.savePatientToNodeJS(
        patientData: {
          'age': int.parse(_ageController.text),
          'region': _regionController.text,
          'cyst_size': double.parse(_cystSizeController.text),
          'ca125_level': int.parse(_ca125Controller.text),
          'symptoms': _symptomsController.text,
          'menopause_stage': _menopauseStage,
          'ultrasound_features': _ultrasoundFeatures,
          'name': 'Patient ${DateTime.now().millisecondsSinceEpoch}', // Generate a unique name
        },
      );

      if (saveResult['success']) {
        // Get risk assessment from Python backend
        final riskResult = await ref
            .read(doctorDashboardServiceProvider)
            .createRiskAssessment(patientData);

        // Get cost estimation using the same patient data
        final costResult = await ref
            .read(doctorDashboardServiceProvider)
            .getCostEstimation(patientData);

        // Show risk assessment popup with the results
        _showRiskAssessmentPopup(
          riskResult['success'] ? riskResult['risk_assessment'] : {},
          costResult['success'] ? costResult['cost_estimation'] : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Patient added successfully with risk assessment'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
        widget.onPatientAdded();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saveResult['message'] ?? 'Failed to add patient'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showRiskAssessmentPopup(
    Map<String, dynamic> riskAssessment,
    CostEstimation? costEstimation,
  ) {
    final colors = ref.read(themeProvider) == ThemeMode.dark
        ? AppColors.dark
        : AppColors.light;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Risk Level Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getRiskColor(
                      riskAssessment['risk_level'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    size: 40,
                    color: _getRiskColor(riskAssessment['risk_level']),
                  ),
                ),
                const SizedBox(height: 16),

                // Risk Level Title
                Text(
                  'Risk Assessment Complete',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Risk Level
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getRiskColor(
                      riskAssessment['risk_level'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getRiskColor(riskAssessment['risk_level']),
                    ),
                  ),
                  child: Text(
                    'Risk Level: ${riskAssessment['risk_level']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getRiskColor(riskAssessment['risk_level']),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Risk Factors
                if ((riskAssessment['risk_factors'] as List?)?.isNotEmpty ==
                    true) ...[
                  Text(
                    'Risk Factors:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(riskAssessment['risk_factors'] as List).map(
                    (factor) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: _getRiskColor(riskAssessment['risk_level']),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Cost Estimation Summary
                if (costEstimation != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: colors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Estimated Cost',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${costEstimation.currency} ${costEstimation.riskAdjustedCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Base Cost: ${costEstimation.currency} ${costEstimation.baseCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Close',
                          style: TextStyle(color: colors.secondaryText),
                        ),
                      ),
                    ),
                    if (costEstimation != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CostEstimationScreen(
                                  patientData: {
                                    'Age': int.parse(_ageController.text),
                                    'Menopause Stage': _menopauseStage,
                                    'SI Cyst Size cm': double.parse(
                                      _cystSizeController.text,
                                    ),
                                    'Cyst Growth': 0.0,
                                    'fca 125 Level': int.parse(
                                      _ca125Controller.text,
                                    ),
                                    'Ultrasound Fe': _ultrasoundFeatures,
                                    'Reported Sym': _symptomsController.text,
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('View Full Cost'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider) == ThemeMode.dark
        ? AppColors.dark
        : AppColors.light;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.scaffoldBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.person_add, color: colors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Add New Patient',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: colors.secondaryText),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name

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
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: colors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: colors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
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

                    // Region
                    TextFormField(
                      controller: _regionController,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Region',
                        labelStyle: TextStyle(
                          color: colors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: colors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: colors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter region';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Medical Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
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
                        prefixIcon: Icon(
                          Icons.straighten,
                          color: colors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: colors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
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
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: colors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
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

                    // Menopause Stage
                    DropdownButtonFormField<String>(
                      value: _menopauseStage,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Menopause Stage',
                        labelStyle: TextStyle(
                          color: colors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.woman, color: colors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: colors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items:
                          [
                            'Pre-menopausal',
                            'Peri-menopausal',
                            'Post-menopausal',
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
                          _menopauseStage = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ultrasound Features
                    DropdownButtonFormField<String>(
                      value: _ultrasoundFeatures,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Ultrasound Features',
                        labelStyle: TextStyle(
                          color: colors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.medical_services,
                          color: colors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: colors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items:
                          [
                            'Simple cyst',
                            'Complex cyst',
                            'Solid mass',
                            'Hemorrhagic cyst',
                            'Septated cyst',
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
                          _ultrasoundFeatures = newValue!;
                        });
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
                        hintText:
                            'e.g., Pelvic pain, bloating, irregular periods',
                        hintStyle: TextStyle(
                          color: colors.secondaryText.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(Icons.healing, color: colors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: colors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter symptoms';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addPatient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Add Patient',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Upload Excel Dialog
class UploadExcelDialog extends ConsumerStatefulWidget {
  final VoidCallback onUploadComplete;

  const UploadExcelDialog({super.key, required this.onUploadComplete});

  @override
  ConsumerState<UploadExcelDialog> createState() => _UploadExcelDialogState();
}

class _UploadExcelDialogState extends ConsumerState<UploadExcelDialog> {
  bool _isUploading = false;

  Future<void> _uploadExcelFile() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Simulate file upload - in real implementation, you would use file_picker
      // and send the file to your backend
      await Future.delayed(Duration(seconds: 2));

      // Mock successful upload
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel file uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
      widget.onUploadComplete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider) == ThemeMode.dark
        ? AppColors.dark
        : AppColors.light;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.upload_file, color: colors.primary),
          const SizedBox(width: 12),
          Text(
            'Upload Excel File',
            style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload patient data from Excel file',
            style: TextStyle(color: colors.text, fontSize: 16),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Excel File Requirements:',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• File format: .xlsx\n'
                  '• Columns: Name, Age, Region, Cyst Size, CA-125 Level, Symptoms\n'
                  '• Maximum 1000 patients per file\n'
                  '• File size: < 10MB',
                  style: TextStyle(color: colors.secondaryText, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Note: The system will automatically assess risk for each patient based on the uploaded data.',
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: colors.secondaryText)),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadExcelFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isUploading
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Upload File'),
        ),
      ],
    );
  }
}

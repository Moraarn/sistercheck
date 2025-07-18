import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistercheck/plugins/network_provider.dart';
import 'package:sistercheck/plugins/app_provider.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String region;
  final String? ca125Level;
  final double? cystSize;
  final String? dateOfExam;
  final String? previousRecommendation;
  final List<String> riskFactors;
  final String riskLevel;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.region,
    this.ca125Level,
    this.cystSize,
    this.dateOfExam,
    this.previousRecommendation,
    required this.riskFactors,
    required this.riskLevel,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['patient_id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      region: json['region'] ?? '',
      ca125Level: json['ca125_level']?.toString(),
      cystSize: json['cyst_size']?.toDouble(),
      dateOfExam: json['date_of_exam'],
      previousRecommendation: json['previous_recommendation'],
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
      riskLevel: json['risk_level'] ?? 'Unknown',
    );
  }
}

class CareTemplate {
  final String patientId;
  final Map<String, dynamic> patientSummary;
  final Map<String, dynamic> aiRecommendation;
  final Map<String, dynamic> treatmentProtocol;
  final Map<String, dynamic> followUpPlan;
  final Map<String, dynamic> costEstimation;
  final Map<String, dynamic> inventoryStatus;
  final Map<String, dynamic> kenyanGuidelinesCompliance;
  final Map<String, dynamic> comparison;
  final DateTime timestamp;

  CareTemplate({
    required this.patientId,
    required this.patientSummary,
    required this.aiRecommendation,
    required this.treatmentProtocol,
    required this.followUpPlan,
    required this.costEstimation,
    required this.inventoryStatus,
    required this.kenyanGuidelinesCompliance,
    required this.comparison,
    required this.timestamp,
  });

  factory CareTemplate.fromJson(Map<String, dynamic> json) {
    return CareTemplate(
      patientId: json['patient_id'] ?? '',
      patientSummary: json['patient_summary'] ?? {},
      aiRecommendation: json['ai_recommendation'] ?? {},
      treatmentProtocol: json['treatment_protocol'] ?? {},
      followUpPlan: json['follow_up_plan'] ?? {},
      costEstimation: json['cost_estimation'] ?? {},
      inventoryStatus: json['inventory_status'] ?? {},
      kenyanGuidelinesCompliance: json['kenyan_guidelines_compliance'] ?? {},
      comparison: json['comparison'] ?? {},
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class CostEstimation {
  final String serviceName;
  final double baseCost;
  final double riskAdjustedCost;
  final String currency;
  final Map<String, dynamic> additionalCosts;
  final Map<String, dynamic> financingOptions;
  final DateTime timestamp;

  CostEstimation({
    required this.serviceName,
    required this.baseCost,
    required this.riskAdjustedCost,
    required this.currency,
    required this.additionalCosts,
    required this.financingOptions,
    required this.timestamp,
  });

  factory CostEstimation.fromJson(Map<String, dynamic> json) {
    return CostEstimation(
      serviceName: json['service_name'] ?? '',
      baseCost: (json['base_cost'] ?? 0).toDouble(),
      riskAdjustedCost: (json['risk_adjusted_cost'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'KES',
      additionalCosts: json['additional_costs'] ?? {},
      financingOptions: json['financing_options'] ?? {},
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class InventoryItem {
  final String item;
  final int stock;
  final String unit;
  final String status; // 'available', 'low_stock', 'out_of_stock'
  final String? note;
  final DateTime? estimatedRestock;

  InventoryItem({
    required this.item,
    required this.stock,
    required this.unit,
    required this.status,
    this.note,
    this.estimatedRestock,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      item: json['item'] ?? '',
      stock: json['stock'] ?? 0,
      unit: json['unit'] ?? '',
      status: json['status'] ?? 'unknown',
      note: json['note'],
      estimatedRestock: json['estimated_restock'] != null 
          ? DateTime.parse(json['estimated_restock']) 
          : null,
    );
  }
}

class DoctorDashboardService {
  final NetworkProvider _networkProvider;
  final AppNotifier _appNotifier;

  DoctorDashboardService(this._networkProvider, this._appNotifier);

  /// Get all patients with pagination
  Future<Map<String, dynamic>> getPatients({int page = 1, int limit = 10}) async {
    try {
      if (!_appNotifier.state.isAuthenticated && !_appNotifier.state.isPatientAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to access patient data',
        };
      }

      final response = await _networkProvider.getFromPython('/patients?page=$page&limit=$limit');

      if (response.success && response.data != null) {
        final patientsData = response.data!['patients'] as List;
        final patients = patientsData
            .map((patient) => Patient.fromJson(patient))
            .toList();

        return {
          'success': true,
          'patients': patients,
          'total': response.data!['total'] ?? 0,
          'page': response.data!['page'] ?? 1,
          'limit': response.data!['limit'] ?? 10,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to get patients',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting patients: $e',
      };
    }
  }

  /// Search patients by query and type
  Future<Map<String, dynamic>> searchPatients({
    required String query,
    required String type, // 'id' or 'region'
  }) async {
    try {
      if (!_appNotifier.state.isAuthenticated && !_appNotifier.state.isPatientAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to search patients',
        };
      }

      final response = await _networkProvider.getFromPython('/search-patients?q=$query&type=$type');

      if (response.success && response.data != null) {
        final patientsData = response.data!['patients'] as List;
        final patients = patientsData
            .map((patient) => Patient.fromJson(patient))
            .toList();

        return {
          'success': true,
          'patients': patients,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to search patients',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error searching patients: $e',
      };
    }
  }

  /// Get care template for a specific patient
  Future<Map<String, dynamic>> getPatientCareTemplate(String patientId) async {
    try {
      if (!_appNotifier.state.isAuthenticated && !_appNotifier.state.isPatientAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to access care templates',
        };
      }

      final response = await _networkProvider.getFromPython('/patient/$patientId/care-template');

      if (response.success && response.data != null) {
        final careTemplate = CareTemplate.fromJson(response.data!['care_template']);
        return {
          'success': true,
          'care_template': careTemplate,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to get care template',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting care template: $e',
      };
    }
  }

  /// Create enhanced prediction with risk assessment
  Future<Map<String, dynamic>> createPrediction(Map<String, dynamic> patientData) async {
    try {
      if (!_appNotifier.state.isAuthenticated && !_appNotifier.state.isPatientAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to create predictions',
        };
      }

      final response = await _networkProvider.submitToPython(
        method: HttpMethod.post,
        path: '/predict',
        body: patientData,
      );

      if (response.success && response.data != null) {
        return {
          'success': true,
          'prediction': response.data!,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to create prediction',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating prediction: $e',
      };
    }
  }

  /// Create complete intelligent care template
  Future<Map<String, dynamic>> createCareTemplate(Map<String, dynamic> patientData) async {
    try {
      if (!_appNotifier.state.isAuthenticated && !_appNotifier.state.isPatientAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to create care templates',
        };
      }

      final response = await _networkProvider.submitToPython(
        method: HttpMethod.post,
        path: '/care-template',
        body: patientData,
      );

      if (response.success && response.data != null) {
        final careTemplate = CareTemplate.fromJson(response.data!['care_template']);
        return {
          'success': true,
          'care_template': careTemplate,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to create care template',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating care template: $e',
      };
    }
  }

  /// Create risk assessment based on guidelines
  Future<Map<String, dynamic>> createRiskAssessment(Map<String, dynamic> patientData) async {
    try {
      if (!_appNotifier.state.isAuthenticated && !_appNotifier.state.isPatientAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to create risk assessments',
        };
      }

      final response = await _networkProvider.submitToPython(
        method: HttpMethod.post,
        path: '/risk-assessment',
        body: patientData,
      );

      if (response.success && response.data != null) {
        // Return the raw response data instead of trying to parse it as RiskAssessment object
        return {
          'success': true,
          'risk_assessment': response.data!['risk_assessment'],
          'guidelines_reference': response.data!['guidelines_reference'],
          'timestamp': response.data!['timestamp'],
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to create risk assessment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating risk assessment: $e',
      };
    }
  }

  /// Get detailed cost analysis
  Future<Map<String, dynamic>> getCostEstimation(Map<String, dynamic> patientData) async {
    try {
      if (!_appNotifier.state.isAuthenticated && !_appNotifier.state.isPatientAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to get cost estimations',
        };
      }

      final response = await _networkProvider.submitToPython(
        method: HttpMethod.post,
        path: '/cost-estimation',
        body: patientData,
      );

      if (response.success && response.data != null) {
        // Handle the backend response structure correctly
        final costEstimationData = response.data!['cost_estimation'];
        final costEstimation = CostEstimation.fromJson(costEstimationData);
        
        return {
          'success': true,
          'cost_estimation': costEstimation,
          'recommended_treatment': response.data!['recommended_treatment'],
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to get cost estimation',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting cost estimation: $e',
      };
    }
  }

  /// Get real-time inventory check
  Future<Map<String, dynamic>> getInventoryStatus(Map<String, dynamic> patientData) async {
    try {
      if (!_appNotifier.state.isAuthenticated && !_appNotifier.state.isPatientAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to check inventory',
        };
      }

      final response = await _networkProvider.submitToPython(
        method: HttpMethod.post,
        path: '/inventory-status',
        body: patientData,
      );

      if (response.success && response.data != null) {
        final inventoryData = response.data!['inventory_status'];
        final available = (inventoryData['available'] as List?)
            ?.map((item) => InventoryItem.fromJson(item))
            .toList() ?? [];
        final lowStock = (inventoryData['low_stock'] as List?)
            ?.map((item) => InventoryItem.fromJson(item))
            .toList() ?? [];
        final outOfStock = (inventoryData['out_of_stock'] as List?)
            ?.map((item) => InventoryItem.fromJson(item))
            .toList() ?? [];

        return {
          'success': true,
          'recommended_treatment': response.data!['recommended_treatment'],
          'available': available,
          'low_stock': lowStock,
          'out_of_stock': outOfStock,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to get inventory status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting inventory status: $e',
      };
    }
  }

  /// Estimate treatment cost
  Future<Map<String, dynamic>> estimateCost(Map<String, dynamic> patientData) async {
    try {
      if (!_appNotifier.state.isAuthenticated && !_appNotifier.state.isPatientAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to estimate costs',
        };
      }

      final response = await _networkProvider.submitToPython(
        method: HttpMethod.post,
        path: '/cost-estimation',
        body: patientData,
      );

      if (response.success && response.data != null) {
        return {
          'success': true,
          'cost_estimate': response.data!['cost_estimate'],
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to estimate cost',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error estimating cost: $e',
      };
    }
  }

  /// Upload dataset file (Excel or PDF) to Python backend
  Future<Map<String, dynamic>> uploadDataset({
    required String filePath,
    required String fileName,
  }) async {
    try {
      if (!_appNotifier.state.isAuthenticated && !_appNotifier.state.isPatientAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to upload files',
        };
      }

      // In a real implementation, you would use FormData to upload files
      // For now, we'll simulate the upload with file metadata
      final fileData = {
        'file_path': filePath,
        'file_name': fileName,
        'file_type': fileName.split('.').last.toLowerCase(),
        'upload_timestamp': DateTime.now().toIso8601String(),
      };

      final response = await _networkProvider.submitToPython(
        method: HttpMethod.post,
        path: '/upload-dataset',
        body: fileData,
      );

      if (response.success && response.data != null) {
        return {
          'success': true,
          'upload_result': response.data!['upload_result'],
          'message': 'Dataset uploaded successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to upload dataset',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error uploading dataset: $e',
      };
    }
  }
}

// Provider for DoctorDashboardService
final doctorDashboardServiceProvider = Provider<DoctorDashboardService>((ref) {
  final network = ref.watch(networkProvider);
  final appNotifier = ref.watch(appNotifierProvider.notifier);
  return DoctorDashboardService(network, appNotifier);
});

// Provider for patients list
final patientsProvider = FutureProvider.family<Map<String, dynamic>, Map<String, int>>((ref, params) async {
  final service = ref.watch(doctorDashboardServiceProvider);
  return await service.getPatients(page: params['page'] ?? 1, limit: params['limit'] ?? 10);
});

// Provider for inventory status
final inventoryStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(doctorDashboardServiceProvider);
  // Provide default/sample patient data
  final samplePatientData = {
    'Age': 35,
    'Menopause Stage': 'Pre-menopausal',
    'SI Cyst Size cm': 6.5,
    'Cyst Growth': 0.2,
    'fca 125 Level': 45,
    'Ultrasound Fe': 'Complex cyst',
    'Reported Sym': 'Pelvic pain, bloating'
  };
  return await service.getInventoryStatus(samplePatientData);
}); 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/network_provider.dart';

class CareTemplate {
  final String id;
  final String userId;
  final String? symptomId;
  final String? riskAssessmentId;
  final Map<String, dynamic> patientData;
  final Map<String, dynamic> prediction;
  final Map<String, dynamic> carePlan;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CareTemplate({
    required this.id,
    required this.userId,
    this.symptomId,
    this.riskAssessmentId,
    required this.patientData,
    required this.prediction,
    required this.carePlan,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CareTemplate.fromJson(Map<String, dynamic> json) {
    return CareTemplate(
      id: json['_id'],
      userId: json['userId'],
      symptomId: json['symptomId'],
      riskAssessmentId: json['riskAssessmentId'],
      patientData: json['patientData'] ?? {},
      prediction: json['prediction'] ?? {},
      carePlan: json['carePlan'] ?? {},
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class CareTemplateService {
  final NetworkProvider _networkProvider;

  CareTemplateService(this._networkProvider);

  Future<Map<String, dynamic>> createCareTemplate({
    required String token,
    String? symptomId,
    String? riskAssessmentId,
    required Map<String, dynamic> patientData,
  }) async {
    try {
      final response = await _networkProvider.submitToPython(
        method: HttpMethod.post,
        path: '/care-template',
        body: {
          'symptomId': symptomId,
          'riskAssessmentId': riskAssessmentId,
          'patientData': patientData,
        },
      );

      if (response.success && response.data != null) {
        return {
          'success': true,
          'careTemplate': CareTemplate.fromJson(response.data!['data']['careTemplate']),
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
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getCareTemplateById({
    required String token,
    required String templateId,
  }) async {
    try {
      final response = await _networkProvider.getFromPython('/care-template/$templateId');

      if (response.success && response.data != null) {
        return {
          'success': true,
          'careTemplate': CareTemplate.fromJson(response.data!['data']['careTemplate']),
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
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getUserLatestCareTemplate({
    required String token,
  }) async {
    try {
      final response = await _networkProvider.getFromPython('/care-template/latest');

      if (response.success && response.data != null) {
        return {
          'success': true,
          'careTemplate': CareTemplate.fromJson(response.data!['data']['careTemplate']),
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'No care template found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getUserCareTemplates({
    required String token,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _networkProvider.getFromPython('/care-template', query: query);

      if (response.success && response.data != null) {
        final careTemplates = (response.data!['data']['data'] as List)
            .map((json) => CareTemplate.fromJson(json))
            .toList();

        return {
          'success': true,
          'careTemplates': careTemplates,
          'pagination': response.data!['data']['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to get care templates',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getCareTemplatesByStatus({
    required String token,
    required String status,
  }) async {
    try {
      final response = await _networkProvider.getFromPython('/care-template/status/$status');

      if (response.success && response.data != null) {
        final careTemplates = (response.data!['data']['careTemplates'] as List)
            .map((json) => CareTemplate.fromJson(json))
            .toList();

        return {
          'success': true,
          'careTemplates': careTemplates,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to get care templates',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getCareTemplateStats({
    required String token,
  }) async {
    try {
      final response = await _networkProvider.getFromPython('/care-template/stats');

      if (response.success && response.data != null) {
        return {
          'success': true,
          'stats': response.data!['data']['stats'],
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to get care template stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateCareTemplate({
    required String token,
    required String templateId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final response = await _networkProvider.submitToPython(
        method: HttpMethod.put,
        path: '/care-template/$templateId',
        body: updateData,
      );

      if (response.success && response.data != null) {
        return {
          'success': true,
          'careTemplate': CareTemplate.fromJson(response.data!['data']['careTemplate']),
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to update care template',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteCareTemplate({
    required String token,
    required String templateId,
  }) async {
    try {
      final response = await _networkProvider.submitToPython(
        method: HttpMethod.delete,
        path: '/care-template/$templateId',
      );

      if (response.success) {
        return {
          'success': true,
          'message': response.message ?? 'Care template deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to delete care template',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}

// Riverpod provider
final careTemplateServiceProvider = Provider<CareTemplateService>((ref) {
  return CareTemplateService(ref.read(networkProvider));
}); 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistercheck/plugins/app_provider.dart';
import 'package:sistercheck/plugins/network_provider.dart';
import '../models/risk_assessment.dart';

class RiskAssessmentService {
  final NetworkProvider _networkProvider;
  final AppNotifier _appNotifier;

  RiskAssessmentService(this._networkProvider, this._appNotifier);

  /// Submit a risk assessment and get results
  Future<Map<String, dynamic>> submitAssessment({
    required Map<String, dynamic> answers,
  }) async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to submit risk assessment',
        };
      }

      final response = await _networkProvider.submitToPython(
        method: HttpMethod.post,
        path: '/risk-assessment',
        body: {
          'answers': answers,
        },
      );

      if (response.success && response.data != null) {
        final assessment = RiskAssessment.fromJson(response.data!['assessment']);
        return {
          'success': true,
          'assessment': assessment,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to submit assessment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error submitting assessment: $e',
      };
    }
  }

  /// Get user's latest risk assessment
  Future<RiskAssessment?> getLatestAssessment() async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        throw Exception('Please login to view risk assessments');
      }

      final response = await _networkProvider.getFromPython('/risk-assessment/latest');

      if (response.success && response.data != null) {
        return RiskAssessment.fromJson(response.data!['assessment']);
      } else {
        return null; // No assessment found
      }
    } catch (e) {
      throw Exception('Error getting latest assessment: $e');
    }
  }

  /// Get all risk assessments for the user
  Future<List<RiskAssessment>> getUserAssessments() async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        throw Exception('Please login to view risk assessments');
      }

      final response = await _networkProvider.getFromPython('/risk-assessment');

      if (response.success && response.data != null) {
        final assessmentsData = response.data!['assessments'] as List;
        return assessmentsData
            .map((assessment) => RiskAssessment.fromJson(assessment))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to get assessments');
      }
    } catch (e) {
      throw Exception('Error getting assessments: $e');
    }
  }

  /// Get a specific risk assessment by ID
  Future<RiskAssessment?> getAssessmentById(String assessmentId) async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        throw Exception('Please login to view risk assessments');
      }

      final response = await _networkProvider.getFromPython('/risk-assessment/$assessmentId');

      if (response.success && response.data != null) {
        return RiskAssessment.fromJson(response.data!['assessment']);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error getting assessment: $e');
    }
  }
}

// Provider for RiskAssessmentService
final riskAssessmentServiceProvider = Provider<RiskAssessmentService>((ref) {
  final network = ref.watch(networkProvider);
  final appNotifier = ref.watch(appNotifierProvider.notifier);
  return RiskAssessmentService(network, appNotifier);
});

// Provider for latest risk assessment
final latestRiskAssessmentProvider = FutureProvider<RiskAssessment?>((ref) async {
  final service = ref.watch(riskAssessmentServiceProvider);
  return await service.getLatestAssessment();
});

// Provider for all user risk assessments
final userRiskAssessmentsProvider = FutureProvider<List<RiskAssessment>>((ref) async {
  final service = ref.watch(riskAssessmentServiceProvider);
  return await service.getUserAssessments();
});

// Provider for specific risk assessment
final riskAssessmentByIdProvider = FutureProvider.family<RiskAssessment?, String>((ref, assessmentId) async {
  final service = ref.watch(riskAssessmentServiceProvider);
  return await service.getAssessmentById(assessmentId);
}); 
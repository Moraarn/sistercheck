import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistercheck/plugins/network_provider.dart';
import 'package:sistercheck/plugins/app_provider.dart';

class Symptom {
  final String id;
  final String userId;
  final Map<String, dynamic> symptoms;
  final String severity;
  final String duration;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Symptom({
    required this.id,
    required this.userId,
    required this.symptoms,
    required this.severity,
    required this.duration,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      symptoms: json['symptoms'] ?? {},
      severity: json['severity'] ?? '',
      duration: json['duration'] ?? '',
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class SymptomStats {
  final int totalEntries;
  final double averageSeverity;
  final Map<String, int> mostCommonSymptoms;

  SymptomStats({
    required this.totalEntries,
    required this.averageSeverity,
    required this.mostCommonSymptoms,
  });

  factory SymptomStats.fromJson(Map<String, dynamic> json) {
    return SymptomStats(
      totalEntries: json['totalEntries'] ?? 0,
      averageSeverity: (json['averageSeverity'] ?? 0).toDouble(),
      mostCommonSymptoms: Map<String, int>.from(json['mostCommonSymptoms'] ?? {}),
    );
  }
}

class SymptomsService {
  final NetworkProvider _networkProvider;
  final AppNotifier _appNotifier;

  SymptomsService(this._networkProvider, this._appNotifier);

  /// Create a new symptom entry
  Future<Map<String, dynamic>> createSymptom({
    required Map<String, dynamic> symptoms,
    required String severity,
    required String duration,
    String? notes,
  }) async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to add symptoms',
        };
      }

      final response = await _networkProvider.submitToPython(
        method: HttpMethod.post,
        path: '/symptoms',
        body: {
          'symptoms': symptoms,
          'severity': severity,
          'duration': duration,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.success && response.data != null) {
        final symptom = Symptom.fromJson(response.data!['symptom']);
        return {
          'success': true,
          'symptom': symptom,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to create symptom entry',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating symptom entry: $e',
      };
    }
  }

  /// Get user's latest symptom entry
  Future<Symptom?> getLatestSymptom() async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        throw Exception('Please login to view symptoms');
      }

      final response = await _networkProvider.getFromPython('/symptoms/latest');

      if (response.success && response.data != null) {
        return Symptom.fromJson(response.data!['symptom']);
      } else {
        return null; // No symptom entry found
      }
    } catch (e) {
      throw Exception('Error getting latest symptom: $e');
    }
  }

  /// Get all symptoms for the user
  Future<List<Symptom>> getUserSymptoms() async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        throw Exception('Please login to view symptoms');
      }

      final response = await _networkProvider.getFromPython('/symptoms');

      if (response.success && response.data != null) {
        final symptomsData = response.data!['symptoms'] as List;
        return symptomsData
            .map((symptom) => Symptom.fromJson(symptom))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to get symptoms');
      }
    } catch (e) {
      throw Exception('Error getting symptoms: $e');
    }
  }

  /// Get a specific symptom by ID
  Future<Symptom?> getSymptomById(String symptomId) async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        throw Exception('Please login to view symptoms');
      }

      final response = await _networkProvider.getFromPython('/symptoms/$symptomId');

      if (response.success && response.data != null) {
        return Symptom.fromJson(response.data!['symptom']);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error getting symptom: $e');
    }
  }

  /// Update a symptom entry
  Future<Map<String, dynamic>> updateSymptom({
    required String symptomId,
    Map<String, dynamic>? symptoms,
    String? severity,
    String? duration,
    String? notes,
  }) async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        return {
          'success': false,
          'message': 'Please login to update symptoms',
        };
      }

      final body = <String, dynamic>{};
      if (symptoms != null) body['symptoms'] = symptoms;
      if (severity != null) body['severity'] = severity;
      if (duration != null) body['duration'] = duration;
      if (notes != null) body['notes'] = notes;

      final response = await _networkProvider.submitToPython(
        method: HttpMethod.put,
        path: '/symptoms/$symptomId',
        body: body,
      );

      if (response.success && response.data != null) {
        final symptom = Symptom.fromJson(response.data!['symptom']);
        return {
          'success': true,
          'symptom': symptom,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to update symptom entry',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating symptom entry: $e',
      };
    }
  }

  /// Delete a symptom entry
  Future<bool> deleteSymptom(String symptomId) async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        throw Exception('Please login to delete symptoms');
      }

      final response = await _networkProvider.submitToPython(
        method: HttpMethod.delete,
        path: '/symptoms/$symptomId',
      );

      return response.success;
    } catch (e) {
      throw Exception('Error deleting symptom: $e');
    }
  }

  /// Get symptom statistics
  Future<SymptomStats> getSymptomStats() async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        throw Exception('Please login to view symptom statistics');
      }

      final response = await _networkProvider.getFromPython('/symptoms/stats');

      if (response.success && response.data != null) {
        return SymptomStats.fromJson(response.data!['stats']);
      } else {
        throw Exception(response.message ?? 'Failed to get symptom statistics');
      }
    } catch (e) {
      throw Exception('Error getting symptom statistics: $e');
    }
  }

  /// Get symptoms by severity
  Future<List<Symptom>> getSymptomsBySeverity(String severity) async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        throw Exception('Please login to view symptoms');
      }

      final response = await _networkProvider.getFromPython('/symptoms/severity/$severity');

      if (response.success && response.data != null) {
        final symptomsData = response.data!['symptoms'] as List;
        return symptomsData
            .map((symptom) => Symptom.fromJson(symptom))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to get symptoms by severity');
      }
    } catch (e) {
      throw Exception('Error getting symptoms by severity: $e');
    }
  }

  /// Get recent symptoms (last 30 days)
  Future<List<Symptom>> getRecentSymptoms() async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        throw Exception('Please login to view symptoms');
      }

      final response = await _networkProvider.getFromPython('/symptoms/recent');

      if (response.success && response.data != null) {
        final symptomsData = response.data!['symptoms'] as List;
        return symptomsData
            .map((symptom) => Symptom.fromJson(symptom))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to get recent symptoms');
      }
    } catch (e) {
      throw Exception('Error getting recent symptoms: $e');
    }
  }
}

// Provider for SymptomsService
final symptomsServiceProvider = Provider<SymptomsService>((ref) {
  final network = ref.watch(networkProvider);
  final appNotifier = ref.watch(appNotifierProvider.notifier);
  return SymptomsService(network, appNotifier);
});

// Provider for latest symptom
final latestSymptomProvider = FutureProvider<Symptom?>((ref) async {
  final service = ref.watch(symptomsServiceProvider);
  return await service.getLatestSymptom();
});

// Provider for all user symptoms
final userSymptomsProvider = FutureProvider<List<Symptom>>((ref) async {
  final service = ref.watch(symptomsServiceProvider);
  return await service.getUserSymptoms();
});

// Provider for specific symptom
final symptomByIdProvider = FutureProvider.family<Symptom?, String>((ref, symptomId) async {
  final service = ref.watch(symptomsServiceProvider);
  return await service.getSymptomById(symptomId);
});

// Provider for symptom statistics
final symptomStatsProvider = FutureProvider<SymptomStats>((ref) async {
  final service = ref.watch(symptomsServiceProvider);
  return await service.getSymptomStats();
});

// Provider for symptoms by severity
final symptomsBySeverityProvider = FutureProvider.family<List<Symptom>, String>((ref, severity) async {
  final service = ref.watch(symptomsServiceProvider);
  return await service.getSymptomsBySeverity(severity);
});

// Provider for recent symptoms
final recentSymptomsProvider = FutureProvider<List<Symptom>>((ref) async {
  final service = ref.watch(symptomsServiceProvider);
  return await service.getRecentSymptoms();
}); 
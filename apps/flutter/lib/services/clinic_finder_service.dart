import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/network_provider.dart';

class ClinicFinderService {
  final NetworkProvider _network;

  ClinicFinderService(this._network);

  // Provider for ClinicFinderService
  static final provider = Provider<ClinicFinderService>((ref) {
    final network = ref.watch(networkProvider);
    return ClinicFinderService(network);
  });

  // Find clinics near user location - Use Python backend
  Future<Map<String, dynamic>> findClinics({
    double? latitude,
    double? longitude,
    String? region,
    int radius = 10, // km
  }) async {
    try {
      final response = await _network.getFromPython(
        '/clinics/nearby',
        query: {
          if (latitude != null) 'lat': latitude.toString(),
          if (longitude != null) 'lng': longitude.toString(),
          if (region != null) 'region': region,
          'radius': radius.toString(),
        },
      );

      if (response.success) {
        return {
          'success': true,
          'clinics': response.data?['clinics'] ?? [],
          'total': response.data?['total'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to find clinics',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error finding clinics: $e',
      };
    }
  }

  // Get clinic details - Use Python backend
  Future<Map<String, dynamic>> getClinicDetails(String clinicId) async {
    try {
      final response = await _network.getFromPython('/clinics/$clinicId');

      if (response.success) {
        return {
          'success': true,
          'clinic': response.data?['clinic'],
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to get clinic details',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting clinic details: $e',
      };
    }
  }

  // Search clinics by name or specialty - Use Python backend
  Future<Map<String, dynamic>> searchClinics({
    required String query,
    String? specialty,
  }) async {
    try {
      final response = await _network.getFromPython(
        '/clinics/search',
        query: {
          'q': query,
          if (specialty != null) 'specialty': specialty,
        },
      );

      if (response.success) {
        return {
          'success': true,
          'clinics': response.data?['clinics'] ?? [],
          'total': response.data?['total'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to search clinics',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error searching clinics: $e',
      };
    }
  }
} 
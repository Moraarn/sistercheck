import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/network_provider.dart';
import '../plugins/app_provider.dart';
import '../models/patient_model.dart';

class PatientAuthService {
  final NetworkProvider _network;
  final AppNotifier _appNotifier;

  PatientAuthService(this._network, this._appNotifier);

  // Provider for PatientAuthService
  static final provider = Provider<PatientAuthService>((ref) {
    final network = ref.watch(networkProvider);
    final appNotifier = ref.watch(appNotifierProvider.notifier);
    return PatientAuthService(network, appNotifier);
  });

  // Patient signup - Use Node.js backend
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    String? phone,
    Map<String, dynamic>? medicalData,
  }) async {
    try {
      final response = await _network.submitToNodeJS(
        method: HttpMethod.post,
        path: '/patients/signup',
        body: {
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.success) {
        final patientData = response.data?['patient'] as Map<String, dynamic>?;
        final token = response.data?['token'] as String?;
        
        print('PatientAuthService.signup - Response: ${response.data}');
        print('PatientAuthService.signup - Patient data: $patientData');
        print('PatientAuthService.signup - Token: $token');
        
        if (patientData != null && token != null) {
          final patient = Patient.fromJson(patientData);
          
          // Store patient token and data (auto-login after signup)
          await _appNotifier.loginAsPatient(token: token, patient: patient);
          
          print('PatientAuthService.signup - Patient parsed successfully: ${patient.id}');
        } else {
          print('PatientAuthService.signup - Missing patient data or token');
        }
        
        return {
          'success': true,
          'message': 'Patient registered successfully',
          'patient': response.data?['patient'],
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to register patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error registering patient: $e',
      };
    }
  }

  // Patient signin - Use Node.js backend
  Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    try {
      print('PatientAuthService.signin - Starting login for email: $email');
      
      final response = await _network.submitToNodeJS(
        method: HttpMethod.post,
        path: '/patients/signin',
        body: {
          'email': email,
          'password': password,
        },
      );

      print('PatientAuthService.signin - Raw response: $response');
      print('PatientAuthService.signin - Response success: ${response.success}');
      print('PatientAuthService.signin - Response data: ${response.data}');

      if (response.success) {
        final patientData = response.data?['patient'] as Map<String, dynamic>?;
        final token = response.data?['token'] as String?;
        
        print('PatientAuthService.signin - Patient data: $patientData');
        print('PatientAuthService.signin - Token: $token');
        
        if (patientData != null && token != null) {
          try {
            final patient = Patient.fromJson(patientData);
            print('PatientAuthService.signin - Patient parsed successfully: ${patient.id}');
            
            // Store patient token and data
            print('PatientAuthService.signin - Calling loginAsPatient...');
            await _appNotifier.loginAsPatient(token: token, patient: patient);
            print('PatientAuthService.signin - loginAsPatient completed');
            
            // Verify the login was successful
            final currentState = _appNotifier.state;
            print('PatientAuthService.signin - Current state after login:');
            print('PatientAuthService.signin - isPatientAuthenticated: ${currentState.isPatientAuthenticated}');
            print('PatientAuthService.signin - patientToken: ${currentState.patientToken != null ? 'exists' : 'null'}');
            print('PatientAuthService.signin - patient: ${currentState.patient?.id}');
            
            return {
              'success': true,
              'message': 'Patient login successful',
              'patient': patient,
            };
          } catch (parseError) {
            print('PatientAuthService.signin - Error parsing patient data: $parseError');
            return {
              'success': false,
              'message': 'Error parsing patient data: $parseError',
            };
          }
        } else {
          print('PatientAuthService.signin - Missing patient data or token');
          print('PatientAuthService.signin - patientData is null: ${patientData == null}');
          print('PatientAuthService.signin - token is null: ${token == null}');
          return {
            'success': false,
            'message': 'Login successful but patient data is incomplete',
          };
        }
      } else {
        print('PatientAuthService.signin - Login failed: ${response.message}');
        return {
          'success': false,
          'message': response.message ?? 'Login failed',
        };
      }
    } catch (e) {
      print('PatientAuthService.signin - Exception during login: $e');
      return {
        'success': false,
        'message': 'Error during login: $e',
      };
    }
  }

  // Get patient profile - Use Node.js backend
  Future<Map<String, dynamic>> getPatientProfile() async {
    try {
      final response = await _network.getFromNodeJS('/patients/profile');

      if (response.success) {
        final patientData = response.data?['patient'] as Map<String, dynamic>?;
        if (patientData != null) {
          final patient = Patient.fromJson(patientData);
          return {
            'success': true,
            'patient': patient,
          };
        }
      }
      
      return {
        'success': false,
        'message': response.message ?? 'Failed to get patient profile',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting patient profile: $e',
      };
    }
  }

  // Update patient profile - Use Python backend
  Future<Map<String, dynamic>> updatePatientProfile({
    required Map<String, dynamic> medicalData,
  }) async {
    try {
      final response = await _network.submitToPython(
        method: HttpMethod.put,
        path: '/patients/profile',
        body: {
          'medical_data': medicalData,
        },
      );

      if (response.success) {
        return {
          'success': true,
          'message': 'Patient profile updated successfully',
          'patient': response.data?['patient'],
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to update patient profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating patient profile: $e',
      };
    }
  }

  // Save patient data to Node.js backend
  Future<Map<String, dynamic>> savePatientToNodeJS({
    required Map<String, dynamic> patientData,
  }) async {
    try {
      final response = await _network.submitToNodeJS(
        method: HttpMethod.post,
        path: '/patients',
        body: patientData,
      );

      if (response.success) {
        return {
          'success': true,
          'message': 'Patient saved successfully',
          'patient': response.data?['patient'],
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to save patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error saving patient: $e',
      };
    }
  }

  // Patient logout - Use Node.js backend
  Future<void> logout() async {
    try {
      await _network.submitToNodeJS(
        method: HttpMethod.post,
        path: '/patients/logout',
      );
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _appNotifier.logoutPatient();
    }
  }

  // Get all patients (for doctors/nurses) - Use Python backend
  Future<Map<String, dynamic>> getPatients({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        return {
          'success': false,
          'message': 'Authentication required to view patients',
        };
      }

      final response = await _network.getFromPython(
        '/patients',
        query: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.success) {
        final patientsData = response.data?['patients'] as List<dynamic>?;
        final patients = patientsData?.map((data) => Patient.fromJson(data as Map<String, dynamic>)).toList() ?? [];
        
        return {
          'success': true,
          'patients': patients,
          'total': response.data?['total'] ?? 0,
          'page': response.data?['page'] ?? page,
          'limit': response.data?['limit'] ?? limit,
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

  // Search patients - Use Python backend
  Future<Map<String, dynamic>> searchPatients({
    required String query,
    String type = 'id',
  }) async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        return {
          'success': false,
          'message': 'Authentication required to search patients',
        };
      }

      final response = await _network.getFromPython(
        '/patients/search',
        query: {
          'query': query,
          'type': type,
        },
      );

      if (response.success) {
        final patientsData = response.data?['patients'] as List<dynamic>?;
        final patients = patientsData?.map((data) => Patient.fromJson(data as Map<String, dynamic>)).toList() ?? [];
        
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

  // Create patient with risk assessment - Use Python backend
  Future<Map<String, dynamic>> createPatientWithRiskAssessment({
    required Map<String, dynamic> patientData,
  }) async {
    try {
      // Check if user is authenticated
      if (!_appNotifier.state.isAuthenticated) {
        return {
          'success': false,
          'message': 'Authentication required to create patients',
        };
      }

      final response = await _network.submitToPython(
        method: HttpMethod.post,
        path: '/patients/create-with-assessment',
        body: patientData,
      );

      if (response.success) {
        return {
          'success': true,
          'message': 'Patient created with risk assessment',
          'patient': response.data?['patient'],
          'risk_assessment': response.data?['risk_assessment'],
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to create patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating patient: $e',
      };
    }
  }
} 
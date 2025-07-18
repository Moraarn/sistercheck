import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:sistercheck/models/user_model.dart';
import 'package:sistercheck/models/patient_model.dart';


const String _tokenKey = 'auth_token';
const String _userKey = 'user_data';
const String _patientTokenKey = 'patient_auth_token';
const String _patientKey = 'patient_data';
const String _themeKey = 'theme'; // light, dark or system (default)

class AppState {
  final User? user;
  final Patient? patient;
  final String? authToken;
  final String? patientToken;
  final bool isInternetConnected;
  final bool isLoading;
  final String? error;
  final ThemeMode themeMode;

  const AppState({
    this.user,
    this.patient,
    this.authToken,
    this.patientToken,
    this.isInternetConnected = true,
    this.isLoading = false,
    this.error,
    this.themeMode = ThemeMode.system,
  });

  bool get isAuthenticated => authToken != null && user != null;
  bool get isPatientAuthenticated => patientToken != null && patient != null;

  AppState copyWith({
    User? user,
    Patient? patient,
    String? authToken,
    String? patientToken,
    bool? isInternetConnected,
    bool? isLoading,
    String? error,
    ThemeMode? themeMode,
  }) {
    return AppState(
      user: user ?? this.user,
      patient: patient ?? this.patient,
      authToken: authToken ?? this.authToken,
      patientToken: patientToken ?? this.patientToken,
      isInternetConnected: isInternetConnected ?? this.isInternetConnected,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(const AppState()) {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _initializeConnectionStatus();
    await _loadStoredAuth();
    await _loadTheme();
  }

  // Authentication Methods
  Future<void> login({required String token, required User user}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _saveAuthData(token, user);
      state = state.copyWith(authToken: token, user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save authentication data',
      );
    }
  }

  Future<void> loginAsPatient({required String token, required Patient patient}) async {
    state = state.copyWith(isLoading: true, error: null);

    print('AppNotifier.loginAsPatient - Starting login for patient: ${patient.id}');
    print('AppNotifier.loginAsPatient - Token: $token');

    try {
      await _savePatientAuthData(token, patient);
      state = state.copyWith(patientToken: token, patient: patient, isLoading: false);
      
      print('AppNotifier.loginAsPatient - Login successful');
      print('AppNotifier.loginAsPatient - New state - isPatientAuthenticated: ${state.isPatientAuthenticated}');
      print('AppNotifier.loginAsPatient - New state - patientToken: ${state.patientToken != null ? 'exists' : 'null'}');
      print('AppNotifier.loginAsPatient - New state - patient: ${state.patient?.id}');
    } catch (e) {
      print('AppNotifier.loginAsPatient - Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save patient authentication data',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Clear both user and patient authentication data
      await _clearAuthData();
      await _clearPatientAuthData();
      state = const AppState(isInternetConnected: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to logout');
    }
  }

  Future<void> logoutPatient() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Clear both user and patient authentication data
      await _clearAuthData();
      await _clearPatientAuthData();
      state = const AppState(isInternetConnected: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to logout patient');
    }
  }

  // User Management Methods
  Future<void> updateUserDetails(User updatedUser) async {
    if (!state.isAuthenticated) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _saveUserData(updatedUser);
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update user details',
      );
    }
  }

  // Network Status Management
  void _initializeConnectionStatus() {
    InternetConnection().onStatusChange.listen((status) {
      updateInternetStatus(status == InternetStatus.connected);
    });
  }

  void updateInternetStatus(bool status) {
    state = state.copyWith(isInternetConnected: status);
  }

  // Storage Methods
  Future<void> _loadStoredAuth() async {
    try {
      print('AppNotifier._loadStoredAuth - Loading stored authentication data');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      final patientToken = prefs.getString(_patientTokenKey);
      final patientJson = prefs.getString(_patientKey);

      print('AppNotifier._loadStoredAuth - Found tokens - authToken: ${token != null ? 'exists' : 'null'}, patientToken: ${patientToken != null ? 'exists' : 'null'}');

      if (token != null && userJson != null) {
        final userData = json.decode(userJson);
        final user = User.fromJson(userData);
        state = state.copyWith(authToken: token, user: user);
        print('AppNotifier._loadStoredAuth - Loaded user authentication: ${user.id}');
      }

      if (patientToken != null && patientJson != null) {
        final patientData = json.decode(patientJson);
        final patient = Patient.fromJson(patientData);
        state = state.copyWith(patientToken: patientToken, patient: patient);
        print('AppNotifier._loadStoredAuth - Loaded patient authentication: ${patient.id}');
      }
      
      print('AppNotifier._loadStoredAuth - Final state - isAuthenticated: ${state.isAuthenticated}, isPatientAuthenticated: ${state.isPatientAuthenticated}');
    } catch (e) {
      print('AppNotifier._loadStoredAuth - Error loading stored auth: $e');
      state = state.copyWith(error: 'Failed to load stored authentication');
    }
  }

  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([prefs.setString(_tokenKey, token), _saveUserData(user)]);
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> _savePatientAuthData(String token, Patient patient) async {
    print('AppNotifier._savePatientAuthData - Saving patient token and data');
    print('AppNotifier._savePatientAuthData - Token: $token');
    print('AppNotifier._savePatientAuthData - Patient ID: ${patient.id}');
    
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([prefs.setString(_patientTokenKey, token), _savePatientData(patient)]);
    
    print('AppNotifier._savePatientAuthData - Patient auth data saved successfully');
  }

  Future<void> _savePatientData(Patient patient) async {
    print('AppNotifier._savePatientData - Saving patient data: ${patient.id}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_patientKey, json.encode(patient.toJson()));
    print('AppNotifier._savePatientData - Patient data saved successfully');
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([prefs.remove(_tokenKey), prefs.remove(_userKey)]);
  }

  Future<void> _clearPatientAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([prefs.remove(_patientTokenKey), prefs.remove(_patientKey)]);
  }

  // Error Management
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Theme Management
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'system';
    ThemeMode mode;
    switch (themeString) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString = 'system';
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    await prefs.setString(_themeKey, themeString);
    state = state.copyWith(themeMode: mode);
  }
}

// Providers
final appNotifierProvider = StateNotifierProvider<AppNotifier, AppState>((ref) => AppNotifier());

// Convenience Providers for commonly accessed state
final userProvider = Provider<User?>((ref) {
  return ref.watch(appNotifierProvider).user;
});

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(appNotifierProvider).authToken;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(appNotifierProvider).isAuthenticated;
});

// Patient authentication providers
final patientProvider = Provider<Patient?>((ref) {
  return ref.watch(appNotifierProvider).patient;
});

final patientTokenProvider = Provider<String?>((ref) {
  return ref.watch(appNotifierProvider).patientToken;
});

final isPatientAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(appNotifierProvider).isPatientAuthenticated;
});

final isConnectedProvider = Provider<bool>((ref) {
  return ref.watch(appNotifierProvider).isInternetConnected;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appNotifierProvider).themeMode;
});

// Extension for easy access in widgets
extension AppStateContext on BuildContext {
  AppState get appState =>
      ProviderScope.containerOf(this).read(appNotifierProvider);
  bool get isAuthenticated => appState.isAuthenticated;
  bool get isPatientAuthenticated => appState.isPatientAuthenticated;
  bool get isConnected => appState.isInternetConnected;
  User? get currentUser => appState.user;
  Patient? get currentPatient => appState.patient;
  String? get authToken => appState.authToken;
  String? get patientToken => appState.patientToken;
}

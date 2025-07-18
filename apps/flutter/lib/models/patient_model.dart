import 'package:flutter/material.dart';

// Patient Status enum
enum PatientStatus {
  active,
  inactive,
  pending;

  static PatientStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return PatientStatus.active;
      case 'inactive':
        return PatientStatus.inactive;
      case 'pending':
        return PatientStatus.pending;
      default:
        return PatientStatus.active;
    }
  }

  String get value {
    switch (this) {
      case PatientStatus.active:
        return 'active';
      case PatientStatus.inactive:
        return 'inactive';
      case PatientStatus.pending:
        return 'pending';
    }
  }
}

// Patient Risk Level enum
enum PatientRiskLevel {
  low,
  medium,
  high,
  unknown;

  static PatientRiskLevel fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
        return PatientRiskLevel.low;
      case 'medium':
        return PatientRiskLevel.medium;
      case 'high':
        return PatientRiskLevel.high;
      default:
        return PatientRiskLevel.unknown;
    }
  }

  String get value {
    switch (this) {
      case PatientRiskLevel.low:
        return 'Low';
      case PatientRiskLevel.medium:
        return 'Medium';
      case PatientRiskLevel.high:
        return 'High';
      case PatientRiskLevel.unknown:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case PatientRiskLevel.low:
        return Colors.green;
      case PatientRiskLevel.medium:
        return Colors.orange;
      case PatientRiskLevel.high:
        return Colors.red;
      case PatientRiskLevel.unknown:
        return Colors.grey;
    }
  }
}

// Patient Authentication model
class PatientAuth {
  final String? id;
  final String? email;
  final String? phone;
  final String? password;
  final PatientStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PatientAuth({
    this.id,
    this.email,
    this.phone,
    this.password,
    this.status = PatientStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientAuth.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PatientAuth();
    
    return PatientAuth(
      id: json['id'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      password: json['password'] as String?,
      status: PatientStatus.fromString(json['status'] as String?),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (password != null) 'password': password,
      'status': status.value,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  PatientAuth copyWith({
    String? id,
    String? email,
    String? phone,
    String? password,
    PatientStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientAuth(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Patient Medical Data model
class PatientMedicalData {
  final int? age;
  final String? region;
  final double? cystSize;
  final int? ca125Level;
  final String? symptoms;
  final String? menopauseStage;
  final String? ultrasoundFeatures;
  final PatientRiskLevel riskLevel;
  final String? previousRecommendation;
  final Map<String, dynamic>? careTemplate;

  const PatientMedicalData({
    this.age,
    this.region,
    this.cystSize,
    this.ca125Level,
    this.symptoms,
    this.menopauseStage,
    this.ultrasoundFeatures,
    this.riskLevel = PatientRiskLevel.unknown,
    this.previousRecommendation,
    this.careTemplate,
  });

  factory PatientMedicalData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PatientMedicalData();
    
    return PatientMedicalData(
      age: json['age'] as int?,
      region: json['region'] as String?,
      cystSize: json['cystSize'] != null ? (json['cystSize'] as num).toDouble() : null,
      ca125Level: json['ca125Level'] as int?,
      symptoms: json['symptoms'] as String?,
      menopauseStage: json['menopauseStage'] as String?,
      ultrasoundFeatures: json['ultrasoundFeatures'] as String?,
      riskLevel: PatientRiskLevel.fromString(json['riskLevel'] as String?),
      previousRecommendation: json['previousRecommendation'] as String?,
      careTemplate: json['careTemplate'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (age != null) 'age': age,
      if (region != null) 'region': region,
      if (cystSize != null) 'cyst_size': cystSize,
      if (ca125Level != null) 'ca125_level': ca125Level,
      if (symptoms != null) 'symptoms': symptoms,
      if (menopauseStage != null) 'menopause_stage': menopauseStage,
      if (ultrasoundFeatures != null) 'ultrasound_features': ultrasoundFeatures,
      'risk_level': riskLevel.value,
      if (previousRecommendation != null) 'previous_recommendation': previousRecommendation,
      if (careTemplate != null) 'care_template': careTemplate,
    };
  }

  PatientMedicalData copyWith({
    int? age,
    String? region,
    double? cystSize,
    int? ca125Level,
    String? symptoms,
    String? menopauseStage,
    String? ultrasoundFeatures,
    PatientRiskLevel? riskLevel,
    String? previousRecommendation,
    Map<String, dynamic>? careTemplate,
  }) {
    return PatientMedicalData(
      age: age ?? this.age,
      region: region ?? this.region,
      cystSize: cystSize ?? this.cystSize,
      ca125Level: ca125Level ?? this.ca125Level,
      symptoms: symptoms ?? this.symptoms,
      menopauseStage: menopauseStage ?? this.menopauseStage,
      ultrasoundFeatures: ultrasoundFeatures ?? this.ultrasoundFeatures,
      riskLevel: riskLevel ?? this.riskLevel,
      previousRecommendation: previousRecommendation ?? this.previousRecommendation,
      careTemplate: careTemplate ?? this.careTemplate,
    );
  }
}

// Main Patient model
class Patient {
  final String? id;
  final PatientAuth auth;
  final PatientMedicalData medicalData;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Patient({
    this.id,
    required this.auth,
    required this.medicalData,
    this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Patient(
      auth: PatientAuth(),
      medicalData: PatientMedicalData(),
    );
    
    return Patient(
      id: json['id'] as String?,
      auth: PatientAuth.fromJson(json['auth'] as Map<String, dynamic>?),
      medicalData: PatientMedicalData.fromJson(json['medicalData'] as Map<String, dynamic>?),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'auth': auth.toJson(),
      'medical_data': medicalData.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Patient copyWith({
    String? id,
    PatientAuth? auth,
    PatientMedicalData? medicalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      auth: auth ?? this.auth,
      medicalData: medicalData ?? this.medicalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convenience getters for backward compatibility
  String? get email => auth.email;
  String? get phone => auth.phone;
  int? get age => medicalData.age;
  String? get region => medicalData.region;
  double? get cystSize => medicalData.cystSize;
  int? get ca125Level => medicalData.ca125Level;
  String? get symptoms => medicalData.symptoms;
  String? get menopauseStage => medicalData.menopauseStage;
  String? get ultrasoundFeatures => medicalData.ultrasoundFeatures;
  PatientRiskLevel get riskLevel => medicalData.riskLevel;
  String? get previousRecommendation => medicalData.previousRecommendation;
  Map<String, dynamic>? get careTemplate => medicalData.careTemplate;
} 
class RiskAssessment {
  final String? id;
  final String? patientId;
  final String? userId;
  final Map<String, dynamic>? answers;
  final String riskLevel;
  final int? score;
  final List<String> riskFactors;
  final Map<String, dynamic>? guidelines;
  final Map<String, dynamic>? recommendations;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? timestamp;

  RiskAssessment({
    this.id,
    this.patientId,
    this.userId,
    this.answers,
    required this.riskLevel,
    this.score,
    required this.riskFactors,
    this.guidelines,
    this.recommendations,
    this.createdAt,
    this.updatedAt,
    this.timestamp,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      id: json['_id'] ?? json['id'],
      patientId: json['patient_id'] ?? json['patientId'],
      userId: json['userId'],
      answers: json['answers'],
      riskLevel: json['risk_level'] ?? json['riskLevel'] ?? '',
      score: json['risk_score'] ?? json['score'],
      riskFactors: List<String>.from(json['risk_factors'] ?? json['riskFactors'] ?? []),
      guidelines: json['guidelines'],
      recommendations: json['recommendations'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'patient_id': patientId,
    'userId': userId,
    'answers': answers,
    'risk_level': riskLevel,
    'risk_score': score,
    'risk_factors': riskFactors,
    'guidelines': guidelines,
    'recommendations': recommendations,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'timestamp': timestamp?.toIso8601String(),
  };
} 
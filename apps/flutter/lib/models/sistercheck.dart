
class SisterCheck {
  final String name;
  final int age;
  final String language;
  final String location;
  final String riskLevel; // Low, Moderate, High

  SisterCheck({
    required this.name,
    required this.age,
    required this.language,
    required this.location,
    required this.riskLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'language': language,
      'location': location,
      'riskLevel': riskLevel,
    };
  }
} 
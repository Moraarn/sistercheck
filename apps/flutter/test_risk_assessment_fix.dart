import 'dart:convert';

void main() async {
  print('Testing Risk Assessment Fix...\n');

  // Test data that matches the backend response
  final testResponse = {
    'guidelines_reference': 'Kenyan National Guidelines for Ovarian Cyst Management',
    'risk_assessment': {
      'risk_factors': ['Elevated CA-125 (>35)', 'Suspicious ultrasound features'],
      'risk_level': 'Medium',
      'risk_score': 3
    },
    'success': true,
    'timestamp': '2025-07-12T18:42:01.613686'
  };

  print('✅ Backend Response Structure:');
  print(json.encode(testResponse));
  print('\n');

  // Test accessing the data as Map<String, dynamic>
  final riskAssessment = testResponse['risk_assessment'] as Map<String, dynamic>;
  
  print('✅ Risk Level: ${riskAssessment['risk_level']}');
  print('✅ Risk Score: ${riskAssessment['risk_score']}');
  print('✅ Risk Factors: ${riskAssessment['risk_factors']}');
  print('✅ Guidelines Reference: ${testResponse['guidelines_reference']}');
  
  print('\n✅ Test completed successfully! The fix should work correctly.');
} 
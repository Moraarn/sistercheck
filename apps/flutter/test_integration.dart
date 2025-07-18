import 'dart:convert';
import 'package:http/http.dart' as http;

class IntegrationTest {
  static const String baseUrl = 'http://localhost:5000';

  static Future<void> testBackendConnection() async {
    print('🧪 Testing Backend Integration...\n');

    try {
      // Test 1: Check if backend is running
      print('1. Testing backend connectivity...');
      final response = await http.get(Uri.parse('$baseUrl/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Backend is running: ${data['message']}');
      } else {
        print('❌ Backend is not responding properly');
        return;
      }

      // Test 2: Test user registration
      print('\n2. Testing user registration...');
      final registerResponse = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': 'testuser_${DateTime.now().millisecondsSinceEpoch}',
          'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
          'password': 'password123',
          'name': 'Test User',
          'age': 25,
          'language': 'English',
          'location': 'Nairobi',
          'role': 'user',
        }),
      );

      if (registerResponse.statusCode == 201) {
        final registerData = json.decode(registerResponse.body);
        print('✅ User registration successful: ${registerData['message']}');
        
        // Test 3: Test user login
        print('\n3. Testing user login...');
        final loginResponse = await http.post(
          Uri.parse('$baseUrl/users/signin'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': 'test_${DateTime.now().millisecondsSinceEpoch - 1000}@example.com',
            'password': 'password123',
          }),
        );

        if (loginResponse.statusCode == 200) {
          final loginData = json.decode(loginResponse.body);
          print('✅ User login successful: ${loginData['message']}');
        } else {
          print('❌ User login failed: ${loginResponse.statusCode}');
        }
      } else {
        print('❌ User registration failed: ${registerResponse.statusCode}');
        print('Response: ${registerResponse.body}');
      }

      // Test 4: Test peer sister registration
      print('\n4. Testing peer sister registration...');
      final sisterResponse = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': 'sister_${DateTime.now().millisecondsSinceEpoch}',
          'email': 'sister_${DateTime.now().millisecondsSinceEpoch}@example.com',
          'password': 'password123',
          'name': 'Test Sister',
          'age': 30,
          'language': 'English',
          'location': 'Mombasa',
          'role': 'peer_sister',
        }),
      );

      if (sisterResponse.statusCode == 201) {
        final sisterData = json.decode(sisterResponse.body);
        print('✅ Peer sister registration successful: ${sisterData['message']}');
      } else {
        print('❌ Peer sister registration failed: ${sisterResponse.statusCode}');
      }

      // Test 5: Test nurse registration
      print('\n5. Testing nurse registration...');
      final nurseResponse = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': 'nurse_${DateTime.now().millisecondsSinceEpoch}',
          'email': 'nurse_${DateTime.now().millisecondsSinceEpoch}@example.com',
          'password': 'password123',
          'name': 'Test Nurse',
          'age': 35,
          'language': 'English',
          'location': 'Kisumu',
          'role': 'nurse',
        }),
      );

      if (nurseResponse.statusCode == 201) {
        final nurseData = json.decode(nurseResponse.body);
        print('✅ Nurse registration successful: ${nurseData['message']}');
      } else {
        print('❌ Nurse registration failed: ${nurseResponse.statusCode}');
      }

      print('\n🎉 All tests completed!');
      print('\n📱 You can now test the Flutter app:');
      print('   1. Run: flutter run');
      print('   2. Navigate to signup screen');
      print('   3. Choose a role and register');
      print('   4. Try logging in with the created account');

    } catch (e) {
      print('❌ Test failed with error: $e');
      print('\n🔧 Troubleshooting:');
      print('   1. Make sure the backend is running: cd sistercheck-api && npm run dev');
      print('   2. Check if the backend is accessible at http://localhost:5000');
      print('   3. Verify there are no firewall or network issues');
    }
  }
}

void main() async {
  await IntegrationTest.testBackendConnection();
} 
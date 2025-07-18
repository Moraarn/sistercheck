import 'dart:convert';
import 'dart:io';

void main() async {
  print('Testing CodeHer Registration Flow...\n');
  
  // Test data
  final testUser = {
    'username': 'testuser_${DateTime.now().millisecondsSinceEpoch}',
    'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
    'password': 'testpassword123',
    'name': 'Test User',
    'phone': '+254700000000',
    'age': 25,
    'language': 'English',
    'location': 'Nairobi',
    'role': 'user'
  };
  
  try {
    // Test registration
    print('1. Testing user registration...');
    final registrationResult = await testRegistration(testUser);
    
    if (registrationResult['success']) {
      print('✅ Registration successful!');
      print('   User ID: ${registrationResult['data']['user']['_id']}');
      print('   Username: ${registrationResult['data']['user']['username']}');
      print('   Email: ${registrationResult['data']['user']['email']}');
      
      // Test login with the registered user
      print('\n2. Testing login with registered user...');
      final loginResult = await testLogin(testUser['email'] as String, testUser['password'] as String);
      
      if (loginResult['success']) {
        print('✅ Login successful!');
        print('   User authenticated successfully');
      } else {
        print('❌ Login failed: ${loginResult['message']}');
      }
      
    } else {
      print('❌ Registration failed: ${registrationResult['message']}');
    }
    
  } catch (e) {
    print('❌ Test failed with error: $e');
  }
  
  print('\n✅ Registration flow test completed!');
}

Future<Map<String, dynamic>> testRegistration(Map<String, dynamic> userData) async {
  final client = HttpClient();
  
  try {
    final request = await client.postUrl(Uri.parse('http://localhost:5000/users/signup'));
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode(userData));
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return {
        'success': true,
        'message': 'User registered successfully',
        'data': data
      };
    } else {
      final error = jsonDecode(responseBody);
      return {
        'success': false,
        'message': error['message'] ?? 'Registration failed',
        'data': null
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Network error: $e',
      'data': null
    };
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>> testLogin(String email, String password) async {
  final client = HttpClient();
  
  try {
    final request = await client.postUrl(Uri.parse('http://localhost:5000/users/signin'));
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode({
      'email': email,
      'password': password
    }));
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return {
        'success': true,
        'message': 'Login successful',
        'data': data
      };
    } else {
      final error = jsonDecode(responseBody);
      return {
        'success': false,
        'message': error['message'] ?? 'Login failed',
        'data': null
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Network error: $e',
      'data': null
    };
  } finally {
    client.close();
  }
} 
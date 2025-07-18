import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sistercheck/plugins/theme/theme_provider.dart';
import 'package:sistercheck/plugins/theme/colors.dart';
import 'package:sistercheck/plugins/network_provider.dart';
import 'package:sistercheck/plugins/app_provider.dart';
import 'package:sistercheck/models/user_model.dart';


class SignupUserScreen extends ConsumerStatefulWidget {
  const SignupUserScreen({super.key});

  @override
  _SignupUserScreenState createState() => _SignupUserScreenState();
}

class _SignupUserScreenState extends ConsumerState<SignupUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _regionController = TextEditingController();
  
  int? age;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  final List<String> regions = ['Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret', 'Kakamega', 'Kisii', 'Kericho', 'Nyeri', 'Thika', 'Other'];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _hospitalController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'User Registration',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.border.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.person_add,
                        color: colors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Join as a User',
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Access health resources and track your wellness',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Form fields
              _buildFormField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.person,
                validator: (v) => v == null || v.isEmpty ? 'Username is required' : null,
                colors: colors,
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                colors: colors,
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                colors: colors,
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Phone number is required' : null,
                colors: colors,
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                label: 'Age',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Age is required' : null,
                onSaved: (v) => age = int.tryParse(v ?? ''),
                colors: colors,
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _hospitalController,
                label: 'Hospital/Clinic Name',
                icon: Icons.local_hospital,
                validator: (v) => v == null || v.isEmpty ? 'Hospital/Clinic name is required' : null,
                colors: colors,
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _regionController,
                label: 'Region',
                icon: Icons.location_city,
                validator: (v) => v == null || v.isEmpty ? 'Region is required' : null,
                colors: colors,
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: !_isPasswordVisible,
                validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: colors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                colors: colors,
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                obscureText: !_isConfirmPasswordVisible,
                validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: colors.primary,
                  ),
                onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                colors: colors,
              ),
              
              const SizedBox(height: 32),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? SpinKitWave(
                          color: Colors.white,
                          size: 24.0,
                        )
                      : Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Back to login
              Center(
                child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/onboarding'),
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cross-link to patient signup
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/patient_signup'),
                  child: Text(
                    'Are you a patient? Sign up as Patient',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required AppColors colors,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    Function(String?)? onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.border.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: colors.primary),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.primary, width: 2),
          ),
          filled: true,
          fillColor: colors.inputFieldBg,
          labelStyle: TextStyle(color: colors.secondaryText),
        ),
        style: TextStyle(color: colors.text),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
    required AppColors colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.border.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: colors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.primary, width: 2),
          ),
          filled: true,
          fillColor: colors.inputFieldBg,
          labelStyle: TextStyle(color: colors.secondaryText),
        ),
        style: TextStyle(color: colors.text),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item, style: TextStyle(color: colors.text)),
        )).toList(),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final network = ref.read(networkProvider);
      final appNotifier = ref.read(appNotifierProvider.notifier);

      final response = await network.submit(
        method: HttpMethod.post,
        path: '/users/signup',
        body: {
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text,
          'age': age,
          'region': _regionController.text.trim(),
          'role': UserRole.user.value,
          'status': UserStatus.active.value,
          'riskLevel': RiskLevel.low.value,
          'healthPreferences': {
            'notifications': true,
            'privacyLevel': PrivacyLevel.private.value,
            'language': 'en', // Default language
          },
        },
      );

      if (response.success) {
        // Extract user data from response
        final userData = response.data?['user'] as Map<String, dynamic>?;
        final token = response.data?['token'] as String?;
        
        if (userData != null && token != null) {
          // Create User object from response data
          final user = User.fromJson(userData);

          // Login using app provider
          await appNotifier.login(token: token, user: user);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful! Welcome to SisterCheck'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home screen
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Handle successful registration but missing user data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful but user data is incomplete'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Handle registration failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 
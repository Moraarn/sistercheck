import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';
import '../plugins/network_provider.dart';
import '../plugins/app_provider.dart';
import '../models/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        path: '/users/signin',
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
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

          // Navigate to home screen
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Handle successful login but missing user data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful but user data is incomplete'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        // Handle login failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Login failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    // TODO: Implement Google Sign-In functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Google Sign-In will be available soon!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;
    final size = MediaQuery.of(context).size;
    
    // Debug: Check authentication state
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final appState = ref.watch(appNotifierProvider);

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary.withOpacity(0.1),
              colors.primary.withOpacity(0.05),
              colors.scaffoldBackground,
              colors.scaffoldBackground,
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
              child: SingleChildScrollView(
          child: Container(
                  constraints: BoxConstraints(
                    minHeight: size.height - MediaQuery.of(context).padding.top,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header section with back button
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
            decoration: BoxDecoration(
                                color: colors.card.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.border.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const Spacer(),
                ],
              ),
            ),
                      
                      // Main content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                            // Logo section with enhanced design
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colors.primary.withOpacity(0.2),
                                          colors.primary.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(70),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.primary.withOpacity(0.3),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                        ),
                                        BoxShadow(
                                          color: colors.border.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.card,
                                        borderRadius: BorderRadius.circular(66),
                            boxShadow: [
                              BoxShadow(
                                            color: colors.border.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                                        borderRadius: BorderRadius.circular(66),
                            child: Image.asset(
                              'assets/images/pic1.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                                    ),
                                  ),
                                );
                              },
                        ),
                        
                            const SizedBox(height: 40),
                        
                            // Welcome text with enhanced typography
                        Text(
                              'Welcome Back',
                          style: TextStyle(
                                fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                                letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                            const SizedBox(height: 12),
                        
                        Text(
                          'Sign in to continue your health journey',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.secondaryText,
                                height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                            const SizedBox(height: 50),
                        
                            // Modern input fields
                            _buildModernInputField(
                            controller: _emailController,
                              label: 'Email Address',
                              icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                              colors: colors,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            _buildModernInputField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              colors: colors,
                        ),
                        
                        const SizedBox(height: 16),
                        
                            // Forgot password with modern styling
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password functionality
                            },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                            child: Text(
                              'Forgot password?',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        ),
                        
                            const SizedBox(height: 32),
                        
                            // Enhanced login button
                            _buildModernButton(
                            onPressed: _isLoading ? null : _login,
                              isLoading: _isLoading,
                              text: 'Sign In',
                              colors: colors,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Modern divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colors.border.withOpacity(0.0),
                                          colors.border,
                                          colors.border.withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Text(
                                    'or continue with',
                                  style: TextStyle(
                                      color: colors.secondaryText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colors.border.withOpacity(0.0),
                                          colors.border,
                                          colors.border.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                                ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                            // Enhanced Google sign in button
                            _buildGoogleSignInButton(colors),
                        
                            const SizedBox(height: 32),
                        
                            // Sign up section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                                  style: TextStyle(
                                    color: colors.secondaryText,
                                    fontSize: 15,
                                  ),
                            ),
                            TextButton(
                              onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/signup_user');
                              },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Cross-link to patient authentication
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Are you a patient? ',
                                  style: TextStyle(
                                    color: colors.secondaryText,
                                    fontSize: 15,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/patient_login');
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  child: Text(
                                    'Sign in as Patient',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Bottom padding for safe area
                            const SizedBox(height: 40),
                          ],
                        ),
                        ),
                      ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppColors colors,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.inputFieldBg.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.inputFieldBorder.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.border.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        style: TextStyle(
          color: colors.text,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: colors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: colors.primary,
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: colors.primary,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String text,
    required AppColors colors,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.primary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SpinKitWave(
                color: Colors.white,
                size: 24.0,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(AppColors colors) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        color: colors.card.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.border.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: _isLoading
            ? SpinKitWave(
                color: colors.primary,
                size: 20.0,
              )
            : Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: colors.border.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/google.png',
                  height: 20,
                  width: 20,
                ),
              ),
        label: Text(
          _isLoading ? 'Signing in...' : 'Continue with Google',
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
} 
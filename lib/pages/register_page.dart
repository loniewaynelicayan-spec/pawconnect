import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'splash_page.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool _acceptedTerms = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    passwordController.removeListener(_onPasswordChanged);
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) setState(() {});
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    final name = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog('Please complete all required fields');
      return;
    }
    if (!_isValidEmail(email)) {
      _showErrorDialog('Please enter a valid email address');
      return;
    }
    if (!_isStrongPassword(password)) {
      _showErrorDialog(
        'Password must be at least 8 characters and include letters and numbers',
      );
      return;
    }
    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match');
      return;
    }
    if (!_acceptedTerms) {
      _showErrorDialog('Please accept the terms to continue');
      return;
    }

    setState(() => isLoading = true);

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    } else {
      _showErrorDialog(result['message'] ?? 'Registration failed');
    }
  }

  bool _isValidEmail(String value) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(value);
  }

  bool _isStrongPassword(String value) {
    if (value.length < 8) return false;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasNumber = RegExp(r'\d').hasMatch(value);
    return hasLetter && hasNumber;
  }

  String _passwordHint(String value) {
    if (value.isEmpty) {
      return 'Use at least 8 characters with letters and numbers';
    }
    if (!_isStrongPassword(value)) {
      return 'Weak password';
    }
    return 'Strong password';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Hello! Register to get started',
                  textAlign: TextAlign.center,
                  style: AppStyles.heading2,
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: usernameController,
                  hintText: 'Name',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  isPassword: true,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _passwordHint(passwordController.text),
                    style: TextStyle(
                      fontSize: 12,
                      color: _isStrongPassword(passwordController.text)
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm password',
                  isPassword: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                      activeColor: AppColors.primary,
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to the app terms and privacy policy',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const SizedBox(
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : CustomButton(
                        text: 'Register',
                        onPressed: _handleRegister,
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: AppStyles.bodyText,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('Sign In', style: AppStyles.linkText),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

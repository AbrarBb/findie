import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import './otp_login_widget.dart';

class LoginTabWidget extends StatefulWidget {
  final bool isLoading;
  final Function(bool) onLoadingChanged;

  const LoginTabWidget({
    super.key,
    required this.isLoading,
    required this.onLoadingChanged,
  });

  @override
  State<LoginTabWidget> createState() => _LoginTabWidgetState();
}

class _LoginTabWidgetState extends State<LoginTabWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isEmailLogin = true;
  String? _emailError;
  String? _passwordError;

  // Mock credentials
  final Map<String, String> _mockCredentials = {
    "admin@findie.com": "admin123",
    "user@findie.com": "user123",
    "student@university.edu": "student123",
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _emailError == null &&
        _passwordError == null;
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$')
          .hasMatch(value)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;

    widget.onLoadingChanged(true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_mockCredentials.containsKey(email) &&
        _mockCredentials[email] == password) {
      // Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home-screen');
      }
    } else {
      // Error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Invalid credentials. Try: admin@findie.com / admin123'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    widget.onLoadingChanged(false);
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Text('Password reset link will be sent to your email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reset link sent to your email')),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isEmailLogin ? _buildEmailLogin() : _buildOTPLogin();
  }

  Widget _buildEmailLogin() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmailField(),
          SizedBox(height: 3.h),
          _buildPasswordField(),
          SizedBox(height: 2.h),
          _buildForgotPasswordButton(),
          SizedBox(height: 4.h),
          _buildLoginButton(),
          SizedBox(height: 3.h),
          _buildOTPToggle(),
        ],
      ),
    );
  }

  Widget _buildOTPLogin() {
    return OTPLoginWidget(
      isLoading: widget.isLoading,
      onLoadingChanged: widget.onLoadingChanged,
      onBackToEmail: () => setState(() => _isEmailLogin = true),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: _validateEmail,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'email',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            errorText: _emailError,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          onChanged: _validatePassword,
          onFieldSubmitted: (_) => _handleLogin(),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
              icon: CustomIconWidget(
                iconName: _isPasswordVisible ? 'visibility_off' : 'visibility',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            errorText: _passwordError,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _handleForgotPassword,
        child: Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isFormValid && !widget.isLoading) ? _handleLogin : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
        child: widget.isLoading
            ? SizedBox(
                height: 5.w,
                width: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text('Login'),
      ),
    );
  }

  Widget _buildOTPToggle() {
    return Center(
      child: TextButton(
        onPressed: () => setState(() => _isEmailLogin = false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'sms',
              color: Theme.of(context).colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Login with OTP',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

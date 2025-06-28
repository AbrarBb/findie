import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RegisterTabWidget extends StatefulWidget {
  final bool isLoading;
  final Function(bool) onLoadingChanged;

  const RegisterTabWidget({
    super.key,
    required this.isLoading,
    required this.onLoadingChanged,
  });

  @override
  State<RegisterTabWidget> createState() => _RegisterTabWidgetState();
}

class _RegisterTabWidgetState extends State<RegisterTabWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _acceptTerms &&
        _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Name is required';
      } else if (value.length < 2) {
        _nameError = 'Name must be at least 2 characters';
      } else {
        _nameError = null;
      }
    });
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
      } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
        _passwordError =
            'Password must contain uppercase, lowercase and number';
      } else {
        _passwordError = null;
      }
    });

    // Re-validate confirm password if it has value
    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword(_confirmPasswordController.text);
    }
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  Future<void> _handleRegister() async {
    if (!_isFormValid) return;

    widget.onLoadingChanged(true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully! Please login.'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );

      // Clear form
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      setState(() {
        _acceptTerms = false;
      });
    }

    widget.onLoadingChanged(false);
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Text(
            'By using Findie, you agree to:\n\n'
            '• Provide accurate information when posting items\n'
            '• Respect other users and maintain community standards\n'
            '• Not misuse the platform for fraudulent activities\n'
            '• Allow us to process your data as per our Privacy Policy\n'
            '• Verify your identity when required\n\n'
            'We reserve the right to remove posts and suspend accounts that violate these terms.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameField(),
          SizedBox(height: 3.h),
          _buildEmailField(),
          SizedBox(height: 3.h),
          _buildPasswordField(),
          SizedBox(height: 3.h),
          _buildConfirmPasswordField(),
          SizedBox(height: 3.h),
          _buildTermsCheckbox(),
          SizedBox(height: 4.h),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          onChanged: _validateName,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'person',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            errorText: _nameError,
          ),
        ),
      ],
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
          textInputAction: TextInputAction.next,
          onChanged: _validatePassword,
          decoration: InputDecoration(
            hintText: 'Create a strong password',
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

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          textInputAction: TextInputAction.done,
          onChanged: _validateConfirmPassword,
          onFieldSubmitted: (_) => _handleRegister(),
          decoration: InputDecoration(
            hintText: 'Confirm your password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              icon: CustomIconWidget(
                iconName:
                    _isConfirmPasswordVisible ? 'visibility_off' : 'visibility',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            errorText: _confirmPasswordError,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) => setState(() => _acceptTerms = value ?? false),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
            child: Padding(
              padding: EdgeInsets.only(top: 2.w),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(text: 'I agree to the '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: _showTermsDialog,
                        child: Text(
                          'Terms & Conditions',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                      ),
                    ),
                    TextSpan(text: ' and '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: _showTermsDialog,
                        child: Text(
                          'Privacy Policy',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isFormValid && !widget.isLoading) ? _handleRegister : null,
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
            : Text('Create Account'),
      ),
    );
  }
}

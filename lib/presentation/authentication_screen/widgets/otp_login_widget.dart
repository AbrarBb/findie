import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class OTPLoginWidget extends StatefulWidget {
  final bool isLoading;
  final Function(bool) onLoadingChanged;
  final VoidCallback onBackToEmail;

  const OTPLoginWidget({
    super.key,
    required this.isLoading,
    required this.onLoadingChanged,
    required this.onBackToEmail,
  });

  @override
  State<OTPLoginWidget> createState() => _OTPLoginWidgetState();
}

class _OTPLoginWidgetState extends State<OTPLoginWidget> {
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (index) => FocusNode());
  String _selectedCountryCode = '+1';
  bool _isOTPSent = false;
  int _resendTimer = 30;
  String? _phoneError;

  // Mock phone numbers for testing
  final List<String> _mockPhoneNumbers = [
    '+1234567890',
    '+1987654321',
    '+1555123456',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _validatePhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneError = 'Phone number is required';
      } else if (value.length < 10) {
        _phoneError = 'Please enter a valid phone number';
      } else {
        _phoneError = null;
      }
    });
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty || _phoneError != null) return;

    widget.onLoadingChanged(true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final fullPhone = _selectedCountryCode + _phoneController.text;

    if (_mockPhoneNumbers.contains(fullPhone)) {
      setState(() {
        _isOTPSent = true;
        _resendTimer = 30;
      });
      _startResendTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to $fullPhone'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid phone number. Try: +1234567890'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    widget.onLoadingChanged(false);
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startResendTimer();
      }
    });
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    widget.onLoadingChanged(true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock OTP verification (accept 123456 as valid OTP)
    if (otp == '123456') {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP. Use: 123456'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    widget.onLoadingChanged(false);
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all fields are filled
    if (index == 5 && value.isNotEmpty) {
      final otp = _otpControllers.map((controller) => controller.text).join();
      if (otp.length == 6) {
        _verifyOTP();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(),
        SizedBox(height: 2.h),
        !_isOTPSent ? _buildPhoneInput() : _buildOTPInput(),
      ],
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: widget.onBackToEmail,
      icon: CustomIconWidget(
        iconName: 'arrow_back',
        color: Theme.of(context).colorScheme.primary,
        size: 5.w,
      ),
      label: Text(
        'Back to Email Login',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            _buildCountryCodePicker(),
            SizedBox(width: 3.w),
            Expanded(child: _buildPhoneField()),
          ],
        ),
        SizedBox(height: 4.h),
        _buildSendOTPButton(),
      ],
    );
  }

  Widget _buildCountryCodePicker() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(3.w),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountryCode,
          items: [
            DropdownMenuItem(value: '+1', child: Text('+1 🇺🇸')),
            DropdownMenuItem(value: '+44', child: Text('+44 🇬🇧')),
            DropdownMenuItem(value: '+91', child: Text('+91 🇮🇳')),
          ],
          onChanged: (value) => setState(() => _selectedCountryCode = value!),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      onChanged: _validatePhone,
      onFieldSubmitted: (_) => _sendOTP(),
      decoration: InputDecoration(
        hintText: 'Enter phone number',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'phone',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
        ),
        errorText: _phoneError,
      ),
    );
  }

  Widget _buildSendOTPButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_phoneController.text.isNotEmpty &&
                _phoneError == null &&
                !widget.isLoading)
            ? _sendOTP
            : null,
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
            : Text('Send OTP'),
      ),
    );
  }

  Widget _buildOTPInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        Text(
          'We sent a 6-digit code to $_selectedCountryCode${_phoneController.text}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        SizedBox(height: 3.h),
        _buildOTPFields(),
        SizedBox(height: 3.h),
        _buildResendButton(),
        SizedBox(height: 4.h),
        _buildVerifyButton(),
      ],
    );
  }

  Widget _buildOTPFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 12.w,
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _onOTPChanged(value, index),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.symmetric(vertical: 2.h),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendButton() {
    return Center(
      child: _resendTimer > 0
          ? Text(
              'Resend OTP in ${_resendTimer}s',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          : TextButton(
              onPressed: _sendOTP,
              child: Text('Resend OTP'),
            ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !widget.isLoading ? _verifyOTP : null,
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
            : Text('Verify & Login'),
      ),
    );
  }
}

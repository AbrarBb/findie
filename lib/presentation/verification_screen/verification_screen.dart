import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/ocr_service.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  
  File? _selectedImage;
  bool _isUploading = false;
  bool _isProcessing = false;
  String? _extractedText;
  String? _verificationStatus;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _processImage();
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _extractedText = null;
    });

    try {
      final ocrService = ref.read(ocrServiceProvider);
      final extractedText = await ocrService.extractTextFromImage(_selectedImage!);
      
      setState(() {
        _extractedText = extractedText;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final storageService = ref.read(storageServiceProvider);
      final authService = ref.read(authServiceProvider);
      final user = authService.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload image to storage
      final imageUrl = await storageService.uploadImage(
        file: _selectedImage!,
        bucket: 'verification-docs',
        folder: user.id,
      );

      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      // Create verification record
      final response = await SupabaseConfig.client
          .from('verifications')
          .insert({
            'user_id': user.id,
            'id_image_url': imageUrl,
            'extracted_name': _nameController.text.trim(),
            'extracted_dob': _dobController.text.trim(),
            'status': 'pending',
          })
          .select()
          .single();

      // Call verification edge function
      final verificationResponse = await SupabaseConfig.client.functions.invoke(
        'verify-identity',
        body: {
          'name': _nameController.text.trim(),
          'dob': _dobController.text.trim(),
          'extractedText': _extractedText ?? '',
          'userId': user.id,
        },
      );

      if (verificationResponse.data['success'] == true) {
        setState(() {
          _verificationStatus = verificationResponse.data['isVerified'] 
              ? 'approved' 
              : 'rejected';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(verificationResponse.data['message']),
              backgroundColor: verificationResponse.data['isVerified']
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.error,
            ),
          );
        }

        if (verificationResponse.data['isVerified']) {
          // Navigate back to profile
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Identity Verification'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Verification Instructions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '1. Take a clear photo of your government-issued ID\n'
                      '2. Enter your name and date of birth exactly as shown on ID\n'
                      '3. Our system will verify the information automatically\n'
                      '4. Verification typically takes a few minutes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // Image Upload Section
              Text(
                'Upload ID Document',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 2.h),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 25.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(3.w),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'camera_alt',
                              color: Theme.of(context).colorScheme.primary,
                              size: 48,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Tap to take photo of ID',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Government ID, Student ID, or Driver\'s License',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),

              if (_isProcessing) ...[
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 3.w),
                      Text('Processing image...'),
                    ],
                  ),
                ),
              ],

              if (_extractedText != null) ...[
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Extracted Text:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _extractedText!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 4.h),

              // Form Fields
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 2.h),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter name as shown on ID',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'person',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),

              SizedBox(height: 3.h),

              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: 'YYYY-MM-DD or MM/DD/YYYY',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'calendar_today',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Date of birth is required';
                  }
                  return null;
                },
              ),

              SizedBox(height: 6.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedImage != null && !_isUploading) 
                      ? _submitVerification 
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: _isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text('Verifying...'),
                          ],
                        )
                      : Text('Submit for Verification'),
                ),
              ),

              if (_verificationStatus != null) ...[
                SizedBox(height: 3.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: _verificationStatus == 'approved'
                        ? Theme.of(context).colorScheme.tertiaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: _verificationStatus == 'approved' 
                            ? 'check_circle' 
                            : 'error',
                        color: _verificationStatus == 'approved'
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.error,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _verificationStatus == 'approved'
                            ? 'Verification Successful!'
                            : 'Verification Failed',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _verificationStatus == 'approved'
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _verificationStatus == 'approved'
                            ? 'Your account has been verified. You can now contact item owners directly.'
                            : 'Please check that your information matches your ID exactly and try again.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
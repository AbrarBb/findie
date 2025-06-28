import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_selector_widget.dart';
import './widgets/image_picker_widget.dart';
import './widgets/location_picker_widget.dart';
import './widgets/ocr_tags_widget.dart';

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLostItem = true;
  bool _isProcessingOCR = false;
  bool _isPosting = false;
  bool _showAdvancedOptions = false;
  double _uploadProgress = 0.0;

  List<File> _selectedImages = [];
  String _selectedCategory = '';
  String _selectedLocation = '';
  DateTime _selectedDate = DateTime.now();
  List<String> _ocrTags = [];
  List<String> _extractedText = [];

  // Mock OCR extracted text
  final List<String> _mockOCRResults = [
    "iPhone 13 Pro",
    "Apple",
    "Blue case",
    "Cracked screen",
    "Student ID inside",
    "Library card",
    "Headphones",
    "Black wallet",
    "Credit cards",
    "Driver license"
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSave();
  }

  void _startAutoSave() {
    // Auto-save draft every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _saveDraft();
        _startAutoSave();
      }
    });
  }

  void _saveDraft() {
    // Mock draft saving
    if (_titleController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft saved automatically'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _onImagesSelected(List<File> images) {
    setState(() {
      _selectedImages = images;
      if (images.isNotEmpty) {
        _processOCR();
      }
    });
  }

  void _processOCR() async {
    setState(() {
      _isProcessingOCR = true;
      _ocrTags.clear();
      _extractedText.clear();
    });

    // Simulate OCR processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessingOCR = false;
        _extractedText = _mockOCRResults.take(3).toList();
        _ocrTags = _mockOCRResults.take(5).toList();
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onLocationSelected(String location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _onTagSelected(String tag) {
    if (!_descriptionController.text.contains(tag)) {
      final currentText = _descriptionController.text;
      final newText = currentText.isEmpty ? tag : '$currentText, $tag';
      _descriptionController.text = newText;
    }
  }

  bool _canPost() {
    return _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _selectedImages.isNotEmpty &&
        _selectedCategory.isNotEmpty &&
        _selectedLocation.isNotEmpty;
  }

  void _postItem() async {
    if (!_canPost()) return;

    setState(() {
      _isPosting = true;
      _uploadProgress = 0.0;
    });

    // Simulate upload progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _uploadProgress = i / 100;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isPosting = false;
      });

      // Show success dialog
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.tertiary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Posted Successfully!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        content: Text(
          'Your ${_isLostItem ? 'lost' : 'found'} item has been posted and is now visible to the community.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/home-screen');
            },
            child: const Text('View Feed'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/home-screen');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Post Item',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'close',
            color: Theme.of(context).appBarTheme.foregroundColor!,
            size: 24,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _canPost() && !_isPosting ? _postItem : null,
            child: _isPosting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Text(
                    'Post',
                    style: TextStyle(
                      color: _canPost()
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).disabledColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Section
              ImagePickerWidget(
                selectedImages: _selectedImages,
                onImagesSelected: _onImagesSelected,
              ),

              SizedBox(height: 6.h),

              // Lost/Found Toggle
              _buildLostFoundToggle(),

              SizedBox(height: 4.h),

              // Title Input
              _buildTitleInput(),

              SizedBox(height: 3.h),

              // Description Input
              _buildDescriptionInput(),

              SizedBox(height: 3.h),

              // Category Selector
              CategorySelectorWidget(
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
              ),

              SizedBox(height: 3.h),

              // Location Picker
              LocationPickerWidget(
                selectedLocation: _selectedLocation,
                onLocationSelected: _onLocationSelected,
              ),

              SizedBox(height: 3.h),

              // OCR Tags
              if (_selectedImages.isNotEmpty) ...[
                OCRTagsWidget(
                  isProcessing: _isProcessingOCR,
                  tags: _ocrTags,
                  extractedText: _extractedText,
                  onTagSelected: _onTagSelected,
                ),
                SizedBox(height: 3.h),
              ],

              // Date Picker
              _buildDatePicker(),

              SizedBox(height: 3.h),

              // Advanced Options
              _buildAdvancedOptions(),

              SizedBox(height: 6.h),

              // Post Button
              _buildPostButton(),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLostFoundToggle() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLostItem = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                decoration: BoxDecoration(
                  color: _isLostItem
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'search',
                      color: _isLostItem
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium!.color!,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Lost',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: _isLostItem
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLostItem = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                decoration: BoxDecoration(
                  color: !_isLostItem
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'inventory',
                      color: !_isLostItem
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium!.color!,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Found',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: !_isLostItem
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _titleController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: _isLostItem ? 'What did you lose?' : 'What did you find?',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'title',
                color: Theme.of(context).textTheme.bodyMedium!.color!,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Provide more details about the item...',
            alignLabelWithHint: true,
            prefixIcon: Padding(
              padding: EdgeInsets.only(top: 3.w, left: 3.w, right: 3.w),
              child: CustomIconWidget(
                iconName: 'description',
                color: Theme.of(context).textTheme.bodyMedium!.color!,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date ${_isLostItem ? 'Lost' : 'Found'}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () =>
              setState(() => _showAdvancedOptions = !_showAdvancedOptions),
          child: Row(
            children: [
              Text(
                'Advanced Options',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              CustomIconWidget(
                iconName: _showAdvancedOptions ? 'expand_less' : 'expand_more',
                color: Theme.of(context).textTheme.bodyMedium!.color!,
                size: 20,
              ),
            ],
          ),
        ),
        if (_showAdvancedOptions) ...[
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'notifications',
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Contact Preferences',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                CheckboxListTile(
                  title: const Text('Allow direct messages'),
                  value: true,
                  onChanged: (value) {},
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Email notifications'),
                  value: false,
                  onChanged: (value) {},
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Auto-expire in 14 days',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _canPost() && !_isPosting ? _postItem : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canPost()
              ? Theme.of(context).primaryColor
              : Theme.of(context).disabledColor,
        ),
        child: _isPosting
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      value: _uploadProgress,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${(_uploadProgress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'publish',
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Post Item',
                    style: Theme.of(context)
                        .elevatedButtonTheme
                        .style!
                        .textStyle!
                        .resolve({})!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

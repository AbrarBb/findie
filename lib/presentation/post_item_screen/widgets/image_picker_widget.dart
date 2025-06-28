import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ImagePickerWidget extends StatefulWidget {
  final List<File> selectedImages;
  final Function(List<File>) onImagesSelected;

  const ImagePickerWidget({
    super.key,
    required this.selectedImages,
    required this.onImagesSelected,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Add Photos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    icon: 'camera_alt',
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildImageSourceOption(
                    icon: 'photo_library',
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _pickImageFromCamera() {
    // Mock camera image selection
    final mockImagePath =
        '/mock/camera/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final mockFile = File(mockImagePath);

    final updatedImages = List<File>.from(widget.selectedImages)..add(mockFile);
    widget.onImagesSelected(updatedImages);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo captured from camera'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pickImageFromGallery() {
    // Mock gallery image selection
    final mockImagePaths = [
      '/mock/gallery/image_1.jpg',
      '/mock/gallery/image_2.jpg',
      '/mock/gallery/image_3.jpg',
    ];

    final mockFiles = mockImagePaths.map((path) => File(path)).toList();
    final updatedImages = List<File>.from(widget.selectedImages)
      ..addAll(mockFiles);
    widget.onImagesSelected(updatedImages);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${mockFiles.length} photos selected from gallery'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeImage(int index) {
    final updatedImages = List<File>.from(widget.selectedImages)
      ..removeAt(index);
    widget.onImagesSelected(updatedImages);

    if (_currentImageIndex >= updatedImages.length &&
        updatedImages.isNotEmpty) {
      setState(() {
        _currentImageIndex = updatedImages.length - 1;
      });
      _pageController.animateToPage(
        _currentImageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showFullScreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          images: widget.selectedImages,
          initialIndex: index,
          onImageRemoved: _removeImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),

        // Main image display area
        Container(
          width: double.infinity,
          height: 30.h,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: widget.selectedImages.isEmpty
              ? _buildEmptyImagePicker()
              : _buildImageDisplay(),
        ),

        // Image thumbnails
        if (widget.selectedImages.isNotEmpty) ...[
          SizedBox(height: 2.h),
          _buildImageThumbnails(),
        ],
      ],
    );
  }

  Widget _buildEmptyImagePicker() {
    return InkWell(
      onTap: _showImageSourceDialog,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomIconWidget(
                iconName: 'add_a_photo',
                color: Theme.of(context).primaryColor,
                size: 48,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Add Photos',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Tap to add photos from camera or gallery',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Stack(
      children: [
        // Main image viewer
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: widget.selectedImages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _showFullScreenImage(index),
              child: Container(
                margin: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Mock image display
                      Container(
                        color: Colors.grey.shade300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'image',
                              color: Colors.grey.shade600,
                              size: 48,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Image ${index + 1}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit overlay
                      Positioned(
                        bottom: 2.w,
                        right: 2.w,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'edit',
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Remove button
        Positioned(
          top: 2.w,
          right: 2.w,
          child: GestureDetector(
            onTap: () => _removeImage(_currentImageIndex),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),

        // Add more button
        Positioned(
          top: 2.w,
          left: 2.w,
          child: GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),

        // Page indicator
        if (widget.selectedImages.length > 1)
          Positioned(
            bottom: 2.w,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.selectedImages.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  width: 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    color: index == _currentImageIndex
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageThumbnails() {
    return SizedBox(
      height: 15.w,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.selectedImages.length) {
            // Add more button
            return GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 15.w,
                height: 15.w,
                margin: EdgeInsets.only(left: 2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  ),
                ),
                child: CustomIconWidget(
                  iconName: 'add',
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
            );
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentImageIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 15.w,
              height: 15.w,
              margin: EdgeInsets.only(left: index == 0 ? 0 : 2.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: index == _currentImageIndex
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  color: Colors.grey.shade300,
                  child: CustomIconWidget(
                    iconName: 'image',
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<File> images;
  final int initialIndex;
  final Function(int) onImageRemoved;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
    required this.onImageRemoved,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} of ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              widget.onImageRemoved(_currentIndex);
              Navigator.pop(context);
            },
            icon: CustomIconWidget(
              iconName: 'delete',
              color: Colors.white,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              // Mock edit functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality would open here'),
                  backgroundColor: Colors.grey,
                ),
              );
            },
            icon: CustomIconWidget(
              iconName: 'edit',
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Center(
            child: Container(
              width: double.infinity,
              height: 50.h,
              color: Colors.grey.shade800,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'image',
                    color: Colors.grey.shade400,
                    size: 64,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Full Screen Image ${index + 1}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

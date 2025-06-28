import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class OCRTagsWidget extends StatelessWidget {
  final bool isProcessing;
  final List<String> tags;
  final List<String> extractedText;
  final Function(String) onTagSelected;

  const OCRTagsWidget({
    super.key,
    required this.isProcessing,
    required this.tags,
    required this.extractedText,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'auto_awesome',
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'AI Suggestions',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            if (isProcessing) ...[
              SizedBox(width: 2.w),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 2.h),
        if (isProcessing)
          _buildProcessingState(context)
        else if (tags.isNotEmpty || extractedText.isNotEmpty)
          _buildSuggestionsContent(context)
        else
          _buildEmptyState(context),
      ],
    );
  }

  Widget _buildProcessingState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'psychology',
            color: Theme.of(context).primaryColor,
            size: 32,
          ),
          SizedBox(height: 2.h),
          Text(
            'Analyzing image...',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'AI is extracting text and generating suggestions',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsContent(BuildContext context) {
    return Container(
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
          if (extractedText.isNotEmpty) ...[
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'text_fields',
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Extracted Text',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Text(
                extractedText.join(', '),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ),
            SizedBox(height: 3.h),
          ],
          if (tags.isNotEmpty) ...[
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'local_offer',
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Suggested Tags',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Text(
                  'Tap to add',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: tags.map((tag) => _buildTagChip(context, tag)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    return GestureDetector(
      onTap: () => onTagSelected(tag),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'add',
              color: Theme.of(context).primaryColor,
              size: 14,
            ),
            SizedBox(width: 1.w),
            Text(
              tag,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
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
        children: [
          CustomIconWidget(
            iconName: 'image_search',
            color: Theme.of(context).textTheme.bodyMedium!.color!,
            size: 32,
          ),
          SizedBox(height: 2.h),
          Text(
            'Add photos to get AI suggestions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 1.h),
          Text(
            'Our AI will analyze your images and suggest relevant tags and descriptions',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

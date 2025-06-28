import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class SearchResultItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final String searchQuery;
  final VoidCallback onTap;

  const SearchResultItemWidget({
    super.key,
    required this.item,
    required this.searchQuery,
    required this.onTap,
  });

  Widget _buildHighlightedText(String text, String query, TextStyle? style) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style?.copyWith(
          backgroundColor:
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
          fontWeight: FontWeight.w600,
        ),
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildOCRHighlight(BuildContext context, String extractedText, String query) {
    if (query.isEmpty ||
        !extractedText.toLowerCase().contains(query.toLowerCase())) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.successLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.successLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'text_fields',
            color: AppTheme.successLight,
            size: 12,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildHighlightedText(
              'OCR: $extractedText',
              query,
              Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.successLight,
                    fontSize: 10,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLostItem = (item['type'] as String) == 'Lost';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImageWidget(
                imageUrl: item['image'] as String,
                width: 20.w,
                height: 20.w,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(width: 3.w),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item type badge and title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLostItem
                              ? AppTheme.errorLight.withValues(alpha: 0.1)
                              : AppTheme.successLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['type'] as String,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isLostItem
                                        ? AppTheme.errorLight
                                        : AppTheme.successLight,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item['distance'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Title with highlighting
                  _buildHighlightedText(
                    item['title'] as String,
                    searchQuery,
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),

                  SizedBox(height: 0.5.h),

                  // Description with highlighting
                  _buildHighlightedText(
                    item['description'] as String,
                    searchQuery,
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),

                  // OCR text highlight if matches
                  _buildOCRHighlight(
                      context, item['extractedText'] as String, searchQuery),

                  SizedBox(height: 1.h),

                  // Location and date
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item['building'] as String,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['date'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
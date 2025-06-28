import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ItemInfoSectionWidget extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final bool isDescriptionExpanded;
  final VoidCallback onToggleDescription;

  const ItemInfoSectionWidget({
    super.key,
    required this.itemData,
    required this.isDescriptionExpanded,
    required this.onToggleDescription,
  });

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Color _getTypeColor(String type, BuildContext context) {
    return type.toLowerCase() == 'lost'
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.tertiary;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.phone_android;
      case 'clothing':
        return Icons.checkroom;
      case 'accessories':
        return Icons.watch;
      case 'books':
        return Icons.book;
      case 'keys':
        return Icons.key;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = itemData["description"] as String? ?? "";
    final ocrText = itemData["ocrText"] as String? ?? "";
    final shouldShowMore = description.length > 150;
    final displayDescription = isDescriptionExpanded || !shouldShowMore
        ? description
        : '${description.substring(0, 150)}...';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          // Title and Type Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  itemData["title"] ?? "Unknown Item",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getTypeColor(itemData["type"] ?? "lost", context)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getTypeColor(itemData["type"] ?? "lost", context),
                    width: 1,
                  ),
                ),
                child: Text(
                  itemData["type"] ?? "Lost",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color:
                            _getTypeColor(itemData["type"] ?? "lost", context),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Category and Location
          Row(
            children: [
              CustomIconWidget(
                iconName: _getCategoryIcon(itemData["category"] ?? "")
                    .codePoint
                    .toString(),
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                itemData["category"] ?? "Unknown",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(width: 4.w),
              CustomIconWidget(
                iconName: 'location_on',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  itemData["location"] ?? "Unknown Location",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Posted Date
          GestureDetector(
            onTap: () {
              final exactTime = itemData["postedDate"] as DateTime?;
              if (exactTime != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Posted on ${exactTime.toString().split('.')[0]}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  _getRelativeTime(itemData["postedDate"] ?? DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Description Section
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            displayDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
          ),
          if (shouldShowMore)
            GestureDetector(
              onTap: onToggleDescription,
              child: Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Text(
                  isDescriptionExpanded ? 'Show Less' : 'Show More',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),

          // OCR Text Section
          if (ocrText.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              'Extracted Text',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'text_fields',
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      ocrText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

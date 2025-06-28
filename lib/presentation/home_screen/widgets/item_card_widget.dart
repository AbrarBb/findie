import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ItemCardWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ItemCardWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime datePosted = item["datePosted"] as DateTime;
    final String timeAgo = _getTimeAgo(datePosted);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildContentSection(timeAgo),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Hero(
        tag: 'item_image_${item["id"]}',
        child: CustomImageWidget(
          imageUrl: item["imageUrl"] as String,
          width: double.infinity,
          height: 25.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContentSection(String timeAgo) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndCategory(),
          SizedBox(height: 1.h),
          _buildDescription(),
          SizedBox(height: 1.5.h),
          _buildLocationAndDate(timeAgo),
          SizedBox(height: 1.h),
          _buildTags(),
        ],
      ),
    );
  }

  Widget _buildTitleAndCategory() {
    return Row(
      children: [
        Expanded(
          child: Text(
            item["title"] as String,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 2.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: (item["categoryColor"] as Color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: item["categoryIcon"] as String,
                color: item["categoryColor"] as Color,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                item["category"] as String,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: item["categoryColor"] as Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      item["description"] as String,
      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocationAndDate(String timeAgo) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: item["buildingIcon"] as String,
          color:
              AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 16,
        ),
        SizedBox(width: 1.w),
        Expanded(
          child: Text(
            item["building"] as String,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          timeAgo,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    final List<String> tags = (item["tags"] as List).cast<String>();

    return Wrap(
      spacing: 1.w,
      runSpacing: 0.5.h,
      children: tags.take(3).map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            tag,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.8),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

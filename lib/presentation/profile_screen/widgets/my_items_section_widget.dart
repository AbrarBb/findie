import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MyItemsSection extends StatelessWidget {
  final List<Map<String, dynamic>> userItems;
  final Function(Map<String, dynamic>) onItemTap;

  const MyItemsSection({
    super.key,
    required this.userItems,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Items',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full items list
                },
                child: const Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          userItems.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userItems.length > 3 ? 3 : userItems.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final item = userItems[index];
                    return _buildItemCard(context, item);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'inventory_2',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Items Posted Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start by posting your first lost or found item to help the community',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              // Navigate to post item screen
            },
            child: const Text('Post Your First Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item) {
    final String status = item['status'] ?? 'Active';
    final String type = item['type'] ?? 'Lost';

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Active':
        statusColor = Theme.of(context).colorScheme.tertiary;
        statusIcon = Icons.schedule;
        break;
      case 'Matched':
        statusColor = Theme.of(context).colorScheme.tertiary;
        statusIcon = Icons.check_circle;
        break;
      case 'Expired':
        statusColor = Theme.of(context).colorScheme.error;
        statusIcon = Icons.access_time_filled;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.onSurfaceVariant;
        statusIcon = Icons.help;
    }

    return Dismissible(
      key: Key(item['id'].toString()),
      background: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(3.w),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        child: CustomIconWidget(
          iconName: 'edit',
          color: Colors.white,
          size: 6.w,
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(3.w),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 6.w,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context, item);
        } else {
          _showEditOptions(context, item);
          return false;
        }
      },
      child: GestureDetector(
        onTap: () => onItemTap(item),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(3.w),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Item image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3.w),
                  bottomLeft: Radius.circular(3.w),
                ),
                child: CustomImageWidget(
                  imageUrl: item['image'] ?? '',
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.cover,
                ),
              ),

              // Item details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['title'] ?? 'Unknown Item',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: type == 'Lost'
                                  ? Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withValues(alpha: 0.1)
                                  : Theme.of(context)
                                      .colorScheme
                                      .tertiary
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(1.w),
                            ),
                            child: Text(
                              type,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: type == 'Lost'
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        item['category'] ?? 'General',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: statusIcon.codePoint.toString(),
                            color: statusColor,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            status,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(item['postedDate']),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      if (difference < 7) return '${difference}d ago';
      return '${(difference / 7).floor()}w ago';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> item) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Item'),
              content:
                  Text('Are you sure you want to delete "${item['title']}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showEditOptions(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Item Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 3.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'edit',
                  color: Theme.of(context).primaryColor,
                  size: 6.w,
                ),
                title: const Text('Edit Item'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle edit
                },
              ),
              if (item['status'] == 'Active')
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'schedule',
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 6.w,
                  ),
                  title: const Text('Extend Expiry'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle extend
                  },
                ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: Theme.of(context).colorScheme.error,
                  size: 6.w,
                ),
                title: const Text('Delete Item'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, item);
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }
}

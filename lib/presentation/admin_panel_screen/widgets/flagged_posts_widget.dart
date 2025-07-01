import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FlaggedPostsWidget extends ConsumerWidget {
  const FlaggedPostsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock flagged posts - in real app, this would come from a provider
    final flaggedPosts = [
      {
        'id': '1',
        'title': 'Suspicious iPhone Post',
        'description': 'This post seems to be fake or spam...',
        'reporter_email': 'user@example.com',
        'reason': 'Spam or misleading',
        'reported_at': DateTime.now().subtract(Duration(hours: 1)),
        'post_id': 'post-123',
        'status': 'pending',
      },
      {
        'id': '2',
        'title': 'Inappropriate Content',
        'description': 'Contains inappropriate language...',
        'reporter_email': 'another@example.com',
        'reason': 'Inappropriate content',
        'reported_at': DateTime.now().subtract(Duration(hours: 3)),
        'post_id': 'post-456',
        'status': 'pending',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: flaggedPosts.length,
      itemBuilder: (context, index) {
        final report = flaggedPosts[index];
        return Container(
          margin: EdgeInsets.only(bottom: 3.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: CustomIconWidget(
                      iconName: 'report',
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['reason'] as String,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                        Text(
                          'Reported by ${report['reporter_email']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: Text(
                      (report['status'] as String).toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Reported post details
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reported Post',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      report['title'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      report['description'] as String,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _dismissReport(context, report['id'] as String),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 16,
                      ),
                      label: Text('Dismiss'),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewPost(context, report['post_id'] as String),
                      icon: CustomIconWidget(
                        iconName: 'visibility',
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                      label: Text(
                        'View Post',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _removePost(context, report['post_id'] as String),
                      icon: CustomIconWidget(
                        iconName: 'delete',
                        color: Colors.white,
                        size: 16,
                      ),
                      label: Text('Remove'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Timestamp
              Text(
                'Reported ${_getTimeAgo(report['reported_at'] as DateTime)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _dismissReport(BuildContext context, String reportId) async {
    try {
      // In real app, update report status to dismissed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report dismissed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error dismissing report: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _viewPost(BuildContext context, String postId) {
    // Navigate to post details
    Navigator.pushNamed(context, '/item-details-screen');
  }

  void _removePost(BuildContext context, String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Post'),
        content: Text('Are you sure you want to remove this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // In real app, delete the post
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post removed successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing post: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _getTimeAgo(DateTime dateTime) {
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
}
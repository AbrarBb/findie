import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PendingVerificationsWidget extends ConsumerWidget {
  const PendingVerificationsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock pending verifications - in real app, this would come from a provider
    final pendingVerifications = [
      {
        'id': '1',
        'user_name': 'John Doe',
        'user_email': 'john@example.com',
        'submitted_at': DateTime.now().subtract(Duration(hours: 2)),
        'extracted_name': 'John Doe',
        'extracted_dob': '1995-03-15',
        'id_image_url': 'https://example.com/id1.jpg',
      },
      {
        'id': '2',
        'user_name': 'Jane Smith',
        'user_email': 'jane@example.com',
        'submitted_at': DateTime.now().subtract(Duration(hours: 5)),
        'extracted_name': 'Jane Smith',
        'extracted_dob': '1992-08-22',
        'id_image_url': 'https://example.com/id2.jpg',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: pendingVerifications.length,
      itemBuilder: (context, index) {
        final verification = pendingVerifications[index];
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
              // User info
              Row(
                children: [
                  CircleAvatar(
                    radius: 5.w,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: CustomIconWidget(
                      iconName: 'person',
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          verification['user_name'] as String,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          verification['user_email'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      'Pending',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Extracted information
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
                      'Extracted Information',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Text(
                          'Name: ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Text(
                          verification['extracted_name'] as String,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Text(
                          'DOB: ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Text(
                          verification['extracted_dob'] as String,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // ID Image
              GestureDetector(
                onTap: () => _showFullScreenImage(context, verification['id_image_url'] as String),
                child: Container(
                  width: double.infinity,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.w),
                    child: CustomImageWidget(
                      imageUrl: verification['id_image_url'] as String,
                      width: double.infinity,
                      height: 20.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectVerification(context, verification['id'] as String),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: Theme.of(context).colorScheme.error,
                        size: 16,
                      ),
                      label: Text(
                        'Reject',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveVerification(context, verification['id'] as String),
                      icon: CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 16,
                      ),
                      label: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Timestamp
              Text(
                'Submitted ${_getTimeAgo(verification['submitted_at'] as DateTime)}',
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

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text('ID Document'),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CustomImageWidget(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _approveVerification(BuildContext context, String verificationId) async {
    try {
      // In real app, call the verification service
      await SupabaseConfig.client
          .from('verifications')
          .update({'status': 'approved'})
          .eq('id', verificationId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification approved'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving verification: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _rejectVerification(BuildContext context, String verificationId) async {
    try {
      // In real app, call the verification service
      await SupabaseConfig.client
          .from('verifications')
          .update({'status': 'rejected'})
          .eq('id', verificationId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification rejected'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting verification: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
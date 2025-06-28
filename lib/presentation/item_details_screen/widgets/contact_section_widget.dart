import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ContactSectionWidget extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final bool isUserVerified;

  const ContactSectionWidget({
    super.key,
    required this.itemData,
    required this.isUserVerified,
  });

  @override
  Widget build(BuildContext context) {
    final owner = itemData["owner"] as Map<String, dynamic>? ?? {};
    final isExpired = itemData["isExpired"] as bool? ?? false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Owner Info
          Row(
            children: [
              CircleAvatar(
                radius: 6.w,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: owner["avatar"] != null
                    ? ClipOval(
                        child: CustomImageWidget(
                          imageUrl: owner["avatar"],
                          width: 12.w,
                          height: 12.w,
                          fit: BoxFit.cover,
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'person',
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          owner["name"] ?? "Anonymous User",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (owner["isVerified"] == true) ...[
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: 'verified',
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'Item Owner',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Contact Actions
          if (isExpired)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'This post has expired. Contact may not be available.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                ],
              ),
            )
          else if (isUserVerified)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Open anonymous chat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening secure chat...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: CustomIconWidget(
                  iconName: 'chat',
                  color: Theme.of(context)
                          .elevatedButtonTheme
                          .style
                          ?.foregroundColor
                          ?.resolve({}) ??
                      Colors.white,
                  size: 20,
                ),
                label: Text('Message Owner'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            )
          else
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'shield',
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Verification Required',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Verify your account to contact item owners and build trust in the community.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile-screen');
                    },
                    icon: CustomIconWidget(
                      iconName: 'verified_user',
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    label: Text('Verify Account'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

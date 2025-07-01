import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConversationListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;
  final Function(String) onConversationTap;

  const ConversationListWidget({
    super.key,
    required this.conversations,
    required this.onConversationTap,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final post = conversation['post'] as Map<String, dynamic>?;
        final fromUser = conversation['from_user'] as Map<String, dynamic>?;
        final toUser = conversation['to_user'] as Map<String, dynamic>?;
        final message = conversation['message'] as String;
        final timestamp = DateTime.parse(conversation['timestamp'] as String);
        final isRead = conversation['is_read'] as bool? ?? false;

        // Determine the other user (not the current user)
        final otherUser = fromUser; // This would need proper logic based on current user

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          child: ListTile(
            onTap: () => onConversationTap(conversation['post_id'] as String),
            contentPadding: EdgeInsets.all(3.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.w),
            ),
            tileColor: isRead 
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 6.w,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: otherUser?['avatar_url'] != null
                      ? ClipOval(
                          child: CustomImageWidget(
                            imageUrl: otherUser!['avatar_url'],
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
                if (otherUser?['is_verified'] == true)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 1,
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 8,
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    otherUser?['name'] ?? 'Anonymous User',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _getTimeAgo(timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 0.5.h),
                if (post != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: Text(
                      'Re: ${post['title']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                SizedBox(height: 1.h),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: !isRead
                ? Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommentsSectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> comments;

  const CommentsSectionWidget({
    super.key,
    required this.comments,
  });

  @override
  State<CommentsSectionWidget> createState() => _CommentsSectionWidgetState();
}

class _CommentsSectionWidgetState extends State<CommentsSectionWidget> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isCommenting = false;

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

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isCommenting = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isCommenting = false;
        _commentController.clear();
        _commentFocusNode.unfocus();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment posted successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Community Tips & Comments',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        SizedBox(height: 2.h),

        // Add Comment Section
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share a helpful tip or comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  contentPadding: EdgeInsets.all(3.w),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Help the community by sharing useful information',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  ElevatedButton(
                    onPressed: _isCommenting ? null : _submitComment,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isCommenting
                        ? SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text('Post'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 3.h),

        // Comments List
        if (widget.comments.isEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'chat_bubble_outline',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 48,
                ),
                SizedBox(height: 2.h),
                Text(
                  'No comments yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Be the first to share a helpful tip!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: widget.comments.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final comment = widget.comments[index];
              return Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 4.w,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: comment["avatar"] != null
                              ? ClipOval(
                                  child: CustomImageWidget(
                                    imageUrl: comment["avatar"],
                                    width: 8.w,
                                    height: 8.w,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : CustomIconWidget(
                                  iconName: 'person',
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16,
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
                                    comment["user"] ?? "Anonymous",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  if (comment["isVerified"] == true) ...[
                                    SizedBox(width: 1.w),
                                    CustomIconWidget(
                                      iconName: 'verified',
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 14,
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                _getRelativeTime(
                                    comment["timestamp"] ?? DateTime.now()),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: CustomIconWidget(
                            iconName: 'more_vert',
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          onSelected: (value) {
                            if (value == 'report') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Comment reported for review'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'report',
                              child: Text('Report'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      comment["comment"] ?? "",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

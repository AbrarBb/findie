import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/post_service.dart';
import './widgets/admin_stats_widget.dart';
import './widgets/pending_verifications_widget.dart';
import './widgets/flagged_posts_widget.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Posts'),
            Tab(text: 'Verifications'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                AdminStatsWidget(),
                SizedBox(height: 3.h),
                _buildQuickActions(),
              ],
            ),
          ),

          // Posts Tab
          _buildPostsManagement(),

          // Verifications Tab
          PendingVerificationsWidget(),

          // Reports Tab
          FlaggedPostsWidget(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Run Auto-Expire',
        'subtitle': 'Remove expired posts',
        'icon': 'schedule',
        'color': Theme.of(context).colorScheme.primary,
        'onTap': _runAutoExpire,
      },
      {
        'title': 'Backup Data',
        'subtitle': 'Export database',
        'icon': 'backup',
        'color': Theme.of(context).colorScheme.tertiary,
        'onTap': _backupData,
      },
      {
        'title': 'Send Notifications',
        'subtitle': 'Bulk notifications',
        'icon': 'notifications',
        'color': Theme.of(context).colorScheme.secondary,
        'onTap': _sendNotifications,
      },
      {
        'title': 'Generate Report',
        'subtitle': 'Analytics report',
        'icon': 'analytics',
        'color': Theme.of(context).colorScheme.error,
        'onTap': _generateReport,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return GestureDetector(
              onTap: action['onTap'] as VoidCallback,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: CustomIconWidget(
                        iconName: action['icon'] as String,
                        color: action['color'] as Color,
                        size: 24,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      action['title'] as String,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      action['subtitle'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPostsManagement() {
    final postsAsync = ref.watch(postsProvider({}));

    return postsAsync.when(
      data: (posts) => ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Container(
            margin: EdgeInsets.only(bottom: 2.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        post.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: post.isFound
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                      child: Text(
                        post.isFound ? 'Found' : 'Lost',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: post.isFound
                                  ? Theme.of(context).colorScheme.onTertiaryContainer
                                  : Theme.of(context).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  post.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      'Posted: ${post.timeAgo}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () => _deletePost(post.id),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _extendPost(post.id),
                      child: Text('Extend'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  void _runAutoExpire() async {
    try {
      final response = await SupabaseConfig.client.functions.invoke('auto-expire-posts');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auto-expire completed: ${response.data['deletedCount']} posts removed'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error running auto-expire: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _backupData() {
    // Implement data backup functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup functionality would be implemented here')),
    );
  }

  void _sendNotifications() {
    // Implement bulk notification functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification functionality would be implemented here')),
    );
  }

  void _generateReport() {
    // Implement report generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report generation would be implemented here')),
    );
  }

  void _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post?'),
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
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final postService = ref.read(postServiceProvider);
        await postService.deletePost(postId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting post: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _extendPost(String postId) async {
    try {
      final postService = ref.read(postServiceProvider);
      await postService.extendPostExpiry(postId, days: 7);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post extended by 7 days')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error extending post: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
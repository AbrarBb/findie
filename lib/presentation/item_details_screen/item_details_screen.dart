import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/comments_section_widget.dart';
import './widgets/contact_section_widget.dart';
import './widgets/hero_image_section_widget.dart';
import './widgets/item_info_section_widget.dart';
import './widgets/similar_items_section_widget.dart';

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isDescriptionExpanded = false;
  final bool _isUserVerified = true; // Mock verification status

  // Mock item data
  final Map<String, dynamic> itemData = {
    "id": 1,
    "title": "Lost iPhone 14 Pro",
    "description":
        "Lost my iPhone 14 Pro in Space Gray color near the library. It has a clear case with a small crack on the bottom right corner. The phone contains important work documents and family photos. Last seen around 3 PM near the main entrance. Please contact if found - reward offered!",
    "ocrText": "iPhone 14 Pro, Space Gray, 128GB, Model A2894",
    "category": "Electronics",
    "location": "Main Library",
    "type": "Lost",
    "postedDate": DateTime.now().subtract(const Duration(hours: 2)),
    "isExpired": false,
    "images": [
      "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800&q=80",
      "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800&q=80",
      "https://images.unsplash.com/photo-1580910051074-3eb694886505?w=800&q=80"
    ],
    "owner": {
      "name": "Sarah Johnson",
      "isVerified": true,
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png"
    }
  };

  final List<Map<String, dynamic>> similarItems = [
    {
      "id": 2,
      "title": "Found iPhone 13",
      "type": "Found",
      "location": "Student Center",
      "image":
          "https://images.unsplash.com/photo-1556656793-08538906a9f8?w=400&q=80",
      "postedDate": DateTime.now().subtract(const Duration(hours: 5))
    },
    {
      "id": 3,
      "title": "Lost Samsung Galaxy",
      "type": "Lost",
      "location": "Engineering Building",
      "image":
          "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80",
      "postedDate": DateTime.now().subtract(const Duration(days: 1))
    }
  ];

  final List<Map<String, dynamic>> comments = [
    {
      "id": 1,
      "user": "Mike Chen",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "comment":
          "I saw someone with a similar phone near the cafeteria around that time. You might want to check there too.",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 30)),
      "isVerified": true
    },
    {
      "id": 2,
      "user": "Emma Wilson",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "comment":
          "Have you tried using Find My iPhone? Sometimes it helps even when the phone is offline.",
      "timestamp": DateTime.now().subtract(const Duration(hours: 1)),
      "isVerified": false
    }
  ];

  void _showReportBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Item',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 2.h),
                  _buildReportOption('Spam or misleading', Icons.report),
                  _buildReportOption('Inappropriate content', Icons.block),
                  _buildReportOption('Duplicate post', Icons.copy),
                  _buildReportOption('Other', Icons.more_horiz),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(String title, IconData icon) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon.codePoint.toString(),
        color: Theme.of(context).colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report submitted for review'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 30.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  Text(
                    'Share Item',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareOption('Copy Link', Icons.link),
                      _buildShareOption('Message', Icons.message),
                      _buildShareOption('Email', Icons.email),
                      _buildShareOption('More', Icons.share),
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

  Widget _buildShareOption(String title, IconData icon) {
    return Column(
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: icon.codePoint.toString(),
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 40.h,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: Container(
              margin: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: CustomIconWidget(
                    iconName: 'share',
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _showShareBottomSheet,
                ),
              ),
              Container(
                margin: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: CustomIconWidget(
                    iconName: 'more_vert',
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _showReportBottomSheet,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: HeroImageSectionWidget(
                images: (itemData["images"] as List).cast<String>(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemInfoSectionWidget(
                  itemData: itemData,
                  isDescriptionExpanded: _isDescriptionExpanded,
                  onToggleDescription: () {
                    setState(() {
                      _isDescriptionExpanded = !_isDescriptionExpanded;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                ContactSectionWidget(
                  itemData: itemData,
                  isUserVerified: _isUserVerified,
                ),
                SizedBox(height: 3.h),
                SimilarItemsSectionWidget(
                  similarItems: similarItems,
                ),
                SizedBox(height: 3.h),
                CommentsSectionWidget(
                  comments: comments,
                ),
                SizedBox(height: 10.h), // Bottom padding for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_isUserVerified) {
            // Open chat
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opening chat...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            // Show verification prompt
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Verification Required'),
                content: Text(
                    'You need to verify your account to contact item owners.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile-screen');
                    },
                    child: Text('Verify Now'),
                  ),
                ],
              ),
            );
          }
        },
        icon: CustomIconWidget(
          iconName: 'message',
          color: Theme.of(context).floatingActionButtonTheme.foregroundColor ??
              Colors.white,
          size: 24,
        ),
        label: Text(
          'Contact Owner',
          style: TextStyle(
            color:
                Theme.of(context).floatingActionButtonTheme.foregroundColor ??
                    Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

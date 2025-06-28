import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/my_items_section_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/stats_section_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4; // Profile tab is active
  final bool _isLoading = false;

  // Mock user data
  final Map<String, dynamic> userData = {
    "id": 1,
    "name": "Sarah Johnson",
    "email": "sarah.johnson@university.edu",
    "avatar":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face",
    "joinDate": "September 2023",
    "isVerified": false,
    "postedItems": 12,
    "successfulMatches": 8,
    "communityRating": 4.8,
    "notificationsEnabled": true,
    "darkModeEnabled": false,
    "privacySettings": {
      "showEmail": false,
      "showPhone": true,
      "allowDirectMessages": true
    }
  };

  final List<Map<String, dynamic>> userItems = [
    {
      "id": 1,
      "title": "Blue Backpack",
      "category": "Bags",
      "status": "Active",
      "image":
          "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300&h=200&fit=crop",
      "postedDate": "2024-01-15",
      "expiryDate": "2024-01-29",
      "type": "Lost"
    },
    {
      "id": 2,
      "title": "iPhone 13 Pro",
      "category": "Electronics",
      "status": "Matched",
      "image":
          "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=300&h=200&fit=crop",
      "postedDate": "2024-01-10",
      "matchedDate": "2024-01-12",
      "type": "Found"
    },
    {
      "id": 3,
      "title": "Red Umbrella",
      "category": "Personal Items",
      "status": "Expired",
      "image":
          "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&h=200&fit=crop",
      "postedDate": "2023-12-20",
      "expiryDate": "2024-01-03",
      "type": "Found"
    }
  ];

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home-screen');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search-screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/post-item-screen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/item-details-screen');
        break;
      case 4:
        // Already on profile screen
        break;
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(
                    context, '/authentication-screen');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _handleVerifyIdentity() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Verify Your Identity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Benefits of verification:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 2.h),
              _buildBenefitItem('• Direct contact with item owners'),
              _buildBenefitItem('• Higher trust rating'),
              _buildBenefitItem('• Priority in search results'),
              _buildBenefitItem('• Access to premium features'),
              SizedBox(height: 2.h),
              Text(
                'Required documents:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 1.h),
              _buildBenefitItem('• Government issued ID'),
              _buildBenefitItem('• Student/Employee ID'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to verification flow
              },
              child: const Text('Start Verification'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ProfileHeaderWidget(
                      userData: userData,
                      onVerifyTap: _handleVerifyIdentity,
                    ),
                    SizedBox(height: 2.h),
                    StatsSection(userData: userData),
                    SizedBox(height: 2.h),
                    MyItemsSection(
                      userItems: userItems,
                      onItemTap: (item) {
                        Navigator.pushNamed(context, '/item-details-screen');
                      },
                    ),
                    SizedBox(height: 2.h),
                    SettingsSection(
                      userData: userData,
                      onLogout: _handleLogout,
                      onSettingChanged: (setting, value) {
                        setState(() {
                          if (setting == 'notifications') {
                            userData['notificationsEnabled'] = value;
                          } else if (setting == 'darkMode') {
                            userData['darkModeEnabled'] = value;
                          }
                        });
                      },
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentIndex == 0
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'search',
              color: _currentIndex == 1
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'add_circle',
              color: _currentIndex == 2
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'inventory_2',
              color: _currentIndex == 3
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Items',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 4
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

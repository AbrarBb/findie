import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/item_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isLostSelected = true;
  int selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Mock data for lost and found items
  final List<Map<String, dynamic>> lostItems = [
    {
      "id": 1,
      "title": "iPhone 14 Pro Max",
      "description": "Black iPhone with cracked screen protector",
      "imageUrl":
          "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&h=300&fit=crop",
      "category": "Electronics",
      "categoryIcon": "phone_android",
      "categoryColor": Color(0xFF2563EB),
      "building": "Engineering Building",
      "buildingIcon": "business",
      "datePosted": DateTime.now().subtract(Duration(hours: 2)),
      "tags": ["iPhone", "Apple", "Black"],
      "isLost": true,
    },
    {
      "id": 2,
      "title": "Red Leather Wallet",
      "description": "Contains student ID and credit cards",
      "imageUrl":
          "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=300&fit=crop",
      "category": "Personal Items",
      "categoryIcon": "account_balance_wallet",
      "categoryColor": Color(0xFF7C3AED),
      "building": "Library",
      "buildingIcon": "local_library",
      "datePosted": DateTime.now().subtract(Duration(hours: 5)),
      "tags": ["Wallet", "Red", "Leather"],
      "isLost": true,
    },
    {
      "id": 3,
      "title": "Blue Backpack",
      "description": "Nike backpack with laptop compartment",
      "imageUrl":
          "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=300&fit=crop",
      "category": "Bags",
      "categoryIcon": "backpack",
      "categoryColor": Color(0xFF059669),
      "building": "Student Center",
      "buildingIcon": "school",
      "datePosted": DateTime.now().subtract(Duration(days: 1)),
      "tags": ["Backpack", "Nike", "Blue"],
      "isLost": true,
    },
    {
      "id": 4,
      "title": "Silver MacBook Air",
      "description": "13-inch MacBook with stickers",
      "imageUrl":
          "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400&h=300&fit=crop",
      "category": "Electronics",
      "categoryIcon": "laptop_mac",
      "categoryColor": Color(0xFF2563EB),
      "building": "Computer Science Building",
      "buildingIcon": "computer",
      "datePosted": DateTime.now().subtract(Duration(days: 2)),
      "tags": ["MacBook", "Apple", "Silver"],
      "isLost": true,
    },
  ];

  final List<Map<String, dynamic>> foundItems = [
    {
      "id": 5,
      "title": "Black Sunglasses",
      "description": "Ray-Ban sunglasses found near cafeteria",
      "imageUrl":
          "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400&h=300&fit=crop",
      "category": "Accessories",
      "categoryIcon": "visibility",
      "categoryColor": Color(0xFFD97706),
      "building": "Cafeteria",
      "buildingIcon": "restaurant",
      "datePosted": DateTime.now().subtract(Duration(hours: 1)),
      "tags": ["Sunglasses", "Ray-Ban", "Black"],
      "isLost": false,
    },
    {
      "id": 6,
      "title": "House Keys",
      "description": "Set of keys with blue keychain",
      "imageUrl":
          "https://images.unsplash.com/photo-1582139329536-e7284fece509?w=400&h=300&fit=crop",
      "category": "Personal Items",
      "categoryIcon": "vpn_key",
      "categoryColor": Color(0xFF7C3AED),
      "building": "Parking Lot A",
      "buildingIcon": "local_parking",
      "datePosted": DateTime.now().subtract(Duration(hours: 3)),
      "tags": ["Keys", "Blue", "Keychain"],
      "isLost": false,
    },
    {
      "id": 7,
      "title": "Water Bottle",
      "description": "Stainless steel water bottle with name tag",
      "imageUrl":
          "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&h=300&fit=crop",
      "category": "Personal Items",
      "categoryIcon": "local_drink",
      "categoryColor": Color(0xFF059669),
      "building": "Gym",
      "buildingIcon": "fitness_center",
      "datePosted": DateTime.now().subtract(Duration(hours: 6)),
      "tags": ["Water Bottle", "Steel", "Name Tag"],
      "isLost": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.elasticOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get currentItems {
    return isLostSelected ? lostItems : foundItems;
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      selectedTabIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/search-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/post-item-screen');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile-screen');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.lightTheme.primaryColor,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(height: 2.h),
                    ),
                    currentItems.isEmpty
                        ? _buildEmptyState()
                        : _buildItemsGrid(),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 10.h),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/post-item-screen');
          },
          backgroundColor: AppTheme.lightTheme.primaryColor,
          child: CustomIconWidget(
            iconName: 'add',
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'F',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Findie',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              CustomIconWidget(
                iconName: 'notifications_outlined',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildToggleSwitch(),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isLostSelected = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isLostSelected
                      ? AppTheme.lightTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Lost Items',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: isLostSelected
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isLostSelected = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: !isLostSelected
                      ? AppTheme.lightTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Found Items',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: !isLostSelected
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = currentItems[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: ItemCardWidget(
                item: item,
                onTap: () {
                  Navigator.pushNamed(context, '/item-details-screen');
                },
                onLongPress: () {
                  _showQuickActions(item);
                },
              ),
            );
          },
          childCount: currentItems.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: isLostSelected ? 'search_off' : 'inventory_2',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              isLostSelected ? 'No Lost Items' : 'No Found Items',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              isLostSelected
                  ? 'Be the first to report a lost item'
                  : 'Help someone by posting found items',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedTabIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        selectedItemColor: AppTheme.lightTheme.primaryColor,
        unselectedItemColor:
            AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: selectedTabIndex == 0 ? 'home' : 'home_outlined',
              color: selectedTabIndex == 0
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: selectedTabIndex == 1 ? 'search' : 'search',
              color: selectedTabIndex == 1
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName:
                  selectedTabIndex == 2 ? 'add_circle' : 'add_circle_outline',
              color: selectedTabIndex == 2
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: selectedTabIndex == 3 ? 'person' : 'person_outline',
              color: selectedTabIndex == 3
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showQuickActions(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'bookmark_border',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text(
                'Save Item',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text(
                'Share',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report',
                color: AppTheme.errorLight,
                size: 24,
              ),
              title: Text(
                'Report',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.errorLight,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

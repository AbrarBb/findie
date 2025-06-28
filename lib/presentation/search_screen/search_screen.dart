import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/no_results_widget.dart';
import './widgets/search_filter_chip_widget.dart';
import './widgets/search_result_item_widget.dart';
import './widgets/trending_categories_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;

  bool _isSearching = false;
  String _selectedCategory = '';
  String _selectedBuilding = '';
  final String _selectedDateRange = '';
  String _selectedItemType = '';
  String _sortBy = 'Relevance';

  final List<String> _recentSearches = ['iPhone 13', 'Blue backpack', 'Keys'];
  List<String> _searchSuggestions = [];

  // Mock data for search results
  final List<Map<String, dynamic>> _allItems = [
    {
      "id": 1,
      "title": "iPhone 13 Pro Max",
      "description":
          "Lost my blue iPhone 13 Pro Max near the library. Has a clear case with stickers.",
      "category": "Electronics",
      "building": "Main Library",
      "date": "2024-01-15",
      "type": "Lost",
      "image":
          "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400",
      "extractedText": "iPhone, Apple, 13 Pro Max, blue case",
      "distance": "0.2 km"
    },
    {
      "id": 2,
      "title": "Blue Backpack",
      "description":
          "Found a blue Jansport backpack in the cafeteria. Contains textbooks and notebooks.",
      "category": "Bags",
      "building": "Student Cafeteria",
      "date": "2024-01-14",
      "type": "Found",
      "image":
          "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400",
      "extractedText": "Jansport, blue, backpack, textbooks",
      "distance": "0.5 km"
    },
    {
      "id": 3,
      "title": "Car Keys with Honda Keychain",
      "description":
          "Lost my car keys with a Honda keychain and house keys attached.",
      "category": "Keys",
      "building": "Parking Lot A",
      "date": "2024-01-13",
      "type": "Lost",
      "image":
          "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400",
      "extractedText": "Honda, keys, car keys, keychain",
      "distance": "0.8 km"
    },
    {
      "id": 4,
      "title": "Black Wallet",
      "description":
          "Found a black leather wallet near the gym entrance. Contains ID and cards.",
      "category": "Personal Items",
      "building": "Sports Complex",
      "date": "2024-01-12",
      "type": "Found",
      "image":
          "https://images.unsplash.com/photo-1627123424574-724758594e93?w=400",
      "extractedText": "wallet, black, leather, ID, cards",
      "distance": "1.2 km"
    },
    {
      "id": 5,
      "title": "Red Water Bottle",
      "description":
          "Lost my red Hydro Flask water bottle in the engineering building.",
      "category": "Personal Items",
      "building": "Engineering Building",
      "date": "2024-01-11",
      "type": "Lost",
      "image":
          "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400",
      "extractedText": "Hydro Flask, red, water bottle",
      "distance": "0.3 km"
    }
  ];

  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1);
    _filteredItems = _allItems;

    // Auto-focus search bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      _updateSearchSuggestions();
      _filterItems();
    });
  }

  void _updateSearchSuggestions() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _searchSuggestions = [];
      return;
    }

    final suggestions = <String>{};

    // Add category suggestions
    final categories = [
      'Electronics',
      'Bags',
      'Keys',
      'Personal Items',
      'Clothing',
      'Books'
    ];
    for (final category in categories) {
      if (category.toLowerCase().contains(query)) {
        suggestions.add(category);
      }
    }

    // Add building suggestions
    final buildings = [
      'Main Library',
      'Student Cafeteria',
      'Engineering Building',
      'Sports Complex',
      'Dormitory A'
    ];
    for (final building in buildings) {
      if (building.toLowerCase().contains(query)) {
        suggestions.add(building);
      }
    }

    // Add item type suggestions
    final itemTypes = [
      'iPhone',
      'Backpack',
      'Wallet',
      'Keys',
      'Laptop',
      'Headphones'
    ];
    for (final itemType in itemTypes) {
      if (itemType.toLowerCase().contains(query)) {
        suggestions.add(itemType);
      }
    }

    _searchSuggestions = suggestions.take(5).toList();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();

    _filteredItems = _allItems.where((item) {
      final matchesQuery = query.isEmpty ||
          (item['title'] as String).toLowerCase().contains(query) ||
          (item['description'] as String).toLowerCase().contains(query) ||
          (item['extractedText'] as String).toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory.isEmpty || item['category'] == _selectedCategory;
      final matchesBuilding =
          _selectedBuilding.isEmpty || item['building'] == _selectedBuilding;
      final matchesItemType =
          _selectedItemType.isEmpty || item['type'] == _selectedItemType;

      return matchesQuery &&
          matchesCategory &&
          matchesBuilding &&
          matchesItemType;
    }).toList();

    // Sort results
    _sortResults();
  }

  void _sortResults() {
    switch (_sortBy) {
      case 'Date':
        _filteredItems.sort(
            (a, b) => (b['date'] as String).compareTo(a['date'] as String));
        break;
      case 'Distance':
        _filteredItems.sort((a, b) {
          final aDistance =
              double.parse((a['distance'] as String).replaceAll(' km', ''));
          final bDistance =
              double.parse((b['distance'] as String).replaceAll(' km', ''));
          return aDistance.compareTo(bDistance);
        });
        break;
      case 'Relevance':
      default:
        // Keep original order for relevance
        break;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    setState(() {
      _searchSuggestions = [];
    });
  }

  void _addToRecentSearches(String query) {
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
  }

  void _showFilterBottomSheet(String filterType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(filterType),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSortBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet(String filterType) {
    List<String> options = [];
    String currentValue = '';

    switch (filterType) {
      case 'Category':
        options = [
          'Electronics',
          'Bags',
          'Keys',
          'Personal Items',
          'Clothing',
          'Books'
        ];
        currentValue = _selectedCategory;
        break;
      case 'Building':
        options = [
          'Main Library',
          'Student Cafeteria',
          'Engineering Building',
          'Sports Complex',
          'Dormitory A'
        ];
        currentValue = _selectedBuilding;
        break;
      case 'Item Type':
        options = ['Lost', 'Found'];
        currentValue = _selectedItemType;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select $filterType',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 2.h),
                ...options.map((option) => ListTile(
                      title: Text(option),
                      trailing: currentValue == option
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          switch (filterType) {
                            case 'Category':
                              _selectedCategory =
                                  currentValue == option ? '' : option;
                              break;
                            case 'Building':
                              _selectedBuilding =
                                  currentValue == option ? '' : option;
                              break;
                            case 'Item Type':
                              _selectedItemType =
                                  currentValue == option ? '' : option;
                              break;
                          }
                          _filterItems();
                        });
                        Navigator.pop(context);
                      },
                    )),
                if (currentValue.isNotEmpty)
                  ListTile(
                    title: Text('Clear Filter'),
                    leading: CustomIconWidget(
                      iconName: 'clear',
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    onTap: () {
                      setState(() {
                        switch (filterType) {
                          case 'Category':
                            _selectedCategory = '';
                            break;
                          case 'Building':
                            _selectedBuilding = '';
                            break;
                          case 'Item Type':
                            _selectedItemType = '';
                            break;
                        }
                        _filterItems();
                      });
                      Navigator.pop(context);
                    },
                  ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBottomSheet() {
    final sortOptions = ['Relevance', 'Date', 'Distance'];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort by',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 2.h),
                ...sortOptions.map((option) => ListTile(
                      title: Text(option),
                      trailing: _sortBy == option
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _sortBy = option;
                          _sortResults();
                        });
                        Navigator.pop(context);
                      },
                    )),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _searchFocusNode.hasFocus
                            ? AppTheme.lightTheme.primaryColor
                            : Theme.of(context).colorScheme.outline,
                        width: _searchFocusNode.hasFocus ? 2 : 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search for lost or found items...',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomIconWidget(
                            iconName: 'search',
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                onPressed: _clearSearch,
                                icon: CustomIconWidget(
                                  iconName: 'clear',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                            IconButton(
                              onPressed: () {
                                // Voice search functionality
                              },
                              icon: CustomIconWidget(
                                iconName: 'mic',
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      onSubmitted: (value) {
                        _addToRecentSearches(value);
                      },
                    ),
                  ),

                  // Search suggestions
                  if (_searchSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Column(
                        children: _searchSuggestions
                            .map((suggestion) => ListTile(
                                  dense: true,
                                  leading: CustomIconWidget(
                                    iconName: 'search',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    size: 16,
                                  ),
                                  title: Text(
                                    suggestion,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  onTap: () => _selectSuggestion(suggestion),
                                ))
                            .toList(),
                      ),
                    ),

                  SizedBox(height: 1.h),

                  // Filter chips and sort button
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SearchFilterChipWidget(
                                label: 'Category',
                                isSelected: _selectedCategory.isNotEmpty,
                                count: _selectedCategory.isNotEmpty ? 1 : null,
                                onTap: () => _showFilterBottomSheet('Category'),
                              ),
                              SizedBox(width: 2.w),
                              SearchFilterChipWidget(
                                label: 'Building',
                                isSelected: _selectedBuilding.isNotEmpty,
                                count: _selectedBuilding.isNotEmpty ? 1 : null,
                                onTap: () => _showFilterBottomSheet('Building'),
                              ),
                              SizedBox(width: 2.w),
                              SearchFilterChipWidget(
                                label: 'Date Range',
                                isSelected: _selectedDateRange.isNotEmpty,
                                count: _selectedDateRange.isNotEmpty ? 1 : null,
                                onTap: () =>
                                    _showFilterBottomSheet('Date Range'),
                              ),
                              SizedBox(width: 2.w),
                              SearchFilterChipWidget(
                                label: 'Item Type',
                                isSelected: _selectedItemType.isNotEmpty,
                                count: _selectedItemType.isNotEmpty ? 1 : null,
                                onTap: () =>
                                    _showFilterBottomSheet('Item Type'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      IconButton(
                        onPressed: _showSortBottomSheet,
                        icon: CustomIconWidget(
                          iconName: 'sort',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Recent searches (when not searching)
            if (!_isSearching && _recentSearches.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Searches',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: _recentSearches
                          .map((search) => GestureDetector(
                                onTap: () => _selectSuggestion(search),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'history',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        search,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

            // Main content
            Expanded(
              child: _isSearching
                  ? _filteredItems.isEmpty
                      ? NoResultsWidget(
                          searchQuery: _searchController.text,
                          onPostItem: () =>
                              Navigator.pushNamed(context, '/post-item-screen'),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await Future.delayed(const Duration(seconds: 1));
                            setState(() {
                              _filterItems();
                            });
                          },
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.h),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              return SearchResultItemWidget(
                                item: item,
                                searchQuery: _searchController.text,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/item-details-screen',
                                  arguments: item,
                                ),
                              );
                            },
                          ),
                        )
                  : TrendingCategoriesWidget(
                      onCategoryTap: (category) => _selectSuggestion(category),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Search tab active
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'add_circle',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'add_circle',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'chat',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'chat',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home-screen');
              break;
            case 1:
              // Already on search screen
              break;
            case 2:
              Navigator.pushNamed(context, '/post-item-screen');
              break;
            case 3:
              // Navigate to messages (not implemented)
              break;
            case 4:
              Navigator.pushNamed(context, '/profile-screen');
              break;
          }
        },
      ),
    );
  }
}

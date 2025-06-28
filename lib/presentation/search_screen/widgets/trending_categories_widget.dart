import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TrendingCategoriesWidget extends StatelessWidget {
  final Function(String) onCategoryTap;

  const TrendingCategoriesWidget({
    super.key,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final trendingCategories = [
      {
        'name': 'Electronics',
        'icon': 'phone_android',
        'color': const Color(0xFF3B82F6),
        'count': 24,
      },
      {
        'name': 'Bags',
        'icon': 'backpack',
        'color': const Color(0xFF8B5CF6),
        'count': 18,
      },
      {
        'name': 'Keys',
        'icon': 'key',
        'color': const Color(0xFF10B981),
        'count': 15,
      },
      {
        'name': 'Personal Items',
        'icon': 'account_balance_wallet',
        'color': const Color(0xFFF59E0B),
        'count': 12,
      },
      {
        'name': 'Clothing',
        'icon': 'checkroom',
        'color': const Color(0xFFEF4444),
        'count': 9,
      },
      {
        'name': 'Books',
        'icon': 'menu_book',
        'color': const Color(0xFF06B6D4),
        'count': 7,
      },
    ];

    final quickActions = [
      {
        'title': 'Post Lost Item',
        'subtitle': 'Report something you lost',
        'icon': 'add_circle_outline',
        'color': AppTheme.errorLight,
      },
      {
        'title': 'Post Found Item',
        'subtitle': 'Help someone find their item',
        'icon': 'favorite_outline',
        'color': AppTheme.successLight,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 2.h),

          Row(
            children: quickActions
                .map((action) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            right: action == quickActions.first ? 2.w : 0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              (action['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (action['color'] as Color)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            CustomIconWidget(
                              iconName: action['icon'] as String,
                              color: action['color'] as Color,
                              size: 32,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              action['title'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              action['subtitle'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),

          SizedBox(height: 3.h),

          // Trending categories
          Text(
            'Trending Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Popular items people are searching for',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 2.h),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.2,
            ),
            itemCount: trendingCategories.length,
            itemBuilder: (context, index) {
              final category = trendingCategories[index];
              return GestureDetector(
                onTap: () => onCategoryTap(category['name'] as String),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (category['color'] as Color)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: category['icon'] as String,
                          color: category['color'] as Color,
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        category['name'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${category['count']} items',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 3.h),

          // Tips section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'lightbulb_outline',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Search Tips',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '• Use specific keywords like brand names or colors\n'
                  '• Try searching for text visible in photos\n'
                  '• Filter by building or category for better results\n'
                  '• Check both Lost and Found sections',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NoResultsWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onPostItem;

  const NoResultsWidget({
    super.key,
    required this.searchQuery,
    required this.onPostItem,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Try different keywords',
      'Check your spelling',
      'Use more general terms',
      'Try searching for brand names',
      'Look in different categories',
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Column(
        children: [
          SizedBox(height: 4.h),

          // No results illustration
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: CustomIconWidget(
              iconName: 'search_off',
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 20.w,
            ),
          ),

          SizedBox(height: 3.h),

          // No results message
          Text(
            'No results found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          Text(
            'We couldn\'t find any items matching "$searchQuery"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 3.h),

          // Suggestions
          Container(
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Try these suggestions:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 1.h),
                ...suggestions.map((suggestion) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'check_circle_outline',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Post item CTA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.primaryColor,
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'add_circle',
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Can\'t find your item?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Post it yourself and let the community help you find it',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: onPostItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.lightTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Post Your Item',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Alternative actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Browse all items
                  },
                  icon: CustomIconWidget(
                    iconName: 'grid_view',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 18,
                  ),
                  label: Text('Browse All'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Contact support
                  },
                  icon: CustomIconWidget(
                    iconName: 'help_outline',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 18,
                  ),
                  label: Text('Get Help'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

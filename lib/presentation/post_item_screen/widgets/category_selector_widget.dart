import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CategorySelectorWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelectorWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Electronics',
      'icon': 'phone_android',
      'color': Color(0xFF2563EB)
    },
    {'name': 'Clothing', 'icon': 'checkroom', 'color': Color(0xFF7C3AED)},
    {'name': 'Books', 'icon': 'menu_book', 'color': Color(0xFF059669)},
    {'name': 'Accessories', 'icon': 'watch', 'color': Color(0xFFD97706)},
    {'name': 'Keys', 'icon': 'key', 'color': Color(0xFFDC2626)},
    {'name': 'Bags', 'icon': 'work', 'color': Color(0xFF0891B2)},
    {'name': 'Documents', 'icon': 'description', 'color': Color(0xFF7C2D12)},
    {'name': 'Sports', 'icon': 'sports_basketball', 'color': Color(0xFF15803D)},
    {'name': 'Jewelry', 'icon': 'diamond', 'color': Color(0xFF9333EA)},
    {'name': 'Other', 'icon': 'category', 'color': Color(0xFF6B7280)},
  ];

  void _showCategoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 70.h,
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),

            // Title
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 3.h),

            // Categories grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 3.h,
                  childAspectRatio: 1.2,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category['name'];

                  return GestureDetector(
                    onTap: () {
                      onCategorySelected(category['name'] as String);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (category['color'] as Color)
                                .withValues(alpha: 0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (category['color'] as Color)
                              : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: (category['color'] as Color)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName: category['icon'] as String,
                              color: category['color'] as Color,
                              size: 32,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            category['name'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: isSelected
                                      ? (category['color'] as Color)
                                      : Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .color,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategoryData = categories.firstWhere(
      (category) => category['name'] == selectedCategory,
      orElse: () => {
        'name': '',
        'icon': 'category',
        'color': Theme.of(context).primaryColor
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: () => _showCategoryBottomSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedCategory.isNotEmpty
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
                width: selectedCategory.isNotEmpty ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                if (selectedCategory.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: (selectedCategoryData['color'] as Color)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: selectedCategoryData['icon'] as String,
                      color: selectedCategoryData['color'] as Color,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    selectedCategory,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: selectedCategoryData['color'] as Color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ] else ...[
                  CustomIconWidget(
                    iconName: 'category',
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Select a category',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                  ),
                ],
                const Spacer(),
                CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

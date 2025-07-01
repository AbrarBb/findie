import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdminStatsWidget extends ConsumerWidget {
  const AdminStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock stats data - in real app, this would come from providers
    final stats = [
      {
        'title': 'Total Posts',
        'value': '1,234',
        'change': '+12%',
        'icon': 'inventory_2',
        'color': Theme.of(context).colorScheme.primary,
      },
      {
        'title': 'Active Users',
        'value': '856',
        'change': '+8%',
        'icon': 'people',
        'color': Theme.of(context).colorScheme.tertiary,
      },
      {
        'title': 'Successful Matches',
        'value': '342',
        'change': '+15%',
        'icon': 'handshake',
        'color': Theme.of(context).colorScheme.secondary,
      },
      {
        'title': 'Pending Verifications',
        'value': '23',
        'change': '-5%',
        'icon': 'pending',
        'color': Theme.of(context).colorScheme.error,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platform Overview',
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
            childAspectRatio: 1.3,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: (stat['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: CustomIconWidget(
                          iconName: stat['icon'] as String,
                          color: stat['color'] as Color,
                          size: 20,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: (stat['change'] as String).startsWith('+')
                              ? Theme.of(context).colorScheme.tertiaryContainer
                              : Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: Text(
                          stat['change'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: (stat['change'] as String).startsWith('+')
                                    ? Theme.of(context).colorScheme.onTertiaryContainer
                                    : Theme.of(context).colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    stat['value'] as String,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: stat['color'] as Color,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    stat['title'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
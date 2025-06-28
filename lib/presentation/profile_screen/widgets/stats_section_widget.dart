import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class StatsSection extends StatelessWidget {
  final Map<String, dynamic> userData;

  const StatsSection({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final int postedItems = userData['postedItems'] ?? 0;
    final int successfulMatches = userData['successfulMatches'] ?? 0;
    final double communityRating =
        (userData['communityRating'] ?? 0.0).toDouble();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: 'inventory_2',
                  label: 'Posted Items',
                  value: postedItems.toString(),
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: 'handshake',
                  label: 'Successful Matches',
                  value: successfulMatches.toString(),
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildRatingSection(context, communityRating),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 6.w,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context, double rating) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'star',
                color: Colors.amber,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Community Rating',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.amber.shade700,
                    ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return CustomIconWidget(
                          iconName:
                              index < rating.floor() ? 'star' : 'star_border',
                          color: Colors.amber,
                          size: 4.w,
                        );
                      }),
                    ),
                    SizedBox(height: 0.5.h),
                    LinearProgressIndicator(
                      value: rating / 5.0,
                      backgroundColor: Colors.amber.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      minHeight: 0.5.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Based on community feedback and successful returns',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

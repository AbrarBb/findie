import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class LocationPickerWidget extends StatefulWidget {
  final String selectedLocation;
  final Function(String) onLocationSelected;

  const LocationPickerWidget({
    super.key,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  bool _isDetectingLocation = false;

  static const List<Map<String, dynamic>> campusLocations = [
    {
      'name': 'Main Library',
      'icon': 'local_library',
      'building': 'Academic Block A'
    },
    {
      'name': 'Student Center',
      'icon': 'people',
      'building': 'Student Services'
    },
    {'name': 'Cafeteria', 'icon': 'restaurant', 'building': 'Dining Hall'},
    {
      'name': 'Gymnasium',
      'icon': 'fitness_center',
      'building': 'Sports Complex'
    },
    {'name': 'Computer Lab', 'icon': 'computer', 'building': 'Tech Building'},
    {'name': 'Auditorium', 'icon': 'theater_comedy', 'building': 'Arts Center'},
    {
      'name': 'Parking Lot A',
      'icon': 'local_parking',
      'building': 'North Campus'
    },
    {
      'name': 'Parking Lot B',
      'icon': 'local_parking',
      'building': 'South Campus'
    },
    {
      'name': 'Dormitory Block 1',
      'icon': 'home',
      'building': 'Residential Area'
    },
    {
      'name': 'Dormitory Block 2',
      'icon': 'home',
      'building': 'Residential Area'
    },
    {
      'name': 'Medical Center',
      'icon': 'local_hospital',
      'building': 'Health Services'
    },
    {
      'name': 'Administration Office',
      'icon': 'business',
      'building': 'Admin Block'
    },
  ];

  void _detectCurrentLocation() async {
    setState(() {
      _isDetectingLocation = true;
    });

    // Simulate GPS detection
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isDetectingLocation = false;
      });

      // Mock detected location
      const detectedLocation = 'Main Library';
      widget.onLocationSelected(detectedLocation);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location detected: Main Library'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showLocationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 80.h,
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

            // Title and GPS button
            Row(
              children: [
                Text(
                  'Select Location',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _detectCurrentLocation();
                  },
                  icon: CustomIconWidget(
                    iconName: 'my_location',
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  tooltip: 'Detect current location',
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search locations...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                    size: 20,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Locations list
            Expanded(
              child: ListView.builder(
                itemCount: campusLocations.length,
                itemBuilder: (context, index) {
                  final location = campusLocations[index];
                  final isSelected =
                      widget.selectedLocation == location['name'];

                  return Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    child: ListTile(
                      onTap: () {
                        widget.onLocationSelected(location['name'] as String);
                        Navigator.pop(context);
                      },
                      leading: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                        child: CustomIconWidget(
                          iconName: location['icon'] as String,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodyMedium!.color!,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        location['name'] as String,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .color,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                      ),
                      subtitle: Text(
                        location['building'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: isSelected
                          ? CustomIconWidget(
                              iconName: 'check_circle',
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            )
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: isSelected
                          ? Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.05)
                          : null,
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
    final selectedLocationData = campusLocations.firstWhere(
      (location) => location['name'] == widget.selectedLocation,
      orElse: () => {'name': '', 'icon': 'location_on', 'building': ''},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Location *',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (!_isDetectingLocation)
              TextButton.icon(
                onPressed: _detectCurrentLocation,
                icon: CustomIconWidget(
                  iconName: 'my_location',
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
                label: Text(
                  'Detect',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  minimumSize: Size.zero,
                ),
              )
            else
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: _showLocationBottomSheet,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.selectedLocation.isNotEmpty
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
                width: widget.selectedLocation.isNotEmpty ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: widget.selectedLocation.isNotEmpty
                      ? selectedLocationData['icon'] as String
                      : 'location_on',
                  color: widget.selectedLocation.isNotEmpty
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium!.color!,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedLocation.isNotEmpty
                            ? widget.selectedLocation
                            : 'Select location',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: widget.selectedLocation.isNotEmpty
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                              fontWeight: widget.selectedLocation.isNotEmpty
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                      ),
                      if (widget.selectedLocation.isNotEmpty &&
                          selectedLocationData['building'] != null)
                        Text(
                          selectedLocationData['building'] as String,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
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

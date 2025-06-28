import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SettingsSection extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;
  final Function(String, bool) onSettingChanged;

  const SettingsSection({
    super.key,
    required this.userData,
    required this.onLogout,
    required this.onSettingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 2.h),

          // Notification Settings
          _buildSettingsCard(
            context,
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                context,
                icon: 'notifications',
                title: 'Push Notifications',
                subtitle: 'Get notified about matches and messages',
                value: userData['notificationsEnabled'] ?? true,
                onChanged: (value) => onSettingChanged('notifications', value),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Appearance Settings
          _buildSettingsCard(
            context,
            title: 'Appearance',
            children: [
              _buildSwitchTile(
                context,
                icon: 'dark_mode',
                title: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: userData['darkModeEnabled'] ?? false,
                onChanged: (value) => onSettingChanged('darkMode', value),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Privacy Settings
          _buildSettingsCard(
            context,
            title: 'Privacy',
            children: [
              _buildTile(
                context,
                icon: 'privacy_tip',
                title: 'Privacy Settings',
                subtitle: 'Control who can see your information',
                onTap: () => _showPrivacySettings(context),
              ),
              _buildTile(
                context,
                icon: 'block',
                title: 'Blocked Users',
                subtitle: 'Manage blocked users',
                onTap: () {
                  // Navigate to blocked users
                },
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Account Settings
          _buildSettingsCard(
            context,
            title: 'Account',
            children: [
              _buildTile(
                context,
                icon: 'help',
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () {
                  // Navigate to help
                },
              ),
              _buildTile(
                context,
                icon: 'info',
                title: 'About',
                subtitle: 'App version and information',
                onTap: () => _showAboutDialog(context),
              ),
              _buildTile(
                context,
                icon: 'logout',
                title: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: onLogout,
                isDestructive: true,
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Danger Zone
          _buildSettingsCard(
            context,
            title: 'Danger Zone',
            children: [
              _buildTile(
                context,
                icon: 'delete_forever',
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and data',
                onTap: () => _showDeleteAccountDialog(context),
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
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
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 3.w, 4.w, 1.h),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: isDestructive
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).primaryColor,
          size: 5.w,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDestructive ? Theme.of(context).colorScheme.error : null,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 5.w,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: Theme.of(context).primaryColor,
          size: 5.w,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    final privacySettings =
        userData['privacySettings'] as Map<String, dynamic>? ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Privacy Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 3.h),
                  SwitchListTile(
                    title: const Text('Show Email'),
                    subtitle: const Text('Allow others to see your email'),
                    value: privacySettings['showEmail'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        privacySettings['showEmail'] = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Show Phone'),
                    subtitle:
                        const Text('Allow others to see your phone number'),
                    value: privacySettings['showPhone'] ?? true,
                    onChanged: (value) {
                      setState(() {
                        privacySettings['showPhone'] = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Allow Direct Messages'),
                    subtitle:
                        const Text('Let verified users message you directly'),
                    value: privacySettings['allowDirectMessages'] ?? true,
                    onChanged: (value) {
                      setState(() {
                        privacySettings['allowDirectMessages'] = value;
                      });
                    },
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Save Settings'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Findie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Version: 1.0.0'),
              SizedBox(height: 1.h),
              const Text(
                  'Findie helps you find and return lost items within your community using AI-powered matching.'),
              SizedBox(height: 2.h),
              const Text('© 2024 Findie Team'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Account',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'This action cannot be undone. All your data will be permanently deleted including:'),
              SizedBox(height: 1.h),
              const Text('• Posted items and matches'),
              const Text('• Messages and conversations'),
              const Text('• Verification status'),
              const Text('• Account preferences'),
              SizedBox(height: 2.h),
              const Text('Are you sure you want to continue?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle account deletion
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }
}

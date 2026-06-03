import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

import '../../features/profile/providers/profile_provider.dart';

class SideDrawer extends StatelessWidget {
  final Function(String) onMenuItemSelected;

  const SideDrawer({
    super.key,
    required this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            child: ListenableBuilder(
              listenable: ProfileProvider(),
              builder: (context, child) {
                final profileData = ProfileProvider().profileData;
                final name = profileData['name']?.toString() ?? 'Kullanıcı';
                final initials = name.length >= 2
                    ? name.substring(0, 2).toUpperCase()
                    : (name.isNotEmpty ? name[0].toUpperCase() : 'KU');
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.dashboard_outlined, 'Dashboard'),
                _buildDrawerItem(Icons.calendar_today_outlined, 'Plans'),
                _buildDrawerItem(Icons.fitness_center_outlined, 'Training'),
                _buildDrawerItem(Icons.storefront_outlined, 'Market'),
                _buildDrawerItem(Icons.analytics_outlined, 'Analytics'),
                const Divider(color: Colors.grey),
                _buildDrawerItem(Icons.settings_outlined, 'Settings'),
                _buildDrawerItem(Icons.help_outline, 'Help & Support'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Alpamys Pro Fitness v1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      onTap: () => onMenuItemSelected(title),
    );
  }
}

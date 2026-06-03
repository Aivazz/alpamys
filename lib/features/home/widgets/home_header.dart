import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../common_widgets/icons/uicons.dart';
import '../../profile/providers/profile_provider.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationsTap;
  final ValueChanged<String>? onSearchChanged;

  const HomeHeader({
    super.key,
    required this.onMenuTap,
    required this.onNotificationsTap,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF131313);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: headerBgColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar (Menu & Notification)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const UIconMenu(color: Colors.white, size: 24),
                onPressed: onMenuTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const UIconNotification(color: Colors.white, size: 24),
                onPressed: onNotificationsTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // User Greeting Info
          ListenableBuilder(
            listenable: ProfileProvider(),
            builder: (context, child) {
              final profileProvider = ProfileProvider();
              final name = profileProvider.profileData['name']?.toString() ?? 'Kullanıcı';
              final location = profileProvider.profileData['location']?.toString() ?? 'Almatı';
              final displayLocation = location.replaceAll(' (GPS)', '');

              return Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: profileProvider.getAvatarImage(),
                    backgroundColor: Colors.white30,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Merhaba, Günaydın',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            displayLocation,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$name !',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}


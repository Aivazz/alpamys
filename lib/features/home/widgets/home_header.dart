import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../common_widgets/icons/uicons.dart';
import '../../profile/providers/profile_provider.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  final ValueChanged<String>? onSearchChanged;

  const HomeHeader({
    super.key,
    required this.onMenuTap,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF131313);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: headerBgColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(R.radiusLg),
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
        left: R.screenPaddingH,
        right: R.screenPaddingH,
        top: MediaQuery.of(context).padding.top + R.xs,
        bottom: R.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar (Menu only)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: UIconMenu(color: Colors.white, size: R.iconMd),
                onPressed: onMenuTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: R.md),
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
                    radius: R.sp(28),
                    backgroundImage: profileProvider.getAvatarImage(),
                    backgroundColor: Colors.white30,
                  ),
                  SizedBox(width: R.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                displayLocation,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: R.sp(11),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Merhaba, Günaydın',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: R.sp(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$name !',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: R.sp(22),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
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


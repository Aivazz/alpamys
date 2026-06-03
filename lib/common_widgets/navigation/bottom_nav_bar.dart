import 'package:flutter/material.dart';
import '../icons/uicons.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final activeColor = isDark ? Colors.white : Colors.black;
    final passiveColor = isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
    final borderColor = isDark ? const Color(0xFF262626) : const Color(0xFFF3F4F6);

    Color iconColor(int index) {
      return currentIndex == index ? activeColor : passiveColor;
    }

    Widget buildNavItem(int index, Widget icon) {
      final isSelected = currentIndex == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => onTap(index),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? activeColor : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: navBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavItem(0, UIconHome(color: iconColor(0), size: 22)),
            buildNavItem(1, UIconMarket(color: iconColor(1), size: 22)),
            buildNavItem(2, UIconAboneler(color: iconColor(2), size: 22)),
            buildNavItem(3, UIconProfile(color: iconColor(3), size: 22)),
          ],
        ),
      ),
    );
  }
}

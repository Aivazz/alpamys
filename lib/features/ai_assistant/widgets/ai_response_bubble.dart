import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AIResponseBubble extends StatelessWidget {
  final String text;

  const AIResponseBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';

class WorkoutBannerCard extends StatelessWidget {
  final VoidCallback onStartExercise;

  const WorkoutBannerCard({
    super.key,
    required this.onStartExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF2994A),
            Color(0xFFE08B26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Dumbbells decorative image at the bottom
            Positioned(
              right: 80,
              bottom: -15,
              width: 110,
              height: 110,
              child: Opacity(
                opacity: 0.85,
                child: Image.network(
                  'https://images.unsplash.com/photo-1638536532686-d610adfc8e5c?w=200&auto=format&fit=crop&q=60',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ),
            // Athlete photo positioned on the left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 140,
              child: Image.network(
                AppAssets.bannerAthlete,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.black26),
              ),
            ),
            // Semi-transparent overlay to ensure text contrast on the photo side
            Positioned(
              left: 120,
              top: 0,
              bottom: 0,
              width: 40,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xFFF2994A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            // Content on the right
            Positioned(
              left: 155,
              top: 20,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'YÜKSEK YOĞUNLUKLU DÖVÜŞ SANATLARI ANTRENMANI',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.3,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      minimumSize: const Size(120, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onStartExercise,
                    child: const Text(
                      'Egzersize Başla',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

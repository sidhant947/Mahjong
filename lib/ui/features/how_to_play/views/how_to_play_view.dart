import 'package:flutter/material.dart';
import 'package:mahjong/ui/core/theme/app_colors.dart';
import 'package:mahjong/ui/core/widgets/tangible_button.dart';

class HowToPlayView extends StatelessWidget {
  const HowToPlayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white24,
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.headingDark,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'HOW TO PLAY',
                        style: TextStyle(
                          
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingDark,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _step(
                      context,
                      1,
                      'Find Matching Pairs',
                      'Select two unlocked tiles that have identical faces (or matching Flowers / Seasons).',
                      Icons.extension_rounded,
                    ),
                    const SizedBox(height: 20),
                    _step(
                      context,
                      2,
                      'Unlocked Tiles Rule',
                      'A tile is free and selectable ONLY if it has no tiles resting on top of it AND has at least its left or right side open.',
                      Icons.lock_open_rounded,
                    ),
                    const SizedBox(height: 20),
                    _step(
                      context,
                      3,
                      'Clear the Board',
                      'Remove all tiles pair by pair until the board is completely clear to win the level!',
                      Icons.cleaning_services_rounded,
                    ),
                    const SizedBox(height: 32),
                    TangibleButton(
                      text: 'GOT IT!',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(
    BuildContext context,
    int number,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.headingDark, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $title',
                  style: const TextStyle(
                    
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.subtext,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

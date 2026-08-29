import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahjong/ui/core/services/haptic_service.dart';
import 'package:mahjong/ui/core/widgets/tangible_button.dart';
import 'package:mahjong/ui/providers.dart';

class HowToPlayView extends ConsumerWidget {
  const HowToPlayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(currentSkinProvider);

    return Scaffold(
      backgroundColor: skin.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.2,
            colors: skin.bgGradient,
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticService.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: skin.surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white24,
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: skin.headingColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'HOW TO PLAY',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: skin.headingColor,
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
                        skin,
                      ),
                      const SizedBox(height: 20),
                      _step(
                        context,
                        2,
                        'Unlocked Tiles Rule',
                        'A tile is free and selectable ONLY if it has no tiles resting on top of it AND has at least its left or right side open.',
                        Icons.lock_open_rounded,
                        skin,
                      ),
                      const SizedBox(height: 20),
                      _step(
                        context,
                        3,
                        'Clear the Board',
                        'Remove all tiles pair by pair until the board is completely clear to win the level!',
                        Icons.cleaning_services_rounded,
                        skin,
                      ),
                      const SizedBox(height: 32),
                      TangibleButton(
                        text: 'GOT IT!',
                        primaryColor: skin.primaryColor,
                        secondaryColor: skin.surfaceColor,
                        textColor: skin.headingColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    dynamic skin,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: skin.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: skin.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: skin.headingColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $title',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: skin.headingColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: skin.subtextColor,
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

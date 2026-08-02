import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mahjong/ui/core/theme/app_colors.dart';
import 'package:mahjong/ui/features/game/views/game_view.dart';
import 'package:mahjong/ui/providers.dart';

class LevelSelectView extends ConsumerStatefulWidget {
  const LevelSelectView({super.key});

  @override
  ConsumerState<LevelSelectView> createState() => _LevelSelectViewState();
}

class _LevelSelectViewState extends ConsumerState<LevelSelectView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final highestCompleted = state.progress?.highestLevelCompleted ?? 0;
    final currentLevel = state.progress?.currentLevel ?? 1;

    final int totalLevelsToShow = math.max(100, (currentLevel + 50).clamp(100, 1000));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        'LEVELS',
                        style: TextStyle(
                          
                          fontSize: 28,
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

            // Grid of levels
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: totalLevelsToShow,
                itemBuilder: (context, index) {
                  final levelNumber = index + 1;
                  final isCompleted = levelNumber <= highestCompleted;
                  final isCurrent = levelNumber == currentLevel;
                  final isLocked = levelNumber > currentLevel;

                  return _buildLevelCard(
                    context,
                    levelNumber: levelNumber,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isLocked: isLocked,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required int levelNumber,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
  }) {
    Color cardBg = AppColors.surface;
    Color textColor = AppColors.headingDark;
    Color borderColor = AppColors.accent;
    Widget content;
    bool isClickable = !isLocked;

    if (isCompleted) {
      cardBg = const Color(0xFF2D8B7A); // Soft Sage Green
      textColor = const Color(0xFFF5F5F0);
      borderColor = const Color(0xFF3D7A6B);
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$levelNumber',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: textColor,
          ),
        ],
      );
    } else if (isCurrent) {
      cardBg = const Color(0xFFF5F5F0); // Ivory Cream Highlight
      textColor = const Color(0xFF1A5C5C); // Deep Teal text
      borderColor = const Color(0xFF2D8B7A);
      content = Text(
        '$levelNumber',
        style: TextStyle(
          fontSize: 26,
          color: textColor,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      cardBg = const Color(0xFF134545).withValues(alpha: 0.5);
      borderColor = const Color(0xFF3D7A6B).withValues(alpha: 0.3);
      content = const Icon(
        Icons.lock_outline_rounded,
        size: 18,
        color: AppColors.subtext,
      );
    }

    return GestureDetector(
      onTap: isClickable
          ? () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameView(levelNumber: levelNumber),
                ),
              );
              ref.read(homeViewModelProvider.notifier).loadProgress();
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}

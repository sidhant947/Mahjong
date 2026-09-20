import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahjong/ui/core/services/haptic_service.dart';
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
    final skin = ref.watch(currentSkinProvider);
    final highestCompleted = state.progress?.highestLevelCompleted ?? 0;
    final currentLevel = state.progress?.currentLevel ?? 1;

    final int totalLevelsToShow = currentLevel + 10;

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
            children: [
              // Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          'LEVELS',
                          style: TextStyle(
                            fontSize: 28,
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
    final skin = ref.watch(currentSkinProvider);
    Color cardBg = skin.surfaceColor;
    Color textColor = skin.headingColor;
    Color borderColor = skin.accentColor;
    Widget content;
    bool isClickable = !isLocked;

    if (isCompleted) {
      cardBg = skin.primaryColor;
      textColor = skin.headingColor;
      borderColor = skin.accentColor;
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
      cardBg = skin.headingColor;
      textColor = skin.scaffoldBg;
      borderColor = skin.primaryColor;
      content = Text(
        '$levelNumber',
        style: TextStyle(
          fontSize: 26,
          color: textColor,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      cardBg = skin.surfaceColor.withValues(alpha: 0.5);
      borderColor = skin.accentColor.withValues(alpha: 0.3);
      content = Icon(
        Icons.lock_outline_rounded,
        size: 18,
        color: skin.subtextColor,
      );
    }

    return GestureDetector(
      onTap: isClickable
          ? () async {
              HapticService.selectionClick();
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

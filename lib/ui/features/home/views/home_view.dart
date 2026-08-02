import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import 'package:mahjong/ui/core/theme/app_colors.dart';
import 'package:mahjong/ui/core/widgets/custom_mahjong_painter.dart';
import 'package:mahjong/ui/core/widgets/tangible_button.dart';
import 'package:mahjong/ui/features/game/views/game_view.dart';
import 'package:mahjong/ui/features/how_to_play/views/how_to_play_view.dart';
import 'package:mahjong/ui/features/level_select/views/level_select_view.dart';
import 'package:mahjong/ui/providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(homeViewModelProvider.notifier).loadProgress(),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 8.0, end: 20.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 20,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact().catchError((_) {});
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.0),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? AppColors.headingDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFF5F5F0),
                    onTap: () =>
                        _launchUrl('https://github.com/sidhant947/Mahjong'),
                  ),
                  if (state.progress != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.accent, width: 1.5),
                      ),
                      child: Text(
                        'LEVEL ${state.progress!.currentLevel}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingDark,
                          letterSpacing: 0.8,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  _circleButton(
                    icon: Icons.favorite_rounded,
                    iconColor: const Color(0xFFF5F5F0),
                    onTap: () => _launchUrl('https://ko-fi.com/sidhant947'),
                  ),
                ],
              ),
              if (isLandscape)
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 80,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  AnimatedBuilder(
                                    animation: _glowAnimation,
                                    builder: (context, child) {
                                      return Positioned(
                                        left: -10,
                                        top: -10,
                                        right: -10,
                                        bottom: -10,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF2D8B7A,
                                                ).withValues(alpha: 0.5),
                                                blurRadius:
                                                    _glowAnimation.value * 1.5,
                                                spreadRadius:
                                                    _glowAnimation.value / 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const Positioned.fill(
                                    child: MahjongTileAssetWidget(
                                      typeIndex: 5,
                                      value: 0,
                                      isFree: true,
                                      isSelected: false,
                                      isHinted: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'MAHJONG',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFF5F5F0),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'SOLITAIRE MATCHING PUZZLE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.subtext,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TangibleButton(
                              text:
                                  state.progress == null ||
                                      state.progress!.currentLevel <= 1
                                  ? 'Start Game'
                                  : 'Play',
                              height: 48,
                              onPressed: state.isLoading
                                  ? null
                                  : () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => GameView(
                                            levelNumber:
                                                state.progress?.currentLevel ??
                                                1,
                                          ),
                                        ),
                                      );
                                      ref
                                          .read(homeViewModelProvider.notifier)
                                          .loadProgress();
                                    },
                            ),
                            const SizedBox(height: 12),
                            TangibleButton(
                              text: 'Select Level',
                              isSecondary: true,
                              height: 48,
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LevelSelectView(),
                                  ),
                                );
                                ref
                                    .read(homeViewModelProvider.notifier)
                                    .loadProgress();
                              },
                            ),
                            const SizedBox(height: 12),
                            TangibleButton(
                              text: 'How to Play',
                              isSecondary: true,
                              height: 48,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HowToPlayView(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                const Spacer(flex: 3),
                SizedBox(
                  width: 75,
                  height: 100,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: -12,
                            top: -12,
                            right: -12,
                            bottom: -12,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2D8B7A,
                                    ).withValues(alpha: 0.5),
                                    blurRadius: _glowAnimation.value * 1.5,
                                    spreadRadius: _glowAnimation.value / 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const Positioned.fill(
                        child: MahjongTileAssetWidget(
                          typeIndex: 5,
                          value: 0,
                          isFree: true,
                          isSelected: false,
                          isHinted: false,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'MAHJONG',
                  style: TextStyle(
                    fontSize: 62,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF5F5F0),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'SOLITAIRE MATCHING PUZZLE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.subtext,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(flex: 4),
                TangibleButton(
                  text:
                      state.progress == null ||
                          state.progress!.currentLevel <= 1
                      ? 'Start Game'
                      : 'Play',
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameView(
                                levelNumber: state.progress?.currentLevel ?? 1,
                              ),
                            ),
                          );
                          ref
                              .read(homeViewModelProvider.notifier)
                              .loadProgress();
                        },
                ),
                const SizedBox(height: 16),
                TangibleButton(
                  text: 'Select Level',
                  isSecondary: true,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LevelSelectView(),
                      ),
                    );
                    ref.read(homeViewModelProvider.notifier).loadProgress();
                  },
                ),
                const SizedBox(height: 16),
                TangibleButton(
                  text: 'How to Play',
                  isSecondary: true,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HowToPlayView(),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

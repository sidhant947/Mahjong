import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mahjong/ui/core/services/haptic_service.dart';
import 'package:mahjong/ui/core/widgets/custom_mahjong_painter.dart';
import 'package:mahjong/ui/core/widgets/tangible_button.dart';
import 'package:mahjong/ui/features/game/views/game_view.dart';
import 'package:mahjong/ui/features/how_to_play/views/how_to_play_view.dart';
import 'package:mahjong/ui/features/level_select/views/level_select_view.dart';
import 'package:mahjong/ui/features/settings/views/settings_view.dart';
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
    Future.microtask(() async {
      ref.read(homeViewModelProvider.notifier).loadProgress();
      await ref.read(settingsRepositoryProvider).init();
    });

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
    required Color surfaceColor,
    required Color iconColor,
    double iconSize = 20,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.0),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final skin = ref.watch(currentSkinProvider);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(
                      icon: Icons.star_rounded,
                      surfaceColor: skin.surfaceColor,
                      iconColor: skin.headingColor,
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
                          color: skin.surfaceColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: skin.accentColor, width: 1.5),
                        ),
                        child: Text(
                          'LEVEL ${state.progress!.currentLevel}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: skin.headingColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    _circleButton(
                      icon: Icons.favorite_rounded,
                      surfaceColor: skin.surfaceColor,
                      iconColor: skin.headingColor,
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
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: skin.glowColor
                                                      .withValues(alpha: 0.5),
                                                  blurRadius: _glowAnimation
                                                          .value *
                                                      1.5,
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
                              Text(
                                'MAHJONG',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: skin.headingColor,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'SOLITAIRE MATCHING PUZZLE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: skin.subtextColor,
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
                                text: state.progress == null ||
                                        state.progress!.currentLevel <= 1
                                    ? 'Start Game'
                                    : 'Play',
                                isSecondary: true,
                                height: 44,
                                primaryColor: skin.primaryColor,
                                secondaryColor: skin.surfaceColor,
                                textColor: skin.headingColor,
                                onPressed: state.isLoading
                                    ? null
                                    : () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GameView(
                                              levelNumber: state.progress
                                                      ?.currentLevel ??
                                                  1,
                                            ),
                                          ),
                                        );
                                        ref
                                            .read(homeViewModelProvider.notifier)
                                            .loadProgress();
                                      },
                              ),
                              const SizedBox(height: 10),
                              TangibleButton(
                                text: 'Select Level',
                                isSecondary: true,
                                height: 44,
                                primaryColor: skin.primaryColor,
                                secondaryColor: skin.surfaceColor,
                                textColor: skin.headingColor,
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
                              const SizedBox(height: 10),
                              TangibleButton(
                                text: 'How to Play',
                                isSecondary: true,
                                height: 44,
                                primaryColor: skin.primaryColor,
                                secondaryColor: skin.surfaceColor,
                                textColor: skin.headingColor,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HowToPlayView(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TangibleButton(
                                text: 'Settings',
                                isSecondary: true,
                                height: 44,
                                primaryColor: skin.primaryColor,
                                secondaryColor: skin.surfaceColor,
                                textColor: skin.headingColor,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsView(),
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
                                      color: skin.glowColor
                                          .withValues(alpha: 0.5),
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
                  Text(
                    'MAHJONG',
                    style: TextStyle(
                      fontSize: 62,
                      fontWeight: FontWeight.w900,
                      color: skin.headingColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'SOLITAIRE MATCHING PUZZLE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: skin.subtextColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(flex: 4),
                  TangibleButton(
                    text: state.progress == null ||
                            state.progress!.currentLevel <= 1
                        ? 'Start Game'
                        : 'Play',
                    isSecondary: true,
                    primaryColor: skin.primaryColor,
                    secondaryColor: skin.surfaceColor,
                    textColor: skin.headingColor,
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameView(
                                  levelNumber:
                                      state.progress?.currentLevel ?? 1,
                                ),
                              ),
                            );
                            ref
                                .read(homeViewModelProvider.notifier)
                                .loadProgress();
                          },
                  ),
                  const SizedBox(height: 14),
                  TangibleButton(
                    text: 'Select Level',
                    isSecondary: true,
                    primaryColor: skin.primaryColor,
                    secondaryColor: skin.surfaceColor,
                    textColor: skin.headingColor,
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
                  const SizedBox(height: 14),
                  TangibleButton(
                    text: 'How to Play',
                    isSecondary: true,
                    primaryColor: skin.primaryColor,
                    secondaryColor: skin.surfaceColor,
                    textColor: skin.headingColor,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HowToPlayView(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TangibleButton(
                    text: 'Settings',
                    isSecondary: true,
                    primaryColor: skin.primaryColor,
                    secondaryColor: skin.surfaceColor,
                    textColor: skin.headingColor,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsView(),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

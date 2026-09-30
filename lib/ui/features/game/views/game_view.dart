import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mahjong/domain/models/mahjong_tile.dart';
import 'package:mahjong/ui/core/services/haptic_service.dart';
import 'package:mahjong/ui/core/widgets/custom_mahjong_painter.dart';
import 'package:mahjong/ui/core/widgets/tangible_button.dart';
import 'package:mahjong/ui/features/game/view_models/game_view_model.dart';
import 'package:mahjong/ui/providers.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({super.key, required this.levelNumber});

  final int levelNumber;

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  final TransformationController _transformationController =
      TransformationController();
  bool _initialTransformSet = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gameViewModelProvider.notifier).loadLevel(widget.levelNumber);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _recenterBoard(
    BoxConstraints constraints,
    double boardW,
    double boardH,
    int depth,
  ) {
    final isMobile = constraints.maxWidth < 600;
    final scaleFactor = isMobile ? 1.0 : 1.3;
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;

    final matrix = Matrix4.identity()
      ..multiply(Matrix4.translationValues(centerX, centerY, 0))
      ..multiply(Matrix4.diagonal3Values(scaleFactor, scaleFactor, 1.0))
      ..multiply(Matrix4.translationValues(-centerX, -centerY, 0));

    _transformationController.value = matrix;
    HapticService.selectionClick();
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 20,
    bool enabled = true,
    String? badge,
    Color? iconColor,
    Color? backgroundColor,
    Color? badgeColor,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () {
              HapticService.selectionClick();
              onTap();
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor ?? const Color(0xFF134545),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.0),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? const Color(0xFFF5F5F0),
              ),
            ),
            if (badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? const Color(0xFF2D8B7A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white70, width: 1),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onLevelComplete(GameViewModelState state) {
    final skin = ref.read(currentSkinProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: skin.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: skin.primaryColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BOARD CLEARED!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: skin.headingColor,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'MOVES: ${state.moveCount}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: skin.subtextColor,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 24),
                TangibleButton(
                  text: 'NEXT LEVEL',
                  isSecondary: true,
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ref
                        .read(gameViewModelProvider.notifier)
                        .loadLevel(state.levelNumber + 1);
                  },
                ),
                const SizedBox(height: 12),
                TangibleButton(
                  text: 'HOME',
                  isSecondary: true,
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                const SizedBox(height: 12),
                TangibleButton(
                  text: 'BUY ME A COFFEE',
                  isSecondary: true,
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () {
                    final Uri url = Uri.parse('https://ko-fi.com/sidhant947');
                    launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    ).catchError((_) => false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeadlockDialog() {
    final skin = ref.watch(currentSkinProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: skin.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: skin.primaryColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sync_problem_rounded,
                  size: 48,
                  color: Color(0xFFFACC15),
                ),
                const SizedBox(height: 12),
                Text(
                  'NO MOVES LEFT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: skin.headingColor,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No matching pairs are currently free. Undo a move to continue!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: skin.subtextColor),
                ),
                const SizedBox(height: 20),
                TangibleButton(
                  text: 'UNDO MOVE',
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ref.read(gameViewModelProvider.notifier).undo();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameViewModelProvider);
    final skin = ref.watch(currentSkinProvider);
    final hintHelperEnabled = ref.watch(hintHelperEnabledProvider);

    ref.listen<GameViewModelState>(gameViewModelProvider, (prev, next) {
      if (next.isComplete && !(prev?.isComplete ?? false)) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _onLevelComplete(next);
          }
        });
      }

      if (next.isDeadlocked && !(prev?.isDeadlocked ?? false)) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _showDeadlockDialog();
          }
        });
      }
    });

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
        child: Stack(
          children: [
            Positioned.fill(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMahjongBoard(state),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        iconSize: 18,
                        iconColor: skin.headingColor,
                        backgroundColor: skin.surfaceColor,
                        onTap: () => Navigator.pop(context),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'LEVEL ${state.levelNumber}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: skin.headingColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            state.layout?.name.toUpperCase() ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: skin.subtextColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      _circleButton(
                        icon: Icons.refresh_rounded,
                        iconSize: 20,
                        iconColor: skin.headingColor,
                        backgroundColor: skin.surfaceColor,
                        onTap: () => ref
                            .read(gameViewModelProvider.notifier)
                            .loadLevel(state.levelNumber),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _circleButton(
                        icon: Icons.undo_rounded,
                        iconSize: 22,
                        iconColor: skin.headingColor,
                        backgroundColor: skin.surfaceColor,
                        enabled: state.canUndo,
                        onTap: () =>
                            ref.read(gameViewModelProvider.notifier).undo(),
                      ),
                      if (hintHelperEnabled)
                        _circleButton(
                          icon: Icons.lightbulb_outline_rounded,
                          iconSize: 22,
                          iconColor: skin.headingColor,
                          backgroundColor: skin.surfaceColor,
                          badgeColor: skin.primaryColor,
                          badge: '${state.hintsRemaining}',
                          enabled: state.hintsRemaining > 0,
                          onTap: () =>
                              ref.read(gameViewModelProvider.notifier).hint(),
                        ),
                      _circleButton(
                        icon: Icons.center_focus_strong_rounded,
                        iconSize: 20,
                        iconColor: skin.headingColor,
                        backgroundColor: skin.surfaceColor,
                        onTap: () {
                          if (state.layout != null) {
                            _recenterBoard(
                              BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.75,
                              ),
                              state.layout!.width.toDouble(),
                              state.layout!.height.toDouble(),
                              state.layout!.depth,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMahjongBoard(GameViewModelState state) {
    final layout = state.layout;
    if (layout == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait = constraints.maxHeight > constraints.maxWidth;
        final isDualBoardHorizontal = layout.name == 'Twin Peaks';
        final useVerticalDualBoard = isPortrait && isDualBoardHorizontal;

        final boardW = useVerticalDualBoard ? 16.0 : layout.width.toDouble();
        final boardH = useVerticalDualBoard ? 32.0 : layout.height.toDouble();

        final isMobile = constraints.maxWidth < 600;
        final scaleFactor = useVerticalDualBoard
            ? 0.85
            : (isMobile ? 1.0 : 1.3);
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;

        final matrix = Matrix4.identity()
          ..multiply(Matrix4.translationValues(centerX, centerY, 0))
          ..multiply(Matrix4.diagonal3Values(scaleFactor, scaleFactor, 1.0))
          ..multiply(Matrix4.translationValues(-centerX, -centerY, 0));

        if (!_initialTransformSet) {
          _initialTransformSet = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _transformationController.value = matrix;
            }
          });
        }

        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(300),
          clipBehavior: Clip.none,
          child: Builder(
            builder: (context) {
              final maxBoardW = (boardW / 2.0) * 2.8 + (layout.depth * 0.45);
              final maxBoardH = (boardH / 2.0) * 3.733 + (layout.depth * 0.45);

              final baseScaleX = constraints.maxWidth / (maxBoardW + 2);
              final baseScaleY = constraints.maxHeight / (maxBoardH + 2);
              final scale = math.min(baseScaleX, baseScaleY);

              final tileW = scale * 2.8;
              final tileH = scale * 3.733;

              final levelOffsetX = scale * 0.45;
              final levelOffsetY = scale * 0.45;

              final totalBoardWidth =
                  (boardW / 2.0) * tileW + (layout.depth * levelOffsetX);
              final totalBoardHeight =
                  (boardH / 2.0) * tileH + (layout.depth * levelOffsetY);

              final offsetX = (constraints.maxWidth - totalBoardWidth) / 2;
              final offsetY = (constraints.maxHeight - totalBoardHeight) / 2;

              final activeTiles = state.activeTiles;

              return RepaintBoundary(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Stack(
                    children: activeTiles.map((tile) {
                      final isSelected = state.selectedTile?.id == tile.id;
                      final isHinted = state.hintPair.any(
                        (h) => h.id == tile.id,
                      );

                      double tileX = tile.position.x.toDouble();
                      double tileY = tile.position.y.toDouble();
                      if (useVerticalDualBoard && tileX >= 16) {
                        tileX -= 16;
                        tileY += 12;
                      }

                      final posX =
                          offsetX +
                          (tileX * (tileW / 2.0)) -
                          (tile.position.z * levelOffsetX);
                      final posY =
                          offsetY +
                          (tileY * (tileH / 2.0)) -
                          (tile.position.z * levelOffsetY);

                      return Positioned(
                        left: posX,
                        top: posY,
                        width: tileW,
                        height: tileH,
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(gameViewModelProvider.notifier)
                                .selectTile(tile);
                          },
                          child: _MahjongTileWidget(
                            key: ValueKey(tile.id),
                            tile: tile,
                            isSelected: isSelected,
                            isHinted: isHinted,
                            depthOffset: levelOffsetX,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MahjongTileWidget extends StatelessWidget {
  const _MahjongTileWidget({
    super.key,
    required this.tile,
    required this.isSelected,
    required this.isHinted,
    required this.depthOffset,
  });

  final BoardTile tile;
  final bool isSelected;
  final bool isHinted;
  final double depthOffset;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutBack,
      child: AnimatedSlide(
        offset: isSelected ? const Offset(0, -0.06) : Offset.zero,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: MahjongTileAssetWidget(
          typeIndex: tile.tile.type.index,
          value: tile.tile.value,
          isFree: tile.isFree,
          isSelected: isSelected,
          isHinted: isHinted,
        ),
      ),
    );
  }
}

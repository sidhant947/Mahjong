import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mahjong/domain/models/mahjong_tile.dart';
import 'package:mahjong/ui/core/theme/app_colors.dart';
import 'package:mahjong/ui/core/widgets/custom_mahjong_painter.dart';
import 'package:mahjong/ui/core/widgets/tangible_button.dart';
import 'package:mahjong/ui/features/game/view_models/game_view_model.dart';
import 'package:mahjong/ui/providers.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({
    super.key,
    required this.levelNumber,
  });

  final int levelNumber;

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  final TransformationController _transformationController = TransformationController();
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

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 20,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact().catchError((_) {});
              onTap();
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
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
          child: Icon(
            icon,
            size: iconSize,
            color: AppColors.headingDark,
          ),
        ),
      ),
    );
  }

  void _onLevelComplete(GameViewModelState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFFFFFFF), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  size: 64,
                  color: Color(0xFFFFFFFF),
                ),
                const SizedBox(height: 12),
                const Text(
                  'BOARD CLEARED!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.headingDark,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                TangibleButton(
                  text: 'NEXT LEVEL',
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
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                const SizedBox(height: 12),
                TangibleButton(
                  text: 'BUY ME A COFFEE',
                  isSecondary: true,
                  onPressed: () {
                    final Uri url = Uri.parse('https://ko-fi.com/sidhant947');
                    launchUrl(url, mode: LaunchMode.externalApplication).catchError((_) => false);
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

    ref.listen<GameViewModelState>(gameViewModelProvider, (prev, next) {
      if (next.isComplete && !(prev?.isComplete ?? false)) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _onLevelComplete(next);
          }
        });
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [
              Color(0xFF1A5C5C), // Deep Teal & Dark Cyan Center
              Color(0xFF0F3838), // Rich Dark Teal
              Color(0xFF092424), // Dark Vignette Edge
            ],
            stops: [0.0, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    iconSize: 18,
                    onTap: () => Navigator.pop(context),
                  ),
                  Column(
                    children: [
                      Text(
                        'LEVEL ${state.levelNumber}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingDark,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        state.layout?.name.toUpperCase() ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.subtext,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  _circleButton(
                    icon: Icons.refresh_rounded,
                    iconSize: 20,
                    onTap: () => ref
                        .read(gameViewModelProvider.notifier)
                        .loadLevel(state.levelNumber),
                  ),
                ],
              ),
            ),

            // Game Board Canvas
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMahjongBoard(state),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMahjongBoard(GameViewModelState state) {
    final layout = state.layout;
    if (layout == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Grid units (width=32, height=16 for standard 12x8 layout area)
        final boardW = layout.width.toDouble();
        final boardH = layout.height.toDouble();

        final isMobile = constraints.maxWidth < 600;
        final scaleFactor = isMobile ? 1.0 : 1.3;
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

              final totalBoardWidth = (boardW / 2.0) * tileW + (layout.depth * levelOffsetX);
              final totalBoardHeight = (boardH / 2.0) * tileH + (layout.depth * levelOffsetY);

              final offsetX = (constraints.maxWidth - totalBoardWidth) / 2;
              final offsetY = (constraints.maxHeight - totalBoardHeight) / 2;

              final sortedTiles = List<BoardTile>.from(state.activeTiles)
                ..sort((a, b) {
                  if (a.position.z != b.position.z) {
                    return a.position.z.compareTo(b.position.z);
                  }
                  if (a.position.y != b.position.y) {
                    return a.position.y.compareTo(b.position.y);
                  }
                  return a.position.x.compareTo(b.position.x);
                });

              return Stack(
                children: [
                  Positioned.fill(
                    child: Stack(
                      children: sortedTiles.map((tile) {
                        final isSelected = state.selectedTile?.id == tile.id;
                        final isHinted = state.hintPair.any((h) => h.id == tile.id);

                        final posX = offsetX + (tile.position.x * (tileW / 2.0)) - (tile.position.z * levelOffsetX);
                        final posY = offsetY + (tile.position.y * (tileH / 2.0)) - (tile.position.z * levelOffsetY);

                        return Positioned(
                          left: posX,
                          top: posY,
                          width: tileW,
                          height: tileH,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(gameViewModelProvider.notifier).selectTile(tile);
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
                ],
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
    return MahjongTileAssetWidget(
      typeIndex: tile.tile.type.index,
      value: tile.tile.value,
      isFree: tile.isFree,
      isSelected: isSelected,
      isHinted: isHinted,
    );
  }
}

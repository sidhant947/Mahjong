import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mahjong/domain/models/app_skin.dart';
import 'package:mahjong/domain/models/mahjong_tile.dart';
import 'package:mahjong/ui/core/services/audio_service.dart';
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

class _GameViewState extends ConsumerState<GameView>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  bool _initialTransformSet = false;
  late final AnimationController _confettiController;
  bool _showConfetti = false;
  final Map<String, BoardTile> _departingTiles = {};
  final Map<String, int> _shakeCounts = {};
  Set<String> _newlyUnlockedIds = {};

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    Future.microtask(() {
      ref.read(gameViewModelProvider.notifier).loadLevel(widget.levelNumber);
    });
  }

  @override
  void dispose() {
    AudioService.dispose();
    _confettiController.dispose();
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
      if (prev != null && prev.levelNumber == next.levelNumber) {
        final removed = prev.activeTiles
            .where((t) => !next.activeTiles.any((n) => n.id == t.id))
            .toList();
        if (removed.isNotEmpty) {
          setState(() {
            for (final t in removed) {
              _departingTiles[t.id] = t;
            }
          });
          Future.delayed(const Duration(milliseconds: 220), () {
            if (mounted) {
              setState(() {
                for (final t in removed) {
                  _departingTiles.remove(t.id);
                }
              });
            }
          });
        }

        final prevLocked =
            prev.activeTiles.where((t) => !t.isFree).map((t) => t.id).toSet();
        final nowFree = next.activeTiles
            .where((t) => t.isFree && prevLocked.contains(t.id))
            .map((t) => t.id)
            .toSet();
        if (nowFree.isNotEmpty) {
          setState(() => _newlyUnlockedIds = nowFree);
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              setState(() => _newlyUnlockedIds = const {});
            }
          });
        }
      } else if (prev != null && prev.levelNumber != next.levelNumber) {
        _departingTiles.clear();
        _newlyUnlockedIds.clear();
        _showConfetti = false;
      }

      if (next.isComplete && !(prev?.isComplete ?? false)) {
        setState(() => _showConfetti = true);
        _confettiController.forward(from: 0.0);
        Future.delayed(const Duration(milliseconds: 400), () {
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
            if (_showConfetti)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _ConfettiPainter(
                          progress: _confettiController.value,
                          skin: skin,
                        ),
                      );
                    },
                  ),
                ),
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
            if (state.canSkip)
              Align(
                alignment: Alignment.bottomRight,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 76),
                    child: GestureDetector(
                      key: const Key('skip_button'),
                      onTap: () =>
                          ref.read(gameViewModelProvider.notifier).skip(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: skin.surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: skin.primaryColor,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fast_forward_rounded,
                              size: 20,
                              color: skin.headingColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SKIP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: skin.headingColor,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
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

              final activeWidgets = activeTiles.map((tile) {
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
                      if (!tile.isFree) {
                        setState(() {
                          _shakeCounts[tile.id] =
                              (_shakeCounts[tile.id] ?? 0) + 1;
                        });
                      }
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
                      isNewlyUnlocked: _newlyUnlockedIds.contains(tile.id),
                      shakeCount: _shakeCounts[tile.id] ?? 0,
                    ),
                  ),
                );
              }).toList();

              final departingWidgets = _departingTiles.values.map((tile) {
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

                return _buildDepartingTile(
                  tile: tile,
                  posX: posX,
                  posY: posY,
                  tileW: tileW,
                  tileH: tileH,
                );
              }).toList();

              return RepaintBoundary(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Stack(
                    children: [
                      ...activeWidgets,
                      ...departingWidgets,
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDepartingTile({
    required BoardTile tile,
    required double posX,
    required double posY,
    required double tileW,
    required double tileH,
  }) {
    return Positioned(
      left: posX,
      top: posY,
      width: tileW,
      height: tileH,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final scale = value < 0.25
                ? 1.0 + (value / 0.25) * 0.12
                : (1.12 * (1.0 - (value - 0.25) / 0.75));
            final opacity = (1.0 - value).clamp(0.0, 1.0);
            return Transform.translate(
              offset: Offset(0, -6.0 * value),
              child: Transform.scale(
                scale: scale.clamp(0.0, 1.5),
                child: Opacity(
                  opacity: opacity,
                  child: MahjongTileAssetWidget(
                    typeIndex: tile.tile.type.index,
                    value: tile.tile.value,
                    isFree: true,
                    isSelected: false,
                    isHinted: false,
                    hintProgress: 0.0,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MahjongTileWidget extends StatefulWidget {
  const _MahjongTileWidget({
    super.key,
    required this.tile,
    required this.isSelected,
    required this.isHinted,
    required this.depthOffset,
    this.isNewlyUnlocked = false,
    this.shakeCount = 0,
  });

  final BoardTile tile;
  final bool isSelected;
  final bool isHinted;
  final double depthOffset;
  final bool isNewlyUnlocked;
  final int shakeCount;

  @override
  State<_MahjongTileWidget> createState() => _MahjongTileWidgetState();
}

class _MahjongTileWidgetState extends State<_MahjongTileWidget>
    with TickerProviderStateMixin {
  late final AnimationController _hintController;
  late final AnimationController _shakeController;
  late final AnimationController _popController;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isHinted) {
      _hintController.repeat(reverse: true);
    }
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    if (widget.isNewlyUnlocked) {
      _popController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant _MahjongTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHinted != oldWidget.isHinted) {
      if (widget.isHinted) {
        _hintController.repeat(reverse: true);
      } else {
        _hintController.stop();
        _hintController.reset();
      }
    }
    if (widget.shakeCount != oldWidget.shakeCount) {
      _shakeController.forward(from: 0.0);
    }
    if (widget.isNewlyUnlocked && !oldWidget.isNewlyUnlocked) {
      _popController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _hintController.dispose();
    _shakeController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_hintController, _shakeController, _popController]),
      builder: (context, child) {
        final hintProgress = widget.isHinted ? _hintController.value : 0.0;
        final bobY = widget.isHinted && !widget.isSelected
            ? -3.0 * Curves.easeInOut.transform(hintProgress)
            : 0.0;
        final elevY = widget.isSelected ? -8.0 : 0.0;
        final popY = -5.0 * math.sin(_popController.value * math.pi);
        final targetY = elevY + bobY + popY;

        final popScale = 0.12 * math.sin(_popController.value * math.pi);
        final baseScale = widget.isSelected ? 1.045 : 1.0;
        final scale = baseScale + popScale;

        final shakeX = math.sin(_shakeController.value * math.pi * 4) *
            5.0 *
            (1.0 - _shakeController.value);

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: targetY),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          builder: (context, currentY, child) {
            return Transform.translate(
              offset: Offset(shakeX, currentY),
              child: Transform.scale(
                scale: scale,
                child: MahjongTileAssetWidget(
                  typeIndex: widget.tile.tile.type.index,
                  value: widget.tile.tile.value,
                  isFree: widget.tile.isFree,
                  isSelected: widget.isSelected,
                  isHinted: widget.isHinted,
                  hintProgress: hintProgress,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.skin});

  final double progress;
  final AppSkin skin;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final colors = [
      skin.primaryColor,
      skin.accentColor,
      skin.headingColor,
      const Color(0xFFFDE047),
      const Color(0xFFF472B6),
      const Color(0xFF38BDF8),
    ];

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final randX = ((i * 37) % 100) / 100.0;
      final speedX = (((i * 17) % 200) - 100) * 3.5;
      final speedY = -(((i * 29) % 300) + 200) * 1.6;
      final gravity = 700.0;
      final color = colors[i % colors.length];

      final t = progress * 1.5;
      final startX = size.width * (0.2 + 0.6 * randX);
      final startY = size.height * 0.45;

      final x = startX + speedX * t;
      final y = startY + speedY * t + 0.5 * gravity * t * t;

      if (y > size.height + 20 || y < -50) continue;

      final opacity =
          (1.0 - (progress - 0.6).clamp(0.0, 0.4) / 0.4).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: opacity);

      final rot = progress * ((i % 2 == 0 ? 1 : -1) * (i + 5));
      final pSize = 6.0 + (i % 5) * 1.5;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: pSize, height: pSize * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

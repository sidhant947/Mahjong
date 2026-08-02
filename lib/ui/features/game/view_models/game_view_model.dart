import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mahjong/data/repositories/progress_repository.dart';
import 'package:mahjong/domain/models/mahjong_tile.dart';
import 'package:mahjong/domain/models/mahjong_layout.dart';
import 'package:mahjong/domain/use_cases/mahjong_generator.dart';

@immutable
class MahjongSnapshot {
  const MahjongSnapshot({
    required this.tiles,
    required this.score,
    required this.moveCount,
  });

  final List<BoardTile> tiles;
  final int score;
  final int moveCount;
}

@immutable
class GameViewModelState {
  const GameViewModelState({
    this.levelNumber = 1,
    this.layout,
    this.activeTiles = const [],
    this.selectedTile,
    this.hintPair = const [],
    this.isLoading = false,
    this.isComplete = false,
    this.moveCount = 0,
    this.score = 0,
    this.elapsedSeconds = 0,
    this.canUndo = false,
    this.error,
  });

  final int levelNumber;
  final MahjongLayoutPreset? layout;
  final List<BoardTile> activeTiles;
  final BoardTile? selectedTile;
  final List<BoardTile> hintPair;
  final bool isLoading;
  final bool isComplete;
  final int moveCount;
  final int score;
  final int elapsedSeconds;
  final bool canUndo;
  final String? error;

  GameViewModelState copyWith({
    int? levelNumber,
    MahjongLayoutPreset? layout,
    List<BoardTile>? activeTiles,
    BoardTile? selectedTile,
    bool clearSelectedTile = false,
    List<BoardTile>? hintPair,
    bool clearHintPair = false,
    bool? isLoading,
    bool? isComplete,
    int? moveCount,
    int? score,
    int? elapsedSeconds,
    bool? canUndo,
    String? error,
  }) {
    return GameViewModelState(
      levelNumber: levelNumber ?? this.levelNumber,
      layout: layout ?? this.layout,
      activeTiles: activeTiles ?? this.activeTiles,
      selectedTile: clearSelectedTile ? null : (selectedTile ?? this.selectedTile),
      hintPair: clearHintPair ? const [] : (hintPair ?? this.hintPair),
      isLoading: isLoading ?? this.isLoading,
      isComplete: isComplete ?? this.isComplete,
      moveCount: moveCount ?? this.moveCount,
      score: score ?? this.score,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      canUndo: canUndo ?? this.canUndo,
      error: error,
    );
  }
}

class GameViewModel extends StateNotifier<GameViewModelState> {
  GameViewModel({
    required this.progressRepository,
    required this.mahjongGenerator,
  }) : super(const GameViewModelState());

  final ProgressRepository progressRepository;
  final SolvableMahjongGenerator mahjongGenerator;

  Timer? _timer;
  final List<MahjongSnapshot> _undoStack = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void loadLevel(int levelNumber) {
    _timer?.cancel();
    _undoStack.clear();

    state = GameViewModelState(
      levelNumber: levelNumber,
      isLoading: true,
    );

    final preset = MahjongLayouts.getPresetForLevel(levelNumber);
    final rawTiles = mahjongGenerator.generateSolvableBoard(
      layout: preset,
      seed: levelNumber * 1000 + 42,
    );

    final updatedTiles = _recalculateTileFreedom(rawTiles);

    state = state.copyWith(
      layout: preset,
      activeTiles: updatedTiles,
      isLoading: false,
      isComplete: false,
      moveCount: 0,
      score: 0,
      elapsedSeconds: 0,
      canUndo: false,
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!state.isComplete && !state.isLoading) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  List<BoardTile> _recalculateTileFreedom(List<BoardTile> tiles) {
    return tiles.map((tile) {
      final free = SolvableMahjongGenerator.isTileFree(tile, tiles);
      return tile.copyWith(isFree: free);
    }).toList();
  }

  void selectTile(BoardTile tile) {
    if (state.isComplete || !tile.isFree) {
      HapticFeedback.heavyImpact().catchError((_) {});
      return;
    }

    state = state.copyWith(clearHintPair: true);

    if (state.selectedTile?.id == tile.id) {
      state = state.copyWith(clearSelectedTile: true);
      HapticFeedback.lightImpact().catchError((_) {});
      return;
    }

    if (state.selectedTile == null) {
      state = state.copyWith(selectedTile: tile);
      HapticFeedback.mediumImpact().catchError((_) {});
      return;
    }

    final firstTile = state.selectedTile!;
    if (firstTile.tile.matches(tile.tile)) {
      HapticFeedback.heavyImpact().catchError((_) {});
      _executePairMatch(firstTile, tile);
    } else {
      state = state.copyWith(selectedTile: tile);
      HapticFeedback.mediumImpact().catchError((_) {});
    }
  }

  void _executePairMatch(BoardTile tileA, BoardTile tileB) {
    _undoStack.add(MahjongSnapshot(
      tiles: List.from(state.activeTiles),
      score: state.score,
      moveCount: state.moveCount,
    ));

    final updatedActive = state.activeTiles
        .where((t) => t.id != tileA.id && t.id != tileB.id)
        .toList();

    final recalculatedActive = _recalculateTileFreedom(updatedActive);
    final isDone = recalculatedActive.isEmpty;

    state = state.copyWith(
      activeTiles: recalculatedActive,
      clearSelectedTile: true,
      score: state.score + 100,
      moveCount: state.moveCount + 1,
      canUndo: true,
      isComplete: isDone,
    );

    HapticFeedback.mediumImpact().catchError((_) {});

    if (isDone) {
      _timer?.cancel();
      progressRepository
          .completeLevel(state.levelNumber)
          .catchError((e) => debugPrint('Error saving progress: $e'));
    }
  }

  void undo() {
    if (_undoStack.isEmpty || state.isComplete) return;

    final snapshot = _undoStack.removeLast();
    final recalculatedActive = _recalculateTileFreedom(snapshot.tiles);

    state = state.copyWith(
      activeTiles: recalculatedActive,
      clearSelectedTile: true,
      clearHintPair: true,
      score: snapshot.score,
      moveCount: snapshot.moveCount,
      canUndo: _undoStack.isNotEmpty,
    );

    HapticFeedback.lightImpact().catchError((_) {});
  }

  void hint() {
    if (state.isComplete) return;

    final freeTiles = state.activeTiles.where((t) => t.isFree).toList();
    for (int i = 0; i < freeTiles.length; i++) {
      for (int j = i + 1; j < freeTiles.length; j++) {
        if (freeTiles[i].tile.matches(freeTiles[j].tile)) {
          state = state.copyWith(
            hintPair: [freeTiles[i], freeTiles[j]],
            selectedTile: freeTiles[i],
          );
          HapticFeedback.heavyImpact().catchError((_) {});
          return;
        }
      }
    }
  }

  void shuffle() {
    if (state.isComplete || state.activeTiles.isEmpty) return;

    final random = Random();
    final currentPositions = state.activeTiles.map((t) => t.position).toList();
    final currentTiles = state.activeTiles.map((t) => t.tile).toList()..shuffle(random);

    final List<BoardTile> shuffled = [];
    for (int i = 0; i < currentPositions.length; i++) {
      shuffled.add(BoardTile(
        id: 'shuffled_${i}_${currentPositions[i].x}_${currentPositions[i].y}_${currentPositions[i].z}',
        position: currentPositions[i],
        tile: currentTiles[i],
      ));
    }

    final recalculatedActive = _recalculateTileFreedom(shuffled);

    state = state.copyWith(
      activeTiles: recalculatedActive,
      clearSelectedTile: true,
      clearHintPair: true,
    );

    HapticFeedback.heavyImpact().catchError((_) {});
  }
}

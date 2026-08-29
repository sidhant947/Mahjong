import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mahjong/data/repositories/progress_repository.dart';
import 'package:mahjong/domain/models/mahjong_tile.dart';
import 'package:mahjong/domain/models/mahjong_layout.dart';
import 'package:mahjong/domain/use_cases/mahjong_generator.dart';
import 'package:mahjong/ui/core/services/haptic_service.dart';

@immutable
class MahjongSnapshot {
  const MahjongSnapshot({
    required this.tiles,
    required this.moveCount,
  });

  final List<BoardTile> tiles;
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
    this.elapsedSeconds = 0,
    this.canUndo = false,
    this.availableMoves = 0,
    this.hintsRemaining = 3,
    this.isDeadlocked = false,
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
  final int elapsedSeconds;
  final bool canUndo;
  final int availableMoves;
  final int hintsRemaining;
  final bool isDeadlocked;
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
    int? elapsedSeconds,
    bool? canUndo,
    int? availableMoves,
    int? hintsRemaining,
    bool? isDeadlocked,
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
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      canUndo: canUndo ?? this.canUndo,
      availableMoves: availableMoves ?? this.availableMoves,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      isDeadlocked: isDeadlocked ?? this.isDeadlocked,
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

  Future<void> loadLevel(int levelNumber) async {
    state = state.copyWith(
      levelNumber: levelNumber,
      isLoading: true,
      clearSelectedTile: true,
      clearHintPair: true,
    );

    _undoStack.clear();

    final preset = MahjongLayouts.getPresetForLevel(levelNumber);
    final rawTiles = await mahjongGenerator.generateSolvableBoardAsync(
      layout: preset,
      seed: levelNumber * 1000 + 42,
    );

    final updatedTiles = _recalculateTileFreedom(rawTiles);
    final moves = _calculateAvailableMoves(updatedTiles);

    state = state.copyWith(
      layout: preset,
      activeTiles: updatedTiles,
      isLoading: false,
      isComplete: false,
      moveCount: 0,
      elapsedSeconds: 0,
      canUndo: false,
      hintsRemaining: 3,
      availableMoves: moves,
      isDeadlocked: moves == 0 && updatedTiles.isNotEmpty,
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!state.isComplete && !state.isLoading) {
        state = state.copyWith(
          elapsedSeconds: state.elapsedSeconds + 1,
        );
      }
    });
  }

  List<BoardTile> _recalculateTileFreedom(List<BoardTile> tiles) {
    final updated = tiles.map((tile) {
      final free = SolvableMahjongGenerator.isTileFree(tile, tiles);
      return tile.copyWith(isFree: free);
    }).toList();

    updated.sort((a, b) {
      if (a.position.z != b.position.z) {
        return a.position.z.compareTo(b.position.z);
      }
      if (a.position.y != b.position.y) {
        return a.position.y.compareTo(b.position.y);
      }
      return a.position.x.compareTo(b.position.x);
    });

    return updated;
  }

  int _calculateAvailableMoves(List<BoardTile> tiles) {
    final freeTiles = tiles.where((t) => t.isFree).toList();
    int matches = 0;
    for (int i = 0; i < freeTiles.length; i++) {
      for (int j = i + 1; j < freeTiles.length; j++) {
        if (freeTiles[i].tile.matches(freeTiles[j].tile)) {
          matches++;
        }
      }
    }
    return matches;
  }

  void selectTile(BoardTile tile) {
    if (state.isComplete || !tile.isFree) {
      HapticService.heavyImpact();
      return;
    }

    if (state.hintPair.isNotEmpty && state.hintPair.any((h) => h.id == tile.id)) {
      final hintedOther = state.hintPair.firstWhere((h) => h.id != tile.id);
      state = state.copyWith(clearHintPair: true, clearSelectedTile: true);
      _executePairMatch(tile, hintedOther);
      return;
    }

    state = state.copyWith(clearHintPair: true);

    if (state.selectedTile?.id == tile.id) {
      state = state.copyWith(clearSelectedTile: true);
      HapticService.selectionClick();
      return;
    }

    if (state.selectedTile == null) {
      state = state.copyWith(selectedTile: tile);
      HapticService.selectionClick();
      return;
    }

    final firstTile = state.selectedTile!;
    if (firstTile.tile.matches(tile.tile)) {
      _executePairMatch(firstTile, tile);
    } else {
      state = state.copyWith(selectedTile: tile);
      HapticService.selectionClick();
    }
  }

  void _executePairMatch(BoardTile tileA, BoardTile tileB) {
    _undoStack.add(MahjongSnapshot(
      tiles: List.from(state.activeTiles),
      moveCount: state.moveCount,
    ));

    final updatedActive = state.activeTiles
        .where((t) => t.id != tileA.id && t.id != tileB.id)
        .toList();

    final recalculatedActive = _recalculateTileFreedom(updatedActive);
    final moves = _calculateAvailableMoves(recalculatedActive);
    final isDone = recalculatedActive.isEmpty;

    state = state.copyWith(
      activeTiles: recalculatedActive,
      clearSelectedTile: true,
      moveCount: state.moveCount + 1,
      canUndo: true,
      isComplete: isDone,
      availableMoves: moves,
      isDeadlocked: moves == 0 && !isDone,
    );

    HapticService.mediumImpact();

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
    final moves = _calculateAvailableMoves(recalculatedActive);

    state = state.copyWith(
      activeTiles: recalculatedActive,
      clearSelectedTile: true,
      clearHintPair: true,
      moveCount: snapshot.moveCount,
      canUndo: _undoStack.isNotEmpty,
      availableMoves: moves,
      isDeadlocked: moves == 0 && recalculatedActive.isNotEmpty,
    );

    HapticService.lightImpact();
  }

  void hint() {
    if (state.isComplete || state.hintsRemaining <= 0) return;

    final freeTiles = state.activeTiles.where((t) => t.isFree).toList();
    for (int i = 0; i < freeTiles.length; i++) {
      for (int j = i + 1; j < freeTiles.length; j++) {
        if (freeTiles[i].tile.matches(freeTiles[j].tile)) {
          state = state.copyWith(
            hintPair: [freeTiles[i], freeTiles[j]],
            hintsRemaining: state.hintsRemaining - 1,
          );
          HapticService.heavyImpact();
          return;
        }
      }
    }
  }

  void shuffle() {
    if (state.isComplete || state.activeTiles.isEmpty) return;

    final shuffled = mahjongGenerator.shuffleSolvableRemaining(state.activeTiles);
    final recalculatedActive = _recalculateTileFreedom(shuffled);
    final moves = _calculateAvailableMoves(recalculatedActive);

    state = state.copyWith(
      activeTiles: recalculatedActive,
      clearSelectedTile: true,
      clearHintPair: true,
      availableMoves: moves,
      isDeadlocked: moves == 0 && recalculatedActive.isNotEmpty,
    );

    HapticService.heavyImpact();
  }
}



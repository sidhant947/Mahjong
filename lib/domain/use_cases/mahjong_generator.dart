import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:mahjong/domain/models/mahjong_tile.dart';
import 'package:mahjong/domain/models/mahjong_layout.dart';

class SolvableMahjongGenerator {
  Future<List<BoardTile>> generateSolvableBoardAsync({
    required MahjongLayoutPreset layout,
    required int seed,
  }) async {
    return compute(
      _generateBoardEntryPoint,
      _GenArgs(layout: layout, seed: seed),
    );
  }

  List<BoardTile> generateSolvableBoard({
    required MahjongLayoutPreset layout,
    required int seed,
  }) {
    return _generateBoardEntryPoint(_GenArgs(layout: layout, seed: seed));
  }

  static List<BoardTile> _generateBoardEntryPoint(_GenArgs args) {
    final positions = _deduplicatePositions(args.layout.positions);

    if (positions.length % 2 != 0) {
      throw StateError('Layout "${args.layout.name}" has odd tile count: ${positions.length}');
    }

    final pairsNeeded = positions.length ~/ 2;
    final allPairs = _buildAllMatchingPairs();
    if (allPairs.length < pairsNeeded) {
      throw StateError('Deck too small: need $pairsNeeded pairs, have ${allPairs.length}');
    }

    for (int attempt = 0; attempt < 500; attempt++) {
      final rand = Random(args.seed + attempt * 7919);
      final shuffledPairs = List<List<MahjongTile>>.from(allPairs)..shuffle(rand);
      final selectedPairs = shuffledPairs.take(pairsNeeded).toList()..shuffle(rand);

      final assignment = _buildReverseAssignment(positions, selectedPairs, rand);
      if (assignment == null) continue;

      int idCounter = 1;
      final board = positions
          .map((pos) => BoardTile(
                id: 't_${idCounter++}',
                position: pos,
                tile: assignment[pos]!,
              ))
          .toList();

      if (isBoardSolvable(board)) {
        return board;
      }
    }

    throw StateError('Failed to generate solvable board for "${args.layout.name}" (${positions.length} tiles)');
  }

  List<BoardTile> shuffleSolvableRemaining(List<BoardTile> currentTiles, [int? seed]) {
    if (currentTiles.isEmpty) return currentTiles;
    if (currentTiles.length % 2 != 0) {
      final rand = Random(seed);
      final currentPositions = currentTiles.map((t) => t.position).toList();
      final tiles = currentTiles.map((t) => t.tile).toList()..shuffle(rand);
      return List.generate(
        currentTiles.length,
        (i) => BoardTile(
          id: 'shuffled_${i}_${currentPositions[i].x}_${currentPositions[i].y}_${currentPositions[i].z}',
          position: currentPositions[i],
          tile: tiles[i],
        ),
      );
    }

    final rand = Random(seed ?? DateTime.now().millisecondsSinceEpoch);
    final positions = currentTiles.map((t) => t.position).toList();
    final remainingTiles = currentTiles.map((t) => t.tile).toList();

    final Map<String, List<MahjongTile>> groups = {};
    for (final t in remainingTiles) {
      final key = '${t.type.index}_${t.type == TileType.flower || t.type == TileType.season ? 0 : t.value}';
      groups.putIfAbsent(key, () => []).add(t);
    }

    final List<List<MahjongTile>> pairs = [];
    for (final g in groups.values) {
      for (int i = 0; i + 1 < g.length; i += 2) {
        pairs.add([g[i], g[i + 1]]);
      }
    }

    if (pairs.length * 2 == currentTiles.length) {
      for (int attempt = 0; attempt < 50; attempt++) {
        final pairPool = List<List<MahjongTile>>.from(pairs)..shuffle(rand);
        final assignment = _buildReverseAssignment(positions, pairPool, rand);
        if (assignment != null) {
          int idCounter = 1;
          final board = positions
              .map((pos) => BoardTile(
                    id: 'shf_${idCounter++}_${pos.x}_${pos.y}_${pos.z}',
                    position: pos,
                    tile: assignment[pos]!,
                  ))
              .toList();
          if (isBoardSolvable(board)) {
            return board;
          }
        }
      }
    }

    final currentPositions = currentTiles.map((t) => t.position).toList();
    final shuffledTiles = List<MahjongTile>.from(remainingTiles)..shuffle(rand);
    return List.generate(
      currentTiles.length,
      (i) => BoardTile(
        id: 'shuffled_${i}_${currentPositions[i].x}_${currentPositions[i].y}_${currentPositions[i].z}',
        position: currentPositions[i],
        tile: shuffledTiles[i],
      ),
    );
  }

  static bool isBoardSolvable(List<BoardTile> initialBoard) {
    if (initialBoard.isEmpty) return true;
    final Set<String> visitedStates = {};
    int explored = 0;
    return _dfsSolve(List.from(initialBoard), visitedStates, () => ++explored > 1500);
  }

  static bool _dfsSolve(
    List<BoardTile> board,
    Set<String> visitedStates,
    bool Function() isLimitReached,
  ) {
    if (board.isEmpty) return true;
    if (isLimitReached()) return true;

    final stateKey = _encodeState(board);
    if (!visitedStates.add(stateKey)) return false;

    final freeTiles = board.where((t) => isTileFree(t, board)).toList();
    if (freeTiles.length < 2) return false;

    final Map<String, List<BoardTile>> matchableGroups = {};
    for (final t in freeTiles) {
      final key = '${t.tile.type.index}_${t.tile.type == TileType.flower || t.tile.type == TileType.season ? 0 : t.tile.value}';
      matchableGroups.putIfAbsent(key, () => []).add(t);
    }

    for (final group in matchableGroups.values) {
      if (group.length < 2) continue;
      for (int i = 0; i < group.length; i++) {
        for (int j = i + 1; j < group.length; j++) {
          final t1 = group[i];
          final t2 = group[j];
          final nextBoard = board.where((t) => t.id != t1.id && t.id != t2.id).toList();
          if (_dfsSolve(nextBoard, visitedStates, isLimitReached)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  static String _encodeState(List<BoardTile> board) {
    final ids = board.map((t) => t.id).toList()..sort();
    return ids.join(',');
  }


  static List<TilePosition> _deduplicatePositions(List<TilePosition> positions) {
    final seen = <String>{};
    return positions.where((p) => seen.add('${p.x},${p.y},${p.z}')).toList();
  }

  static List<List<MahjongTile>> _buildAllMatchingPairs() {
    final Map<String, List<MahjongTile>> groups = {};

    void add(MahjongTile t, String key) {
      groups.putIfAbsent(key, () => []).add(t);
    }

    for (final type in [TileType.character, TileType.bamboo, TileType.rod]) {
      for (int v = 1; v <= 9; v++) {
        for (int i = 0; i < 4; i++) {
          add(MahjongTile(type: type, value: v), '${type.index}_$v');
        }
      }
    }
    for (int w = 0; w < 4; w++) {
      for (int i = 0; i < 4; i++) {
        add(MahjongTile(type: TileType.wind, value: w), 'wind_$w');
      }
    }
    for (int d = 0; d < 3; d++) {
      for (int i = 0; i < 4; i++) {
        add(MahjongTile(type: TileType.dragon, value: d), 'dragon_$d');
      }
    }
    for (int f = 0; f < 4; f++) {
      add(MahjongTile(type: TileType.flower, value: f), 'flower');
    }
    for (int s = 0; s < 4; s++) {
      add(MahjongTile(type: TileType.season, value: s), 'season');
    }

    final List<List<MahjongTile>> pairs = [];
    for (final group in groups.values) {
      for (int i = 0; i + 1 < group.length; i += 2) {
        pairs.add([group[i], group[i + 1]]);
      }
    }
    return pairs;
  }

  static Map<TilePosition, MahjongTile>? _buildReverseAssignment(
    List<TilePosition> positions,
    List<List<MahjongTile>> pairPool,
    Random rand,
  ) {
    final remaining = Set<TilePosition>.from(positions);
    final Map<TilePosition, MahjongTile> assignment = {};
    final pool = List<List<MahjongTile>>.from(pairPool);

    while (remaining.isNotEmpty) {
      final free = remaining.where((p) => _isFree(p, remaining)).toList();
      if (free.length < 2) return null;

      free.shuffle(rand);

      bool placed = false;
      for (int i = 0; i < free.length && !placed; i++) {
        final p1 = free[i];
        final rem1 = Set<TilePosition>.from(remaining)..remove(p1);
        final cands = free.where((p) => p != p1 && _isFree(p, rem1)).toList();
        if (cands.isEmpty) continue;
        cands.shuffle(rand);
        final p2 = cands.first;
        if (pool.isEmpty) return null;
        final pair = pool.removeLast();
        assignment[p1] = pair[0];
        assignment[p2] = pair[1];
        remaining..remove(p1)..remove(p2);
        placed = true;
      }
      if (!placed) return null;
    }
    return assignment;
  }

  static bool _isFree(TilePosition pos, Set<TilePosition> board) {
    for (final other in board) {
      if (other == pos) continue;
      if (other.z == pos.z + 1) {
        if ((other.x - pos.x).abs() < 2 && (other.y - pos.y).abs() < 2) return false;
      }
    }

    bool hasLeft = false;
    bool hasRight = false;
    for (final other in board) {
      if (other == pos || other.z != pos.z) continue;
      if (other.x == pos.x - 2 && (other.y - pos.y).abs() < 2) hasLeft = true;
      if (other.x == pos.x + 2 && (other.y - pos.y).abs() < 2) hasRight = true;
    }
    return !(hasLeft && hasRight);
  }

  static bool isTileFree(BoardTile tile, List<BoardTile> board) {
    final pos = tile.position;

    for (final other in board) {
      if (other.id == tile.id) continue;
      if (other.position.z == pos.z + 1) {
        if ((other.position.x - pos.x).abs() < 2 && (other.position.y - pos.y).abs() < 2) {
          return false;
        }
      }
    }

    bool hasLeft = false;
    bool hasRight = false;
    for (final other in board) {
      if (other.id == tile.id || other.position.z != pos.z) continue;
      if (other.position.x == pos.x - 2 && (other.position.y - pos.y).abs() < 2) hasLeft = true;
      if (other.position.x == pos.x + 2 && (other.position.y - pos.y).abs() < 2) hasRight = true;
    }
    return !(hasLeft && hasRight);
  }
}

class _GenArgs {
  const _GenArgs({required this.layout, required this.seed});
  final MahjongLayoutPreset layout;
  final int seed;
}


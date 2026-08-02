import 'dart:math';
import 'package:mahjong/domain/models/mahjong_tile.dart';
import 'package:mahjong/domain/models/mahjong_layout.dart';

class SolvableMahjongGenerator {
  List<BoardTile> generateSolvableBoard({
    required MahjongLayoutPreset layout,
    required int seed,
  }) {
    final positions = _deduplicatePositions(layout.positions);

    if (positions.length % 2 != 0) {
      throw StateError('Layout "${layout.name}" has odd tile count: ${positions.length}');
    }

    final pairsNeeded = positions.length ~/ 2;
    final allPairs = _buildAllMatchingPairs();
    if (allPairs.length < pairsNeeded) {
      throw StateError('Deck too small: need $pairsNeeded pairs, have ${allPairs.length}');
    }

    for (int attempt = 0; attempt < 500; attempt++) {
      final rand = Random(seed + attempt * 7919);
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

      // Verify that this board is indeed solvable forwardly (prevent deadlocks from identical tiles)
      if (_canSolveForwardly(board)) {
        return board;
      }
    }

    throw StateError('Failed to generate solvable board for "${layout.name}" (${positions.length} tiles)');
  }

  // Forward solver check to guarantee 100% solvability without getting stuck on ambiguous duplicate matches
  static bool _canSolveForwardly(List<BoardTile> initialBoard) {
    List<BoardTile> current = List.from(initialBoard);

    while (current.isNotEmpty) {
      final freeTiles = current.where((t) => isTileFree(t, current)).toList();

      BoardTile? matchA;
      BoardTile? matchB;

      for (int i = 0; i < freeTiles.length; i++) {
        for (int j = i + 1; j < freeTiles.length; j++) {
          if (freeTiles[i].tile.matches(freeTiles[j].tile)) {
            matchA = freeTiles[i];
            matchB = freeTiles[j];
            break;
          }
        }
        if (matchA != null) break;
      }

      if (matchA == null || matchB == null) {
        return false;
      }

      current.removeWhere((t) => t.id == matchA!.id || t.id == matchB!.id);
    }

    return true;
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

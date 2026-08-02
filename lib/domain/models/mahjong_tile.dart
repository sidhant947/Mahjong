import 'package:flutter/foundation.dart';

enum TileType {
  character, // 1-9 (Characters 萬)
  bamboo,    // 1-9 (Bamboo 🀐)
  rod,       // 1-9 (Dots/Rods 筒)
  season,    // Spring, Summer, Autumn, Winter (春, 夏, 秋, 冬)
  wind,      // East, South, West, North (東, 南, 西, 北)
  dragon,    // Red, Green, White (中, 發, 白)
  flower,    // Plum, Orchid, Bamboo, Chrysanthemum (梅, 蘭, 竹, 菊)
}

@immutable
class MahjongTile {
  const MahjongTile({
    required this.type,
    required this.value,
  });

  final TileType type;
  final int value; // 1-9 for suits; 0-3 for wind/flower/season; 0-2 for dragon


  bool matches(MahjongTile other) {
    if (type == TileType.flower && other.type == TileType.flower) return true;
    if (type == TileType.season && other.type == TileType.season) return true;
    return type == other.type && value == other.value;
  }
}



/// 3D Position of a tile on the Mahjong Solitaire board
@immutable
class TilePosition {
  const TilePosition({
    required this.x,
    required this.y,
    required this.z,
  });

  final int x;
  final int y;
  final int z;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TilePosition &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}

/// Represents an active tile instance placed on the board
@immutable
class BoardTile {
  const BoardTile({
    required this.id,
    required this.position,
    required this.tile,
    this.isFree = false,
  });

  final String id;
  final TilePosition position;
  final MahjongTile tile;
  final bool isFree;

  BoardTile copyWith({
    String? id,
    TilePosition? position,
    MahjongTile? tile,
    bool? isFree,
  }) {
    return BoardTile(
      id: id ?? this.id,
      position: position ?? this.position,
      tile: tile ?? this.tile,
      isFree: isFree ?? this.isFree,
    );
  }
}

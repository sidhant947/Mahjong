import 'package:flutter/foundation.dart';
import 'package:mahjong/domain/models/mahjong_tile.dart';

@immutable
class MahjongLayoutPreset {
  const MahjongLayoutPreset({
    required this.name,
    required this.description,
    required this.width,
    required this.height,
    required this.depth,
    required this.positions,
  });

  final String name;
  final String description;
  final int width;
  final int height;
  final int depth;
  final List<TilePosition> positions;
}

class MahjongLayouts {
  MahjongLayouts._();

  // Classic Turtle layout — 144 tiles, 5 layers.
  // Coordinates use 2-unit grid (each tile is 2×2). All x,y even.
  static MahjongLayoutPreset get turtle {
    final pos = <TilePosition>[];

    // Layer 0: main 12×8 grid (12 cols × 8 rows = 96) + 4 side wing tiles
    // Wing tiles at far left/right of row y=8
    pos.add(const TilePosition(x: 0, y: 8, z: 0));
    pos.add(const TilePosition(x: 2, y: 8, z: 0));
    pos.add(const TilePosition(x: 28, y: 8, z: 0));
    pos.add(const TilePosition(x: 30, y: 8, z: 0));

    // Main rectangle: x=4..26 (12 cols), y=2..14 (7 rows) = 84 tiles
    for (int y = 2; y <= 14; y += 2) {
      for (int x = 4; x <= 26; x += 2) {
        pos.add(TilePosition(x: x, y: y, z: 0));
      }
    }
    // Layer 0 total: 4 + 84 = 88 → need 12 more from extensions
    // Add top/bottom border row
    for (int x = 4; x <= 26; x += 2) {
      if (x == 4 || x == 26) continue; // already in rectangle
      // Already included in 2..14 range — the rectangle covers all rows
    }

    // Layer 1: x=8..24 (9 cols), y=4..12 (5 rows) = 45 → trim to even
    for (int y = 4; y <= 12; y += 2) {
      for (int x = 8; x <= 22; x += 2) {
        pos.add(TilePosition(x: x, y: y, z: 1));
      }
    }

    // Layer 2: x=10..22 (7 cols), y=6..10 (3 rows) = 21 → trim
    for (int y = 6; y <= 10; y += 2) {
      for (int x = 10; x <= 20; x += 2) {
        pos.add(TilePosition(x: x, y: y, z: 2));
      }
    }

    // Layer 3: x=12..18 (4 cols), y=8 (1 row) = 4
    for (int x = 12; x <= 18; x += 2) {
      pos.add(TilePosition(x: x, y: 8, z: 3));
    }

    // Layer 4: single top tile
    pos.add(const TilePosition(x: 14, y: 8, z: 4));

    // Exactly count and trim to 144
    final dedupe = _dedupe(pos);
    return MahjongLayoutPreset(
      name: 'Turtle',
      description: 'Classic Turtle — the iconic pyramid structure.',
      width: 34,
      height: 18,
      depth: 5,
      positions: _trimToEven(dedupe, 144),
    );
  }


  // Mini Pyramid — beginner, 36 tiles
  static MahjongLayoutPreset get miniPyramid {
    final pos = <TilePosition>[];
    // Layer 0: 5×3 = 15 cols×rows... let's do 6×4 = 24
    for (int y = 4; y <= 10; y += 2) {
      for (int x = 6; x <= 16; x += 2) {
        pos.add(TilePosition(x: x, y: y, z: 0));
      }
    }
    // Layer 1: 4×2 = 8
    for (int y = 6; y <= 8; y += 2) {
      for (int x = 8; x <= 14; x += 2) {
        pos.add(TilePosition(x: x, y: y, z: 1));
      }
    }
    // Layer 2: 2×1 = 2
    pos.add(const TilePosition(x: 10, y: 6, z: 2));
    pos.add(const TilePosition(x: 12, y: 6, z: 2));

    return MahjongLayoutPreset(
      name: 'Mini Pyramid',
      description: 'Compact 34-tile introductory board.',
      width: 24,
      height: 16,
      depth: 3,
      positions: _trimToEven(_dedupe(pos), 34),
    );
  }

  // Twin Peaks — two independent pyramids side by side
  static MahjongLayoutPreset get twinPeaks {
    final pos = <TilePosition>[];

    // Left peak, 3 layers
    for (int z = 0; z < 3; z++) {
      for (int y = 4 + z * 2; y <= 12 - z * 2; y += 2) {
        for (int x = 2 + z * 2; x <= 12 - z * 2; x += 2) {
          pos.add(TilePosition(x: x, y: y, z: z));
        }
      }
    }
    // Right peak, 3 layers (offset by 16)
    for (int z = 0; z < 3; z++) {
      for (int y = 4 + z * 2; y <= 12 - z * 2; y += 2) {
        for (int x = 18 + z * 2; x <= 28 - z * 2; x += 2) {
          pos.add(TilePosition(x: x, y: y, z: z));
        }
      }
    }

    return MahjongLayoutPreset(
      name: 'Twin Peaks',
      description: 'Two symmetric mountain peaks.',
      width: 32,
      height: 18,
      depth: 3,
      positions: _trimToEven(_dedupe(pos), 72),
    );
  }

  // Arena — hollow ring + inner elevated layer
  static MahjongLayoutPreset get arena {
    final pos = <TilePosition>[];

    // Layer 0: border ring (x=4..28, y=2..14), only outer edge
    for (int y = 2; y <= 14; y += 2) {
      for (int x = 4; x <= 28; x += 2) {
        if (x == 4 || x == 28 || y == 2 || y == 14) {
          pos.add(TilePosition(x: x, y: y, z: 0));
        }
      }
    }
    // Layer 1: full inner area
    for (int y = 4; y <= 12; y += 2) {
      for (int x = 8; x <= 24; x += 2) {
        pos.add(TilePosition(x: x, y: y, z: 1));
      }
    }

    return MahjongLayoutPreset(
      name: 'Arena',
      description: 'Ring of tiles surrounding an elevated inner court.',
      width: 32,
      height: 18,
      depth: 2,
      positions: _trimToEven(_dedupe(pos), 96),
    );
  }

  // Great Wall — two long horizontal rows, stacked 4 high
  static MahjongLayoutPreset get greatWall {
    final pos = <TilePosition>[];

    for (int z = 0; z < 4; z++) {
      final xStart = 2 + z * 2;
      final xEnd = 28 - z * 2;
      for (int x = xStart; x <= xEnd; x += 2) {
        pos.add(TilePosition(x: x, y: 4, z: z));
        pos.add(TilePosition(x: x, y: 10, z: z));
      }
    }

    return MahjongLayoutPreset(
      name: 'Great Wall',
      description: 'Two fortified walls stacked four layers high.',
      width: 32,
      height: 18,
      depth: 4,
      positions: _trimToEven(_dedupe(pos), 120),
    );
  }

  // Imperial Pagoda — tall square tiers, shrinking per layer
  static MahjongLayoutPreset get pagoda {
    final pos = <TilePosition>[];

    for (int z = 0; z < 6; z++) {
      final half = 5 - z;
      final cx = 14;
      final cy = 8;
      for (int y = cy - half * 2; y <= cy + half * 2; y += 2) {
        for (int x = cx - half * 2; x <= cx + half * 2; x += 2) {
          if (x >= 0 && y >= 0) pos.add(TilePosition(x: x, y: y, z: z));
        }
      }
    }

    return MahjongLayoutPreset(
      name: 'Imperial Pagoda',
      description: 'Six-tier sacred pagoda.',
      width: 32,
      height: 22,
      depth: 6,
      positions: _trimToEven(_dedupe(pos), 144),
    );
  }

  // Fortress — outer walls + inner keep
  static MahjongLayoutPreset get fortress {
    final pos = <TilePosition>[];

    // Outer wall ring, layer 0
    for (int y = 2; y <= 14; y += 2) {
      for (int x = 2; x <= 28; x += 2) {
        if (x == 2 || x == 28 || y == 2 || y == 14) {
          pos.add(TilePosition(x: x, y: y, z: 0));
        }
      }
    }
    // Inner wall ring, layer 1
    for (int y = 4; y <= 12; y += 2) {
      for (int x = 6; x <= 24; x += 2) {
        if (x == 6 || x == 24 || y == 4 || y == 12) {
          pos.add(TilePosition(x: x, y: y, z: 1));
        }
      }
    }
    // Inner keep, layer 2
    for (int y = 6; y <= 10; y += 2) {
      for (int x = 10; x <= 20; x += 2) {
        pos.add(TilePosition(x: x, y: y, z: 2));
      }
    }

    return MahjongLayoutPreset(
      name: 'Fortress',
      description: 'Concentric castle walls with elevated inner keep.',
      width: 32,
      height: 18,
      depth: 3,
      positions: _trimToEven(_dedupe(pos), 120),
    );
  }

  // Procedural layout for higher levels — uses seeded symmetric pattern
  static MahjongLayoutPreset generateProceduralLayout(int levelNumber) {
    final pos = <TilePosition>[];
    final depth = (3 + (levelNumber % 4)).clamp(3, 6);
    final rng = _Lcg(levelNumber * 1000003 + 7);

    for (int z = 0; z < depth; z++) {
      final maxCols = 8 - z;
      final maxRows = 5 - z ~/ 2;
      for (int row = 0; row < maxRows; row++) {
        for (int col = 0; col < maxCols; col++) {
          // Use LCG to create interesting sparse patterns
          if (rng.next() % 7 != 0) {
            final x = (16 - maxCols + col * 2);
            final y = (8 - maxRows + row * 2);
            if (x >= 0 && y >= 0) pos.add(TilePosition(x: x, y: y, z: z));
          }
        }
      }
    }

    final targetCount = levelNumber <= 5
        ? 34
        : levelNumber <= 15
            ? 72
            : levelNumber <= 30
                ? 88
                : levelNumber <= 50
                    ? 120
                    : 144;

    return MahjongLayoutPreset(
      name: 'Realm #$levelNumber',
      description: 'Procedural Layout #$levelNumber',
      width: 32,
      height: 18,
      depth: depth,
      positions: _trimToEven(_dedupe(pos), targetCount),
    );
  }

  static MahjongLayoutPreset getPresetForLevel(int levelNumber) {
    if (levelNumber <= 5) return miniPyramid;
    if (levelNumber <= 15) return twinPeaks;
    if (levelNumber <= 30) return arena;
    if (levelNumber <= 50) return greatWall;
    if (levelNumber <= 75) return turtle;
    if (levelNumber <= 100) return fortress;
    if (levelNumber <= 150) return pagoda;
    return generateProceduralLayout(levelNumber);
  }

  // Remove duplicate (x,y,z) positions
  static List<TilePosition> _dedupe(List<TilePosition> positions) {
    final seen = <String>{};
    return positions.where((p) => seen.add('${p.x},${p.y},${p.z}')).toList();
  }

  // Trim to at most [max] positions, ensuring count is even
  static List<TilePosition> _trimToEven(List<TilePosition> positions, int max) {
    final count = positions.length < max ? positions.length : max;
    final evenCount = count % 2 == 0 ? count : count - 1;
    return positions.sublist(0, evenCount);
  }
}

// Simple LCG for seeded procedural layout generation (no dart:math dependency)
class _Lcg {
  _Lcg(int seed) : _state = seed & 0x7FFFFFFF;
  int _state;
  int next() {
    _state = (_state * 1664525 + 1013904223) & 0x7FFFFFFF;
    return _state;
  }
}

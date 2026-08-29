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

  // Butterfly layout — 88 tiles, elegant wing structures
  static MahjongLayoutPreset get butterfly {
    final pos = <TilePosition>[];
    for (int y = 4; y <= 12; y += 2) {
      pos.add(TilePosition(x: 14, y: y, z: 0));
      pos.add(TilePosition(x: 16, y: y, z: 0));
      pos.add(TilePosition(x: 14, y: y, z: 1));
      pos.add(TilePosition(x: 16, y: y, z: 1));
    }
    for (int dx = 2; dx <= 10; dx += 2) {
      for (int dy = -4; dy <= 4; dy += 2) {
        if ((dx == 10 && dy.abs() == 4) || (dx == 2 && dy == 0)) continue;
        pos.add(TilePosition(x: 15 - dx, y: 8 + dy, z: 0));
        pos.add(TilePosition(x: 15 + dx, y: 8 + dy, z: 0));
        if (dx <= 6 && dy.abs() <= 2) {
          pos.add(TilePosition(x: 15 - dx, y: 8 + dy, z: 1));
          pos.add(TilePosition(x: 15 + dx, y: 8 + dy, z: 1));
        }
      }
    }
    return MahjongLayoutPreset(
      name: 'Butterfly',
      description: 'Symmetric wing formation with elevated spine.',
      width: 32,
      height: 18,
      depth: 2,
      positions: _validateLayerSupport(_trimToEven(_dedupe(pos), 88)),
    );
  }

  // Dragon / Snake layout — 108 tiles, winding spine and claws
  static MahjongLayoutPreset get dragon {
    final pos = <TilePosition>[];
    for (int x = 4; x <= 26; x += 2) {
      final yOffset = ((x ~/ 4) % 2 == 0) ? 6 : 10;
      pos.add(TilePosition(x: x, y: yOffset, z: 0));
      pos.add(TilePosition(x: x, y: yOffset + 2, z: 0));
      pos.add(TilePosition(x: x, y: yOffset, z: 1));
      pos.add(TilePosition(x: x, y: yOffset + 2, z: 1));
    }
    for (final x in [6, 12, 18, 24]) {
      pos.add(TilePosition(x: x, y: 2, z: 0));
      pos.add(TilePosition(x: x, y: 14, z: 0));
    }
    for (int x = 8; x <= 22; x += 2) {
      pos.add(TilePosition(x: x, y: 8, z: 2));
    }
    return MahjongLayoutPreset(
      name: 'Celestial Dragon',
      description: 'Coiling serpentine dragon with multi-level head and tail.',
      width: 32,
      height: 18,
      depth: 3,
      positions: _validateLayerSupport(_trimToEven(_dedupe(pos), 108)),
    );
  }

  // Procedural layout for higher levels — guarantees horizontal and vertical 4-way symmetry and layer support
  static MahjongLayoutPreset generateProceduralLayout(int levelNumber) {
    final depth = (2 + (levelNumber % 3)).clamp(2, 4);
    final rng = _Lcg(levelNumber * 1000003 + 7);
    final pos = <TilePosition>[];

    final targetCount = levelNumber <= 5
        ? 34
        : levelNumber <= 15
            ? 72
            : levelNumber <= 30
                ? 88
                : levelNumber <= 50
                    ? 108
                    : levelNumber <= 100
                        ? 120
                        : 144;

    const cx = 15;
    const cy = 8;

    for (int z = 0; z < depth; z++) {
      final maxDx = 6 - z;
      final maxDy = 3 - (z ~/ 2);

      for (int dy = 0; dy <= maxDy; dy++) {
        for (int dx = 0; dx <= maxDx; dx++) {
          if (z == 0 || rng.next() % 5 != 0) {
            final xLeft = cx - (dx * 2);
            final xRight = cx + (dx * 2);
            final yTop = cy - (dy * 2);
            final yBottom = cy + (dy * 2);

            pos.add(TilePosition(x: xLeft, y: yTop, z: z));
            pos.add(TilePosition(x: xRight, y: yTop, z: z));
            pos.add(TilePosition(x: xLeft, y: yBottom, z: z));
            pos.add(TilePosition(x: xRight, y: yBottom, z: z));
          }
        }
      }
    }

    final validPositions = _validateLayerSupport(_trimToEven(_dedupe(pos), targetCount));

    return MahjongLayoutPreset(
      name: 'Realm #$levelNumber',
      description: 'Harmonic procedural realm #$levelNumber',
      width: 34,
      height: 18,
      depth: depth,
      positions: validPositions,
    );
  }

  static MahjongLayoutPreset getPresetForLevel(int levelNumber) {
    if (levelNumber <= 5) return miniPyramid;
    if (levelNumber <= 15) return twinPeaks;
    if (levelNumber <= 30) return arena;
    if (levelNumber <= 50) return butterfly;
    if (levelNumber <= 75) return greatWall;
    if (levelNumber <= 100) return dragon;
    if (levelNumber <= 125) return turtle;
    if (levelNumber <= 150) return fortress;
    if (levelNumber <= 175) return pagoda;
    return generateProceduralLayout(levelNumber);
  }

  // Ensures higher layer tiles have at least 1 supporting tile beneath them
  static List<TilePosition> _validateLayerSupport(List<TilePosition> positions) {
    final result = <TilePosition>[];
    final layerMap = <int, Set<String>>{};

    for (final p in positions) {
      layerMap.putIfAbsent(p.z, () => <String>{}).add('${p.x},${p.y}');
    }

    for (int z = 0; z <= 10; z++) {
      if (!layerMap.containsKey(z)) continue;
      final coords = layerMap[z]!;
      for (final coord in coords) {
        final parts = coord.split(',');
        final x = int.parse(parts[0]);
        final y = int.parse(parts[1]);

        if (z == 0) {
          result.add(TilePosition(x: x, y: y, z: 0));
        } else {
          final belowLayer = layerMap[z - 1] ?? {};
          bool supported = false;
          for (int dx = -1; dx <= 1; dx++) {
            for (int dy = -1; dy <= 1; dy++) {
              if (belowLayer.contains('${x + dx * 2},${y + dy * 2}')) {
                supported = true;
                break;
              }
            }
            if (supported) break;
          }
          if (supported) {
            result.add(TilePosition(x: x, y: y, z: z));
          }
        }
      }
    }

    return _trimToEven(result, result.length);
  }

  static List<TilePosition> _dedupe(List<TilePosition> positions) {
    final seen = <String>{};
    return positions.where((p) => seen.add('${p.x},${p.y},${p.z}')).toList();
  }

  static List<TilePosition> _trimToEven(List<TilePosition> positions, int max) {
    final count = positions.length < max ? positions.length : max;
    final evenCount = count % 2 == 0 ? count : count - 1;
    return positions.sublist(0, evenCount);
  }
}

class _Lcg {
  _Lcg(int seed) : _state = seed & 0x7FFFFFFF;
  int _state;
  int next() {
    _state = (_state * 1664525 + 1013904223) & 0x7FFFFFFF;
    return _state;
  }
}

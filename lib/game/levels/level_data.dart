// ─────────────────────────────────────────────────────
//  MODULAR LEVEL DESIGNER
//  Add new levels by creating a LevelData and appending
//  it to the `levels` list at the bottom of this file.
// ─────────────────────────────────────────────────────

enum PlatformType {
  dirt,   // classic brown dirt block
  brick,  // red brick (can be broken by jumping)
  pipe,   // green pipe (impassable)
  cloud,  // semi-transparent cloud platform
  stone,  // grey stone block
}

enum EnemyType {
  goomba,   // walks forward, player can stomp
  koopa,    // turtle with shell, slides when stomped
  flying,   // flies in a sine wave pattern
  spiky,    // cannot be stomped
}

enum PickupType {
  coin,
  firePower,
  teleport,
  star,
  shield,
}

// ─────────────────────────────────────────────────────
//  Data Classes
// ─────────────────────────────────────────────────────

class PlatformDef {
  /// X position in world units (from level start, 0 = starts off-screen right).
  final double x;

  /// Y position as a fraction from 0 (top of screen) to 1 (ground).
  /// Ground level is ~0.85; use lower values for elevated platforms.
  final double yFraction;

  /// Width in world units.
  final double width;

  final PlatformType type;

  const PlatformDef({
    required this.x,
    required this.yFraction,
    required this.width,
    this.type = PlatformType.dirt,
  });
}

class EnemyDef {
  /// X position in world units from level start.
  final double x;

  /// Y fraction (0 = top, 1 = ground). Use ground (0.85) for walking enemies.
  /// Use 0.4–0.6 for flying enemies.
  final double yFraction;

  final EnemyType type;

  /// For walking enemies: patrol distance left/right around spawn.
  final double patrolRange;

  const EnemyDef({
    required this.x,
    required this.yFraction,
    required this.type,
    this.patrolRange = 80.0,
  });
}

class PickupDef {
  final double x;
  final double yFraction;
  final PickupType type;

  const PickupDef({
    required this.x,
    required this.yFraction,
    this.type = PickupType.coin,
  });
}

class LevelData {
  final String name;
  final List<PlatformDef> platforms;
  final List<EnemyDef> enemies;
  final List<PickupDef> pickups;

  /// Background sky gradient (top color).
  final int skyColorTop;

  /// Background sky gradient (bottom color).
  final int skyColorBottom;

  /// Length of the level in world units. When scrolled this far, next level loads.
  final double length;

  const LevelData({
    required this.name,
    required this.platforms,
    required this.enemies,
    required this.pickups,
    this.skyColorTop = 0xFF5C94FC,
    this.skyColorBottom = 0xFF9BB8FF,
    this.length = 3000,
  });
}

// ─────────────────────────────────────────────────────
//  LEVEL DEFINITIONS
//  To add a level: duplicate a LevelData block and
//  edit platforms / enemies / pickups.
// ─────────────────────────────────────────────────────

const List<LevelData> levels = [
  // ── LEVEL 1 ─ Green Hills ─────────────────────────
  LevelData(
    name: 'Green Hills',
    skyColorTop: 0xFF5C94FC,
    skyColorBottom: 0xFFB0CCFF,
    length: 3200,
    platforms: [
      // Initial ground extensions are handled procedurally.
      // Elevated platforms:
      PlatformDef(x: 400,  yFraction: 0.66, width: 160, type: PlatformType.dirt),
      PlatformDef(x: 620,  yFraction: 0.60, width: 100, type: PlatformType.dirt),
      PlatformDef(x: 780,  yFraction: 0.53, width: 80,  type: PlatformType.brick),
      PlatformDef(x: 950,  yFraction: 0.65, width: 200, type: PlatformType.dirt),
      PlatformDef(x: 1200, yFraction: 0.58, width: 130, type: PlatformType.cloud),
      PlatformDef(x: 1380, yFraction: 0.50, width: 90,  type: PlatformType.brick),
      PlatformDef(x: 1550, yFraction: 0.63, width: 150, type: PlatformType.dirt),
      PlatformDef(x: 1750, yFraction: 0.55, width: 110, type: PlatformType.cloud),
      PlatformDef(x: 1900, yFraction: 0.47, width: 80,  type: PlatformType.brick),
      PlatformDef(x: 2050, yFraction: 0.65, width: 180, type: PlatformType.dirt),
      PlatformDef(x: 2280, yFraction: 0.55, width: 100, type: PlatformType.cloud),
      PlatformDef(x: 2450, yFraction: 0.46, width: 90,  type: PlatformType.brick),
      PlatformDef(x: 2650, yFraction: 0.60, width: 160, type: PlatformType.stone),
      PlatformDef(x: 2850, yFraction: 0.52, width: 120, type: PlatformType.dirt),
      // Pipes (vertical wall/obstacle)
      PlatformDef(x: 700,  yFraction: 0.76, width: 44,  type: PlatformType.pipe),
      PlatformDef(x: 1480, yFraction: 0.76, width: 44,  type: PlatformType.pipe),
      PlatformDef(x: 2300, yFraction: 0.76, width: 44,  type: PlatformType.pipe),
    ],
    enemies: [
      EnemyDef(x: 500,  yFraction: 0.85, type: EnemyType.goomba, patrolRange: 60),
      EnemyDef(x: 720,  yFraction: 0.85, type: EnemyType.goomba, patrolRange: 80),
      EnemyDef(x: 900,  yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 100),
      EnemyDef(x: 1100, yFraction: 0.45, type: EnemyType.flying, patrolRange: 120),
      EnemyDef(x: 1350, yFraction: 0.85, type: EnemyType.goomba, patrolRange: 60),
      EnemyDef(x: 1600, yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 80),
      EnemyDef(x: 1750, yFraction: 0.42, type: EnemyType.flying, patrolRange: 140),
      EnemyDef(x: 2000, yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 100),
      EnemyDef(x: 2200, yFraction: 0.40, type: EnemyType.flying, patrolRange: 150),
      EnemyDef(x: 2400, yFraction: 0.85, type: EnemyType.goomba, patrolRange: 70),
      EnemyDef(x: 2500, yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 90),
      EnemyDef(x: 2700, yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 120),
      EnemyDef(x: 2900, yFraction: 0.42, type: EnemyType.flying, patrolRange: 160),
    ],
    pickups: [
      // Coin rows
      PickupDef(x: 350,  yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 386,  yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 422,  yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 460,  yFraction: 0.62, type: PickupType.coin),
      PickupDef(x: 490,  yFraction: 0.62, type: PickupType.coin),
      PickupDef(x: 640,  yFraction: 0.55, type: PickupType.coin),
      PickupDef(x: 670,  yFraction: 0.55, type: PickupType.coin),
      PickupDef(x: 700,  yFraction: 0.55, type: PickupType.coin),
      // Superpower pickups
      PickupDef(x: 800,  yFraction: 0.62, type: PickupType.firePower),
      PickupDef(x: 1100, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1130, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1160, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1400, yFraction: 0.45, type: PickupType.teleport),
      PickupDef(x: 1600, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1630, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1660, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1800, yFraction: 0.50, type: PickupType.coin),
      PickupDef(x: 1830, yFraction: 0.50, type: PickupType.coin),
      PickupDef(x: 1960, yFraction: 0.42, type: PickupType.star),
      PickupDef(x: 2100, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 2130, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 2350, yFraction: 0.60, type: PickupType.shield),
      PickupDef(x: 2500, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 2530, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 2560, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 2700, yFraction: 0.55, type: PickupType.coin),
      PickupDef(x: 2730, yFraction: 0.55, type: PickupType.coin),
      PickupDef(x: 2850, yFraction: 0.47, type: PickupType.firePower),
    ],
  ),

  // ── LEVEL 2 ─ Desert Dunes ─────────────────────────
  LevelData(
    name: 'Desert Dunes',
    skyColorTop: 0xFFE8A020,
    skyColorBottom: 0xFFFFD580,
    length: 3500,
    platforms: [
      PlatformDef(x: 380,  yFraction: 0.64, width: 140, type: PlatformType.stone),
      PlatformDef(x: 580,  yFraction: 0.56, width: 120, type: PlatformType.stone),
      PlatformDef(x: 760,  yFraction: 0.48, width: 90,  type: PlatformType.brick),
      PlatformDef(x: 940,  yFraction: 0.62, width: 170, type: PlatformType.stone),
      PlatformDef(x: 1160, yFraction: 0.55, width: 110, type: PlatformType.stone),
      PlatformDef(x: 1340, yFraction: 0.47, width: 80,  type: PlatformType.brick),
      PlatformDef(x: 1550, yFraction: 0.63, width: 190, type: PlatformType.stone),
      PlatformDef(x: 1790, yFraction: 0.53, width: 130, type: PlatformType.stone),
      PlatformDef(x: 1970, yFraction: 0.44, width: 100, type: PlatformType.brick),
      PlatformDef(x: 2200, yFraction: 0.64, width: 200, type: PlatformType.stone),
      PlatformDef(x: 2450, yFraction: 0.54, width: 120, type: PlatformType.stone),
      PlatformDef(x: 2650, yFraction: 0.44, width: 100, type: PlatformType.brick),
      PlatformDef(x: 2900, yFraction: 0.62, width: 160, type: PlatformType.stone),
      PlatformDef(x: 3100, yFraction: 0.52, width: 130, type: PlatformType.stone),
      // Pipes
      PlatformDef(x: 650,  yFraction: 0.76, width: 44, type: PlatformType.pipe),
      PlatformDef(x: 1450, yFraction: 0.76, width: 44, type: PlatformType.pipe),
      PlatformDef(x: 2350, yFraction: 0.76, width: 44, type: PlatformType.pipe),
      PlatformDef(x: 3000, yFraction: 0.76, width: 44, type: PlatformType.pipe),
    ],
    enemies: [
      EnemyDef(x: 450,  yFraction: 0.85, type: EnemyType.goomba, patrolRange: 80),
      EnemyDef(x: 650,  yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 90),
      EnemyDef(x: 850,  yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 70),
      EnemyDef(x: 1000, yFraction: 0.40, type: EnemyType.flying, patrolRange: 140),
      EnemyDef(x: 1200, yFraction: 0.85, type: EnemyType.goomba, patrolRange: 80),
      EnemyDef(x: 1250, yFraction: 0.85, type: EnemyType.goomba, patrolRange: 40),
      EnemyDef(x: 1500, yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 100),
      EnemyDef(x: 1700, yFraction: 0.38, type: EnemyType.flying, patrolRange: 160),
      EnemyDef(x: 1900, yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 110),
      EnemyDef(x: 2100, yFraction: 0.38, type: EnemyType.flying, patrolRange: 140),
      EnemyDef(x: 2300, yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 90),
      EnemyDef(x: 2500, yFraction: 0.85, type: EnemyType.goomba, patrolRange: 80),
      EnemyDef(x: 2550, yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 100),
      EnemyDef(x: 2800, yFraction: 0.38, type: EnemyType.flying, patrolRange: 160),
      EnemyDef(x: 3000, yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 80),
      EnemyDef(x: 3200, yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 90),
    ],
    pickups: [
      PickupDef(x: 300,  yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 330,  yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 360,  yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 600,  yFraction: 0.51, type: PickupType.coin),
      PickupDef(x: 630,  yFraction: 0.51, type: PickupType.coin),
      PickupDef(x: 760,  yFraction: 0.43, type: PickupType.firePower),
      PickupDef(x: 1000, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1030, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1200, yFraction: 0.50, type: PickupType.coin),
      PickupDef(x: 1230, yFraction: 0.50, type: PickupType.coin),
      PickupDef(x: 1340, yFraction: 0.42, type: PickupType.teleport),
      PickupDef(x: 1700, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1900, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1930, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1970, yFraction: 0.39, type: PickupType.star),
      PickupDef(x: 2100, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 2200, yFraction: 0.59, type: PickupType.coin),
      PickupDef(x: 2230, yFraction: 0.59, type: PickupType.coin),
      PickupDef(x: 2450, yFraction: 0.49, type: PickupType.shield),
      PickupDef(x: 2700, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 2730, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 3100, yFraction: 0.47, type: PickupType.firePower),
    ],
  ),

  // ── LEVEL 3 ─ Sky Fortress ────────────────────────
  LevelData(
    name: 'Sky Fortress',
    skyColorTop: 0xFF1A0A3E,
    skyColorBottom: 0xFF3D1A7A,
    length: 4000,
    platforms: [
      // Sparse floating platforms high up
      PlatformDef(x: 300,  yFraction: 0.62, width: 120, type: PlatformType.cloud),
      PlatformDef(x: 480,  yFraction: 0.52, width: 90,  type: PlatformType.cloud),
      PlatformDef(x: 630,  yFraction: 0.42, width: 80,  type: PlatformType.brick),
      PlatformDef(x: 760,  yFraction: 0.55, width: 100, type: PlatformType.stone),
      PlatformDef(x: 920,  yFraction: 0.46, width: 80,  type: PlatformType.cloud),
      PlatformDef(x: 1060, yFraction: 0.36, width: 100, type: PlatformType.brick),
      PlatformDef(x: 1230, yFraction: 0.50, width: 130, type: PlatformType.stone),
      PlatformDef(x: 1420, yFraction: 0.40, width: 90,  type: PlatformType.cloud),
      PlatformDef(x: 1570, yFraction: 0.30, width: 80,  type: PlatformType.brick),
      PlatformDef(x: 1720, yFraction: 0.45, width: 110, type: PlatformType.stone),
      PlatformDef(x: 1900, yFraction: 0.35, width: 90,  type: PlatformType.cloud),
      PlatformDef(x: 2070, yFraction: 0.50, width: 140, type: PlatformType.stone),
      PlatformDef(x: 2280, yFraction: 0.40, width: 100, type: PlatformType.brick),
      PlatformDef(x: 2450, yFraction: 0.55, width: 130, type: PlatformType.stone),
      PlatformDef(x: 2640, yFraction: 0.42, width: 100, type: PlatformType.cloud),
      PlatformDef(x: 2830, yFraction: 0.32, width: 90,  type: PlatformType.brick),
      PlatformDef(x: 3020, yFraction: 0.48, width: 140, type: PlatformType.stone),
      PlatformDef(x: 3250, yFraction: 0.38, width: 100, type: PlatformType.cloud),
      PlatformDef(x: 3450, yFraction: 0.50, width: 160, type: PlatformType.stone),
      PlatformDef(x: 3680, yFraction: 0.42, width: 120, type: PlatformType.brick),
      // Pipes
      PlatformDef(x: 560,  yFraction: 0.76, width: 44, type: PlatformType.pipe),
      PlatformDef(x: 1350, yFraction: 0.76, width: 44, type: PlatformType.pipe),
      PlatformDef(x: 2200, yFraction: 0.76, width: 44, type: PlatformType.pipe),
      PlatformDef(x: 3150, yFraction: 0.76, width: 44, type: PlatformType.pipe),
    ],
    enemies: [
      EnemyDef(x: 400,  yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 90),
      EnemyDef(x: 600,  yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 80),
      EnemyDef(x: 750,  yFraction: 0.38, type: EnemyType.flying, patrolRange: 160),
      EnemyDef(x: 900,  yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 90),
      EnemyDef(x: 1050, yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 100),
      EnemyDef(x: 1100, yFraction: 0.32, type: EnemyType.flying, patrolRange: 150),
      EnemyDef(x: 1300, yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 70),
      EnemyDef(x: 1500, yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 110),
      EnemyDef(x: 1550, yFraction: 0.30, type: EnemyType.flying, patrolRange: 180),
      EnemyDef(x: 1800, yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 80),
      EnemyDef(x: 1950, yFraction: 0.35, type: EnemyType.flying, patrolRange: 160),
      EnemyDef(x: 2100, yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 100),
      EnemyDef(x: 2200, yFraction: 0.35, type: EnemyType.flying, patrolRange: 140),
      EnemyDef(x: 2400, yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 90),
      EnemyDef(x: 2600, yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 120),
      EnemyDef(x: 2700, yFraction: 0.35, type: EnemyType.flying, patrolRange: 180),
      EnemyDef(x: 2900, yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 80),
      EnemyDef(x: 3100, yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 100),
      EnemyDef(x: 3200, yFraction: 0.32, type: EnemyType.flying, patrolRange: 200),
      EnemyDef(x: 3400, yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 90),
      EnemyDef(x: 3600, yFraction: 0.85, type: EnemyType.koopa,  patrolRange: 110),
      EnemyDef(x: 3700, yFraction: 0.30, type: EnemyType.flying, patrolRange: 200),
      EnemyDef(x: 3900, yFraction: 0.85, type: EnemyType.spiky,  patrolRange: 80),
    ],
    pickups: [
      PickupDef(x: 350,  yFraction: 0.57, type: PickupType.coin),
      PickupDef(x: 480,  yFraction: 0.47, type: PickupType.coin),
      PickupDef(x: 510,  yFraction: 0.47, type: PickupType.coin),
      PickupDef(x: 630,  yFraction: 0.37, type: PickupType.firePower),
      PickupDef(x: 850,  yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 880,  yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1060, yFraction: 0.31, type: PickupType.teleport),
      PickupDef(x: 1300, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1330, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1420, yFraction: 0.35, type: PickupType.coin),
      PickupDef(x: 1570, yFraction: 0.25, type: PickupType.star),
      PickupDef(x: 1800, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 1830, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 2070, yFraction: 0.45, type: PickupType.coin),
      PickupDef(x: 2100, yFraction: 0.45, type: PickupType.coin),
      PickupDef(x: 2280, yFraction: 0.35, type: PickupType.shield),
      PickupDef(x: 2500, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 2640, yFraction: 0.37, type: PickupType.coin),
      PickupDef(x: 2670, yFraction: 0.37, type: PickupType.coin),
      PickupDef(x: 2830, yFraction: 0.27, type: PickupType.firePower),
      PickupDef(x: 3050, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 3080, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 3250, yFraction: 0.33, type: PickupType.teleport),
      PickupDef(x: 3450, yFraction: 0.45, type: PickupType.coin),
      PickupDef(x: 3480, yFraction: 0.45, type: PickupType.coin),
      PickupDef(x: 3680, yFraction: 0.37, type: PickupType.star),
      PickupDef(x: 3800, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 3830, yFraction: 0.75, type: PickupType.coin),
      PickupDef(x: 3860, yFraction: 0.75, type: PickupType.coin),
    ],
  ),
];

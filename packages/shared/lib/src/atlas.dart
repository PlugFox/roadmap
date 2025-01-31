import 'package:meta/meta.dart';

/// Width of the skill atlas in pixels.
const double kSkillAtlasWidth = 1024;

/// Height of the skill atlas in pixels.
const double kSkillAtlasHeight = 1024;

/// Size of the skill sprite in the skill atlas (width and height).
const double kSkillAtlasTileSize = 32;

/// Number of rows in the skill atlas.
const int kSkillAtlasRows = kSkillAtlasWidth ~/ kSkillAtlasTileSize;

/// Number of columns in the skill atlas.
const int kSkillAtlasColumns = kSkillAtlasHeight ~/ kSkillAtlasTileSize;

@immutable
class SkillSprite {
  /// Returns the skill sprite by its id.
  factory SkillSprite(int id) => values[id];

  @literal
  const SkillSprite.literal(this.id)
      : dx = id % kSkillAtlasRows * kSkillAtlasTileSize,
        dy = id ~/ kSkillAtlasColumns * kSkillAtlasTileSize;

  /// List of all skill sprites.
  static final List<SkillSprite> values = List.generate(
    kSkillAtlasRows * kSkillAtlasColumns,
    SkillSprite.literal,
    growable: false,
  );

  /// Unique identifier of the skill sprite.
  final int id;

  /// X coordinate of the skill sprite in the skill atlas.
  final double dx;

  /// Y coordinate of the skill sprite in the skill atlas.
  final double dy;

  /// Size of the skill sprite in the skill atlas (width and height).
  double get size => kSkillAtlasTileSize;
}

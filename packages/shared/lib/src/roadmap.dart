import 'package:meta/meta.dart';
import 'package:shared/src/atlas.dart';
import 'package:shared/src/color.dart';
import 'package:shared/src/geometry.dart';

@immutable
final class Roadmap$Area implements Comparable<Roadmap$Area> {
  const Roadmap$Area({
    required this.id,
    required this.name,
    required this.description,
    required this.boundary,
    required this.color,
  });

  /// Unique identifier of the area.
  final int id;

  /// Name of the area.
  final String name;

  /// Description of the area.
  final String description;

  /// Rectangle of the area in the roadmap.
  /// Rectangle is defined by the top-left and bottom-right corners.
  /// rect.x - left, rect.y - top, rect.z - right, rect.w - bottom
  final Rect boundary;

  /// Color of the area.
  final Color color;

  @override
  int compareTo(covariant Roadmap$Area other) => id.compareTo(other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Roadmap$Area && id == other.id;

  @override
  String toString() => 'Area{id: $id, name: $name}';
}

@immutable
final class Roadmap$Rank implements Comparable<Roadmap$Rank> {
  const Roadmap$Rank({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });

  /// Unique identifier of the rank.
  final int id;

  /// Name of the rank.
  final String name;

  /// Description of the rank.
  final String description;

  /// Color of the rank.
  final Color color;

  @override
  int compareTo(covariant Roadmap$Rank other) => id.compareTo(other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Roadmap$Rank && id == other.id;

  @override
  String toString() => 'Rank{id: $id, name: $name}';
}

@immutable
final class Roadmap$Level implements Comparable<Roadmap$Level> {
  const Roadmap$Level({
    required this.id,
    required this.name,
    required this.description,
    required this.radius,
    required this.color,
  });

  /// Unique identifier of the level.
  final int id;

  /// Name of the level.
  final String name;

  /// Description of the level.
  final String description;

  /// Radius of the level in the roadmap.
  final double radius;

  /// Color of the level.
  final Color color;

  @override
  int compareTo(covariant Roadmap$Level other) => id.compareTo(other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Roadmap$Level && id == other.id;

  @override
  String toString() => 'Level{id: $id, name: $name}';
}

@immutable
final class Roadmap$Tag implements Comparable<Roadmap$Tag> {
  const Roadmap$Tag({
    required this.id,
    required this.name,
    required this.description,
    required this.sprite,
  });

  /// Unique identifier of the tag.
  final int id;

  /// Name of the tag.
  final String name;

  /// Description of the tag.
  final String description;

  /// Position of the sprite in the sprite atlas.
  /// Position is calculated as follows: x = id % 32 * 32, y = id ~/ 32 * 32
  /// E.g.
  /// Vector2(
  ///   id % 32 * 32,
  ///   id ~/ 32 * 32,
  /// )
  final SkillSprite sprite;

  @override
  int compareTo(covariant Roadmap$Tag other) => id.compareTo(other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Roadmap$Tag && id == other.id;

  @override
  String toString() => 'Tag{id: $id, name: $name}';
}

@immutable
final class Roadmap$Skill implements Comparable<Roadmap$Skill> {
  Roadmap$Skill({
    required this.id,
    required this.name,
    required this.level,
    required this.sprite,
    required this.experience,
    required this.notable,
    required this.color,
    required this.boundary,
    required this.parent,
    required this.tags,
    required this.meta,
  }) : center = boundary.center;

  /// Unique identifier of the skill.
  final int id;

  /// Name of the skill.
  final String name;

  /// Level of the skill.
  final Roadmap$Level level;

  /// Sprite of the skill in the sprite atlas.
  /// Sprite is defined by the top-left corner.
  final SkillSprite sprite;

  /// Experience gained from the skill.
  final int experience;

  /// Whether the skill is notable.
  final bool notable;

  /// Color of the skill.
  final Color color;

  /// Rectangle of the skill in the roadmap.
  /// Rectangle is defined by the top-left and bottom-right corners.
  final Rect boundary;

  /// Center of the skill in the roadmap.
  /// Center is defined as a Vector2 with x and y coordinates.
  /// x - center x coordinate, y - center y coordinate
  final Offset center;

  /// Prerequisite (parent) skill id if any.
  /// If the skill has no parent, then the value is -1.
  final int parent;

  /// Whether the skill has a parent.
  bool get hasParent => parent != -1;

  /// Tags of the skill.
  /// Ordered set of tags that describe the skill.
  final Set<Roadmap$Tag> tags;

  /// Additional metadata of the skill.
  /// Metadata is defined as a unordered map of key-value pairs.
  final Map<String, String> meta;

  /// Creates a copy of this skill with the given fields replaced by the new values.
  Roadmap$Skill copyWith({
    int? id,
    String? name,
    Roadmap$Level? level,
    SkillSprite? sprite,
    int? experience,
    bool? notable,
    Color? color,
    Rect? boundary,
    int? parent,
    Set<Roadmap$Tag>? tags,
    Map<String, String>? meta,
  }) =>
      Roadmap$Skill(
        id: id ?? this.id,
        name: name ?? this.name,
        level: level ?? this.level,
        sprite: sprite ?? this.sprite,
        experience: experience ?? this.experience,
        notable: notable ?? this.notable,
        color: color ?? this.color,
        boundary: boundary ?? this.boundary,
        parent: parent ?? this.parent,
        tags: tags ?? this.tags,
        meta: meta ?? this.meta,
      );

  @override
  int compareTo(covariant Roadmap$Skill other) {
    // Compare by levels ids first
    if (level.id.compareTo(other.level.id) case int v when v != 0) return v;
    // Then compare by first tag ids
    if (tags.first.id.compareTo(other.tags.first.id) case int v when v != 0) return v;
    // Then compare by boundary y coordinates
    if (boundary.top.compareTo(other.boundary.top) case int v when v != 0) return v;
    // Then compare by boundary x coordinates
    if (boundary.left.compareTo(other.boundary.left) case int v when v != 0) return v;
    // Then compare by skill ids
    return id.compareTo(other.id);
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Roadmap$Skill && id == other.id;

  @override
  String toString() => 'Skill{id: $id, name: $name}';
}

@immutable
final class Roadmap {
  const Roadmap({
    required this.version,
    required this.language,
    required this.boundary,
    required this.areas,
    required this.ranks,
    required this.levels,
    required this.tags,
    required this.skills,
  });

  /// Version of the roadmap.
  final String version;

  /// Language of the roadmap.
  final String language;

  /// Rectangle boundary of the roadmap.
  /// Rectangle is defined by the top-left and bottom-right corners.
  /// rect.x - left, rect.y - top, rect.z - right, rect.w - bottom
  final Rect boundary;

  /// Areas of the roadmap.
  final List<Roadmap$Area> areas;

  /// Ranks of the roadmap.
  final List<Roadmap$Rank> ranks;

  /// Levels of the roadmap.
  final List<Roadmap$Level> levels;

  /// Tags of the roadmap.
  final List<Roadmap$Tag> tags;

  /// Skills of the roadmap.
  final Map<int, Roadmap$Skill> skills;

  @override
  int get hashCode => version.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Roadmap && version == other.version;

  @override
  String toString() => 'Roadmap{version: $version}';
}

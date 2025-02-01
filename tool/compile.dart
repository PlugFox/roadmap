import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:shared/shared.dart';
import 'package:vector_math/vector_math.dart';
import 'package:yaml/yaml.dart' as y;

/// Compiles the roadmap from the YAML & Markdown files to the binary file with protobuf.
/// $ dart run tool/compile.dart
void main([List<String>? arguments]) => runZonedGuarded<void>(() async {
      final roadmap = _extractFromYamls();
      _checkRoadmap(roadmap);
      _compileRoadmap(roadmap);
    }, (error, stackTrace) {
      io.stderr
        ..writeln(error)
        ..writeln(stackTrace)
        ..flush();
      io.exit(1);
    });

/// Extracts a rectangle from the object.
Rect? _extractRect(Object? rect) => switch (rect) {
      null => null,
      Map<Object?, Object?> map when map.length == 4 => () {
          var left = (map['left'] ?? map['x']) as num?;
          var top = (map['top'] ?? map['y']) as num?;
          var right = (map['right'] ?? map['r']) as num?;
          var bottom = (map['bottom'] ?? map['b']) as num?;
          final width = (map['width'] ?? map['w']) as num?;
          final height = (map['height'] ?? map['h']) as num?;
          if (right == null && width != null && left != null) {
            right = left + width;
          } else if (left == null && width != null && right != null) {
            left = right - width;
          }
          if (bottom == null && height != null && top != null) {
            bottom = top + height;
          } else if (top == null && height != null && bottom != null) {
            top = bottom - height;
          }
          if (left == null || top == null || right == null || bottom == null) {
            throw ArgumentError.value(map, 'rect', 'Wrong rect format');
          }
          return Rect.fromLTRB(
            left.toDouble(),
            top.toDouble(),
            right.toDouble(),
            bottom.toDouble(),
          );
        }(),
      List<Object?> list when list.length == 4 => Rect.fromLTRB(
          (list[0]! as num).toDouble(),
          (list[1]! as num).toDouble(),
          (list[2]! as num).toDouble(),
          (list[3]! as num).toDouble(),
        ),
      String parts when parts.contains(',') => () {
          final l = parts.split(',').map((e) => e.trim()).map(double.parse).toList();
          if (l.length != 4) throw ArgumentError.value(parts, 'rect', 'Wrong rect format');
          final [left, top, right, bottom] = l;
          return Rect.fromLTRB(left, top, right, bottom);
        }(),
      _ => throw ArgumentError.value(
          rect,
          'rect',
          'Wrong rect format',
        ),
    };

Color? _extractColor(Object? color) => switch (color) {
      null => null,
      Map<Object?, Object?> map when map.length == 4 => Color.from(
          red: ((map['r'] ?? map['red'])! as num).toDouble(),
          green: ((map['g'] ?? map['green'])! as num).toDouble(),
          blue: ((map['b'] ?? map['blue'])! as num).toDouble(),
          alpha: ((map['a'] ?? map['alpha'])! as num).toDouble(),
        ),
      List<Object?> list when list.length == 4 => Color.from(
          red: (list[0]! as num).toDouble(),
          green: (list[1]! as num).toDouble(),
          blue: (list[2]! as num).toDouble(),
          alpha: (list[3]! as num).toDouble(),
        ),
      'r' || 'red' => Color.opaqueRed,
      'g' || 'greeen' => Color.opaqueGreen,
      'b' || 'blue' => Color.opaqueBlue,
      'a' || 'alpha' || 'transparent' => Color.transparent,
      'white' => Color.opaqueWhite,
      'black' => Color.opaqueBlack,
      int value => Color(value),
      String parts when parts.contains(',') => () {
          final l = parts.split(',').map((e) => e.trim()).map(double.parse).toList();
          if (l.length != 4) throw ArgumentError.value(parts, 'color', 'Wrong color format');
          final [r, g, b, a] = l;
          return Color.from(
            red: r,
            green: g,
            blue: b,
            alpha: a,
          );
        }(),
      String hex when hex.startsWith('#') => Color.fromHex(hex),
      _ => throw ArgumentError.value(
          color,
          'color',
          'Wrong color format',
        ),
    };

SkillSprite? _extractSprite(Object? sprite) => switch (sprite) {
      null => null,
      int index => SkillSprite(index),
      _ => throw ArgumentError.value(
          sprite,
          'sprite',
          'Wrong sprite format',
        ),
    };

Roadmap _extractFromYamls() {
  final roadmapYaml = y.loadYaml(io.File('roadmap/roadmap.yml').readAsStringSync()) as y.YamlMap;
  final skillsYaml = y.loadYaml(io.File('roadmap/skills.yml').readAsStringSync()) as y.YamlMap;
  final coordinatesYaml = y.loadYaml(io.File('roadmap/coordinates.yml').readAsStringSync()) as y.YamlMap;

  T handleErrors<T>(T Function() callback, [String? message]) {
    try {
      return callback();
    } on Object catch (error, stackTrace) {
      io.stderr
        ..writeln('! Error: ${message ?? '$error\n$stackTrace'}')
        ..flush();
      io.exit(1);
    }
  }

  // Coordinates
  final coordinatesIterable =
      (coordinatesYaml['coordinates'] as y.YamlList).cast<y.YamlMap>().map<MapEntry<int, Vector2>>(
            (e) => MapEntry(
              e['id'] as int,
              Vector2(
                (e['x']! as num).toDouble(),
                (e['y']! as num).toDouble(),
              ),
            ),
          );

  // Version
  final version = roadmapYaml['version']! as String;
  if (version.split('.').map(int.parse).length != 3)
    throw ArgumentError.value(
      version,
      'version',
      'Wrong version format',
    );

  /// Language
  final language = roadmapYaml['language']! as String;

  // Rectangle
  final rect = _extractRect(roadmapYaml['boundary'] ?? roadmapYaml['rect'])!;

  final center = rect.center;
  final coordinates = <int, Vector2>{
    for (final entry in coordinatesIterable) entry.key: entry.value,
  };
  var coordinatesFallback = Uint32List(0);

  // Get the position of the skill from the coordinates map or fallback to a calculated position
  // based on the level and the number of skills with the same level already positioned with fallback.
  Rect pos(int id, int level, double size) {
    final coordinate = coordinates[id];
    if (coordinate != null) {
      final half = size / 2;
      return Rect.fromLTRB(
        coordinate.x - half,
        coordinate.y - half,
        coordinate.x + half,
        coordinate.y + half,
      );
    }
    if (coordinatesFallback.length <= level)
      coordinatesFallback = Uint32List(level + 1 << 2)..setAll(0, coordinatesFallback);
    final offset = coordinatesFallback[level] += 1;
    final x = center.dx + offset * size * 1.5 - size * 4;
    final y = center.dy + level * size * 1.5 - size * 4;
    return Rect.fromLTRB(
      x,
      y,
      x + size,
      y + size,
    );
  }

  // Areas
  final areasList = (roadmapYaml['areas'] as y.YamlList)
      .cast<y.YamlMap>()
      .map<Roadmap$Area>(
        (e) => Roadmap$Area(
          id: e['id']! as int,
          name: e['name']! as String,
          description: (e['description'] ?? e['desc'])! as String,
          boundary: _extractRect((e['boundary'] ?? e['rect'])!)!,
          color: _extractColor(e['color']!)!,
        ),
      )
      .where((t) => t.id >= 0)
      .toList(growable: false)
    ..sort();
  final areasIds = {for (final area in areasList) area.id};
  if (areasIds.length != areasList.length)
    throw ArgumentError.value(
      areasList,
      'areas',
      'Duplicate area id',
    );
  if (areasList.last.id != areasList.last.id)
    throw ArgumentError.value(
      areasList,
      'areas',
      'Areas are not contiguous array',
    );

  // Ranks
  final ranksList = (roadmapYaml['ranks'] as y.YamlList)
      .cast<y.YamlMap>()
      .map<Roadmap$Rank>(
        (e) => Roadmap$Rank(
          id: e['id']! as int,
          description: (e['description'] ?? e['desc'])! as String,
          name: e['name']! as String,
          color: _extractColor(e['color']!)!,
        ),
      )
      .where((t) => t.id >= 0)
      .toList(growable: false)
    ..sort();
  final ranksIds = {for (final rank in ranksList) rank.id};
  if (ranksIds.length != ranksList.length)
    throw ArgumentError.value(
      ranksList,
      'ranks',
      'Duplicate rank id',
    );
  if (ranksList.last.id != ranksList.last.id)
    throw ArgumentError.value(
      ranksList,
      'ranks',
      'Ranks are not contiguous array',
    );

  // Levels
  final levelsList = (roadmapYaml['levels'] as y.YamlList)
      .cast<y.YamlMap>()
      .map<Roadmap$Level>(
        (e) => Roadmap$Level(
          id: e['id']! as int,
          name: e['name']! as String,
          description: (e['description'] ?? e['desc'])! as String,
          radius: (e['radius']! as num).toDouble(),
          color: _extractColor(e['color']!)!,
        ),
      )
      .where((t) => t.id >= 0)
      .toList(growable: false)
    ..sort();
  final levelsIds = {for (final level in levelsList) level.id};
  if (levelsIds.length != levelsList.length)
    throw ArgumentError.value(
      levelsList,
      'levels',
      'Duplicate level id',
    );
  if (levelsList.last.id != levelsList.last.id)
    throw ArgumentError.value(
      levelsList,
      'levels',
      'Levels are not contiguous array',
    );

  // Tags
  final tagsList = (roadmapYaml['tags'] as y.YamlList)
      .cast<y.YamlMap>()
      .map<Roadmap$Tag>(
        (e) => handleErrors(
          () => Roadmap$Tag(
            id: e['id']! as int,
            name: e['name']! as String,
            description: (e['description'] ?? e['desc'])! as String,
            sprite: _extractSprite(e['sprite'] ?? e['id']!)!,
          ),
          '! Error: tag #${e['id']} extraction failed',
        ),
      )
      .where((t) => t.id >= 0)
      .toList(growable: false)
    ..sort();
  final tagsIds = {for (final tag in tagsList) tag.id};
  if (tagsIds.length != tagsList.length)
    throw ArgumentError.value(
      tagsList,
      'tags',
      'Duplicate tag id',
    );
  if (tagsList.last.id != tagsList.last.id)
    throw ArgumentError.value(
      tagsList,
      'tags',
      'Tags are not contiguous array',
    );

  // Skills
  final skillsList = (skillsYaml['skills'] as y.YamlList)
      .cast<y.YamlMap>()
      .map<Roadmap$Skill>(
        (e) {
          final id = e['id']! as int;
          final levelId = e['level']! as int;
          final tags = (e['tags'] as y.YamlList).cast<int>().map((e) => tagsList[e]).toList(growable: false)
            ..sort((a, b) => a.id.compareTo(b.id));
          if (tags.isEmpty) throw ArgumentError.value(e, 'tags', 'Empty tags');
          final primaryTag = tags.first;
          final notable = e['notable'] == true;
          final level = levelsList[levelId];
          return Roadmap$Skill(
            id: id,
            name: e['name']! as String,
            level: level,
            sprite: _extractSprite(e['sprite']) ?? primaryTag.sprite,
            experience: switch (e['experience']) {
              int value when value > 0 => value,
              double value when value > 0 => value.toInt(),
              String value => int.parse(value),
              null => (levelId + 1) * 10 * (notable ? 3 : 1),
              _ => throw ArgumentError.value(
                  e['experience'],
                  'experience',
                  'Wrong experience format',
                ),
            },
            notable: e['notable'] == true,
            color: _extractColor(e['color']) ?? level.color,
            boundary: _extractRect(e['boundary'] ?? e['rect']) ??
                pos(
                  id,
                  levelId,
                  switch (e['size']) {
                    null || 0 => notable ? 64.0 : 48.0,
                    num value when value > 24 => value.toDouble(),
                    num value when value > 0 => (notable ? 64.0 : 48.0) * value,
                    _ => throw ArgumentError.value(
                        e['size'],
                        'size',
                        'Wrong size format',
                      ),
                  },
                ),
            tags: tags,
            parent: switch (e['parent']) {
              null => null,
              int value => value,
              _ => throw ArgumentError.value(
                  e['parent'],
                  'parent',
                  'Wrong parent format ${e['parent']}',
                ),
            },
            meta: switch (e['meta']) {
              null => const {},
              y.YamlMap map => <String, String>{
                  for (final MapEntry(:key, :value) in map.entries) key.toString(): value.toString(),
                },
              y.YamlList list => <String, String>{
                  for (final node in list)
                    if (node is y.YamlMap)
                      (node['key'] ?? node['k']).toString(): (node['value'] ?? node['v']).toString()
                    else if (node is String)
                      node: ''
                    else if (node is num)
                      node.toString(): ''
                    else if (node is bool)
                      node ? 'y' : 'n': ''
                },
              _ => const {},
            },
          );
        },
      )
      .where((s) => s.isValid)
      .toList(growable: false)
    ..sort();
  final skillIds = skillsList.map((e) => e.id).toSet();
  if (skillIds.length != skillsList.length)
    throw ArgumentError.value(
      skillsList,
      'skills',
      'Duplicate skill id',
    );

  final unpositionedSkills = coordinatesFallback.fold<int>(0, (total, e) => total + e);
  if (unpositionedSkills > 0)
    io.stderr
        .writeln('! Warning: $unpositionedSkills skills were not positioned and were placed in a fallback position.');

  return Roadmap(
    version: version,
    language: language,
    boundary: rect,
    areas: areasList,
    ranks: ranksList,
    levels: levelsList,
    tags: tagsList,
    skills: skillsList,
  );
}

void _checkRoadmap(Roadmap roadmap) {
  /* final skillsWithNoDescription = <int>{};
  for (final skill in roadmap.skills.values) {
    if (skill.description.isEmpty) skillsWithNoDescription.add(skill.id);
  }
  if (skillsWithNoDescription.length > 20)
    io.stderr.writeln('! Warning: ${skillsWithNoDescription.length} skills have no description');
  else if (skillsWithNoDescription.isNotEmpty)
    io.stderr.writeln('! Warning: Skills have no description: ${skillsWithNoDescription.join(', ')}'); */
}

void _compileRoadmap(Roadmap roadmap) =>
    io.File('web/assets/roadmap.bin').writeAsBytesSync(roadmapCodec.encode(roadmap), flush: true);

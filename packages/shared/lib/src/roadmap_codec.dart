import 'dart:collection';
import 'dart:convert';

import 'package:protobuf/protobuf.dart' as pb;
import 'package:shared/src/atlas.dart';
import 'package:shared/src/color.dart';
import 'package:shared/src/geometry.dart';
import 'package:shared/src/protobuf/roadmap.pb.dart' as pb;
import 'package:shared/src/roadmap.dart';

const Codec<Roadmap, List<int>> roadmapCodec = RoadmapCodec();

class RoadmapCodec extends Codec<Roadmap, List<int>> {
  const RoadmapCodec();

  @override
  Converter<List<int>, Roadmap> get decoder => const RoadmapDecoder();

  @override
  Converter<Roadmap, List<int>> get encoder => const RoadmapEncoder();
}

class RoadmapDecoder extends Converter<List<int>, Roadmap> {
  const RoadmapDecoder();

  @override
  Roadmap convert(List<int> input) {
    final reader = pb.CodedBufferReader(input);
    // reader.isAtEnd()
    final msg = pb.Roadmap();
    reader.readMessage(msg, pb.ExtensionRegistry.EMPTY);
    final areas = msg.areas
        .map<Roadmap$Area>(
          (e) => Roadmap$Area(
            id: e.id,
            name: e.name,
            description: e.description,
            boundary: Rect.fromLTRB(
              e.boundary.left,
              e.boundary.top,
              e.boundary.right,
              e.boundary.bottom,
            ),
            color: Color.from(
              alpha: e.color.a,
              red: e.color.r,
              green: e.color.g,
              blue: e.color.b,
            ),
          ),
        )
        .toList(growable: false)
      ..sort();
    final ranks = msg.ranks
        .map<Roadmap$Rank>(
          (e) => Roadmap$Rank(
            id: e.id,
            name: e.name,
            description: e.description,
            color: Color.from(
              alpha: e.color.a,
              red: e.color.r,
              green: e.color.g,
              blue: e.color.b,
            ),
          ),
        )
        .toList(growable: false)
      ..sort();
    final levels = msg.levels
        .map<Roadmap$Level>(
          (e) => Roadmap$Level(
            id: e.id,
            name: e.name,
            description: e.description,
            radius: e.radius,
            color: Color.from(
              alpha: e.color.a,
              red: e.color.r,
              green: e.color.g,
              blue: e.color.b,
            ),
          ),
        )
        .toList(growable: false)
      ..sort();
    final tags = msg.tags
        .map<Roadmap$Tag>(
          (e) => Roadmap$Tag(
            id: e.id,
            name: e.name,
            description: e.description,
            sprite: SkillSprite(e.sprite),
          ),
        )
        .toList(growable: false)
      ..sort();
    final skills = msg.skills
        .map<Roadmap$Skill>(
          (e) => Roadmap$Skill(
            id: e.id,
            name: e.name,
            level: levels[e.level],
            sprite: e.hasSprite() ? SkillSprite(e.sprite) : tags.first.sprite,
            experience: switch (e.experience) {
              > 0 => e.experience,
              _ => (e.level + 1) * 10 * (e.notable ? 3 : 1),
            },
            notable: e.notable,
            color: e.hasColor()
                ? Color.from(
                    alpha: e.color.a,
                    red: e.color.r,
                    green: e.color.g,
                    blue: e.color.b,
                  )
                : ranks.first.color,
            boundary: Rect.fromLTRB(
              e.boundary.left,
              e.boundary.top,
              e.boundary.right,
              e.boundary.bottom,
            ),
            parent: e.hasParent() ? e.parent : -1,
            tags: e.tags.map<Roadmap$Tag>((e) => tags[e]).toSet(),
            meta: HashMap<String, String>.of(e.meta),
          ),
        )
        .toList(growable: false);
    final skillsMap = <int, Roadmap$Skill>{
      for (final skill in skills) skill.id: skill,
    };
    return Roadmap(
      version: msg.version,
      language: msg.hasLanguage() ? msg.language : 'en',
      boundary: Rect.fromLTRB(
        msg.boundary.left,
        msg.boundary.top,
        msg.boundary.right,
        msg.boundary.bottom,
      ),
      areas: areas,
      ranks: ranks,
      levels: levels,
      tags: tags,
      skills: skillsMap,
    );
  }
}

class RoadmapEncoder extends Converter<Roadmap, List<int>> {
  const RoadmapEncoder();

  @override
  List<int> convert(Roadmap input) {
    final msg = pb.Roadmap(
      version: input.version,
      language: input.language,
      boundary: pb.Rect(
        left: input.boundary.left,
        top: input.boundary.top,
        right: input.boundary.right,
        bottom: input.boundary.bottom,
      ),
      areas: input.areas
          .map<pb.Area>(
            (e) => pb.Area(
              id: e.id,
              name: e.name,
              description: e.description,
              boundary: pb.Rect(
                left: e.boundary.left,
                top: e.boundary.top,
                right: e.boundary.right,
                bottom: e.boundary.bottom,
              ),
              color: pb.Color(
                a: e.color.a,
                r: e.color.r,
                g: e.color.g,
                b: e.color.b,
              ),
            ),
          )
          .toList(growable: false),
      ranks: input.ranks
          .map<pb.Rank>(
            (e) => pb.Rank(
              id: e.id,
              name: e.name,
              description: e.description,
              color: pb.Color(
                a: e.color.a,
                r: e.color.r,
                g: e.color.g,
                b: e.color.b,
              ),
            ),
          )
          .toList(growable: false),
      levels: input.levels
          .map<pb.Level>(
            (e) => pb.Level(
              id: e.id,
              name: e.name,
              description: e.description,
              radius: e.radius,
              color: pb.Color(
                a: e.color.a,
                r: e.color.r,
                g: e.color.g,
                b: e.color.b,
              ),
            ),
          )
          .toList(growable: false),
      tags: input.tags
          .map<pb.Tag>(
            (e) => pb.Tag(
              id: e.id,
              name: e.name,
              description: e.description,
              sprite: e.sprite.id,
            ),
          )
          .toList(growable: false),
      skills: input.skills.values
          .map<pb.Skill>(
            (e) => pb.Skill(
              id: e.id,
              name: e.name,
              level: e.level.id,
              sprite: e.sprite.id,
              experience: e.experience,
              notable: e.notable,
              color: pb.Color(
                a: e.color.a,
                r: e.color.r,
                g: e.color.g,
                b: e.color.b,
              ),
              boundary: pb.Rect(
                left: e.boundary.left,
                top: e.boundary.top,
                right: e.boundary.right,
                bottom: e.boundary.bottom,
              ),
              parent: e.parent == -1 ? null : e.parent,
              tags: e.tags.map<int>((e) => e.id).toList(growable: false),
              meta: Map<String, String>.of(e.meta),
            ),
          )
          .toList(growable: false),
    );
    final msgBuffer = msg.writeToBuffer();
    return (pb.CodedBufferWriter()
          ..writeInt32NoTag(msgBuffer.lengthInBytes)
          ..writeRawBytes(msgBuffer))
        .toBuffer();
  }
}

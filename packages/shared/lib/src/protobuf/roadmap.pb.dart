//
//  Generated code. Do not modify.
//  source: roadmap.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Vector2D
class Vector extends $pb.GeneratedMessage {
  factory Vector({
    $core.double? x,
    $core.double? y,
  }) {
    final $result = create();
    if (x != null) {
      $result.x = x;
    }
    if (y != null) {
      $result.y = y;
    }
    return $result;
  }
  Vector._() : super();
  factory Vector.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Vector.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Vector', package: const $pb.PackageName(_omitMessageNames ? '' : 'roadmap'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'x', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'y', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Vector clone() => Vector()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Vector copyWith(void Function(Vector) updates) => super.copyWith((message) => updates(message as Vector)) as Vector;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Vector create() => Vector._();
  Vector createEmptyInstance() => create();
  static $pb.PbList<Vector> createRepeated() => $pb.PbList<Vector>();
  @$core.pragma('dart2js:noInline')
  static Vector getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Vector>(create);
  static Vector? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get x => $_getN(0);
  @$pb.TagNumber(1)
  set x($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get y => $_getN(1);
  @$pb.TagNumber(2)
  set y($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => clearField(2);
}

/// Rectangle (Vector4)
class Rect extends $pb.GeneratedMessage {
  factory Rect({
    $core.double? left,
    $core.double? top,
    $core.double? right,
    $core.double? bottom,
  }) {
    final $result = create();
    if (left != null) {
      $result.left = left;
    }
    if (top != null) {
      $result.top = top;
    }
    if (right != null) {
      $result.right = right;
    }
    if (bottom != null) {
      $result.bottom = bottom;
    }
    return $result;
  }
  Rect._() : super();
  factory Rect.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Rect.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Rect', package: const $pb.PackageName(_omitMessageNames ? '' : 'roadmap'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'left', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'top', $pb.PbFieldType.OF)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'right', $pb.PbFieldType.OF)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'bottom', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Rect clone() => Rect()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Rect copyWith(void Function(Rect) updates) => super.copyWith((message) => updates(message as Rect)) as Rect;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Rect create() => Rect._();
  Rect createEmptyInstance() => create();
  static $pb.PbList<Rect> createRepeated() => $pb.PbList<Rect>();
  @$core.pragma('dart2js:noInline')
  static Rect getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Rect>(create);
  static Rect? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get left => $_getN(0);
  @$pb.TagNumber(1)
  set left($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLeft() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeft() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get top => $_getN(1);
  @$pb.TagNumber(2)
  set top($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTop() => $_has(1);
  @$pb.TagNumber(2)
  void clearTop() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get right => $_getN(2);
  @$pb.TagNumber(3)
  set right($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRight() => $_has(2);
  @$pb.TagNumber(3)
  void clearRight() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get bottom => $_getN(3);
  @$pb.TagNumber(4)
  set bottom($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBottom() => $_has(3);
  @$pb.TagNumber(4)
  void clearBottom() => clearField(4);
}

/// Area
class Area extends $pb.GeneratedMessage {
  factory Area({
    $core.int? id,
    $core.String? name,
    $core.String? description,
    Rect? boundary,
    $core.int? color,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (boundary != null) {
      $result.boundary = boundary;
    }
    if (color != null) {
      $result.color = color;
    }
    return $result;
  }
  Area._() : super();
  factory Area.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Area.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Area', package: const $pb.PackageName(_omitMessageNames ? '' : 'roadmap'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOM<Rect>(10, _omitFieldNames ? '' : 'boundary', subBuilder: Rect.create)
    ..a<$core.int>(50, _omitFieldNames ? '' : 'color', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Area clone() => Area()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Area copyWith(void Function(Area) updates) => super.copyWith((message) => updates(message as Area)) as Area;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Area create() => Area._();
  Area createEmptyInstance() => create();
  static $pb.PbList<Area> createRepeated() => $pb.PbList<Area>();
  @$core.pragma('dart2js:noInline')
  static Area getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Area>(create);
  static Area? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(10)
  Rect get boundary => $_getN(3);
  @$pb.TagNumber(10)
  set boundary(Rect v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasBoundary() => $_has(3);
  @$pb.TagNumber(10)
  void clearBoundary() => clearField(10);
  @$pb.TagNumber(10)
  Rect ensureBoundary() => $_ensure(3);

  @$pb.TagNumber(50)
  $core.int get color => $_getIZ(4);
  @$pb.TagNumber(50)
  set color($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(50)
  $core.bool hasColor() => $_has(4);
  @$pb.TagNumber(50)
  void clearColor() => clearField(50);
}

/// Rank
class Rank extends $pb.GeneratedMessage {
  factory Rank({
    $core.int? id,
    $core.String? name,
    $core.String? description,
    $core.int? color,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (color != null) {
      $result.color = color;
    }
    return $result;
  }
  Rank._() : super();
  factory Rank.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Rank.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Rank', package: const $pb.PackageName(_omitMessageNames ? '' : 'roadmap'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(50, _omitFieldNames ? '' : 'color', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Rank clone() => Rank()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Rank copyWith(void Function(Rank) updates) => super.copyWith((message) => updates(message as Rank)) as Rank;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Rank create() => Rank._();
  Rank createEmptyInstance() => create();
  static $pb.PbList<Rank> createRepeated() => $pb.PbList<Rank>();
  @$core.pragma('dart2js:noInline')
  static Rank getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Rank>(create);
  static Rank? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(50)
  $core.int get color => $_getIZ(3);
  @$pb.TagNumber(50)
  set color($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(50)
  $core.bool hasColor() => $_has(3);
  @$pb.TagNumber(50)
  void clearColor() => clearField(50);
}

/// Level
class Level extends $pb.GeneratedMessage {
  factory Level({
    $core.int? id,
    $core.String? name,
    $core.String? description,
    $core.double? radius,
    $core.int? color,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (radius != null) {
      $result.radius = radius;
    }
    if (color != null) {
      $result.color = color;
    }
    return $result;
  }
  Level._() : super();
  factory Level.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Level.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Level', package: const $pb.PackageName(_omitMessageNames ? '' : 'roadmap'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..a<$core.double>(10, _omitFieldNames ? '' : 'radius', $pb.PbFieldType.OF)
    ..a<$core.int>(50, _omitFieldNames ? '' : 'color', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Level clone() => Level()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Level copyWith(void Function(Level) updates) => super.copyWith((message) => updates(message as Level)) as Level;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Level create() => Level._();
  Level createEmptyInstance() => create();
  static $pb.PbList<Level> createRepeated() => $pb.PbList<Level>();
  @$core.pragma('dart2js:noInline')
  static Level getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Level>(create);
  static Level? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(10)
  $core.double get radius => $_getN(3);
  @$pb.TagNumber(10)
  set radius($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(10)
  $core.bool hasRadius() => $_has(3);
  @$pb.TagNumber(10)
  void clearRadius() => clearField(10);

  @$pb.TagNumber(50)
  $core.int get color => $_getIZ(4);
  @$pb.TagNumber(50)
  set color($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(50)
  $core.bool hasColor() => $_has(4);
  @$pb.TagNumber(50)
  void clearColor() => clearField(50);
}

/// Tag
class Tag extends $pb.GeneratedMessage {
  factory Tag({
    $core.int? id,
    $core.String? name,
    $core.String? description,
    $core.int? sprite,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (sprite != null) {
      $result.sprite = sprite;
    }
    return $result;
  }
  Tag._() : super();
  factory Tag.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Tag.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Tag', package: const $pb.PackageName(_omitMessageNames ? '' : 'roadmap'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'sprite', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Tag clone() => Tag()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Tag copyWith(void Function(Tag) updates) => super.copyWith((message) => updates(message as Tag)) as Tag;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tag create() => Tag._();
  Tag createEmptyInstance() => create();
  static $pb.PbList<Tag> createRepeated() => $pb.PbList<Tag>();
  @$core.pragma('dart2js:noInline')
  static Tag getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tag>(create);
  static Tag? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(10)
  $core.int get sprite => $_getIZ(3);
  @$pb.TagNumber(10)
  set sprite($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(10)
  $core.bool hasSprite() => $_has(3);
  @$pb.TagNumber(10)
  void clearSprite() => clearField(10);
}

/// Skill
class Skill extends $pb.GeneratedMessage {
  factory Skill({
    $core.int? id,
    $core.String? name,
    $core.int? level,
    $core.int? sprite,
    $core.int? experience,
    $core.bool? notable,
    $core.int? color,
    Rect? boundary,
    $core.int? parent,
    $core.Iterable<$core.int>? tags,
    $core.Map<$core.String, $core.String>? meta,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (level != null) {
      $result.level = level;
    }
    if (sprite != null) {
      $result.sprite = sprite;
    }
    if (experience != null) {
      $result.experience = experience;
    }
    if (notable != null) {
      $result.notable = notable;
    }
    if (color != null) {
      $result.color = color;
    }
    if (boundary != null) {
      $result.boundary = boundary;
    }
    if (parent != null) {
      $result.parent = parent;
    }
    if (tags != null) {
      $result.tags.addAll(tags);
    }
    if (meta != null) {
      $result.meta.addAll(meta);
    }
    return $result;
  }
  Skill._() : super();
  factory Skill.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Skill.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Skill', package: const $pb.PackageName(_omitMessageNames ? '' : 'roadmap'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'level', $pb.PbFieldType.OU3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'sprite', $pb.PbFieldType.OU3)
    ..a<$core.int>(20, _omitFieldNames ? '' : 'experience', $pb.PbFieldType.OU3)
    ..aOB(30, _omitFieldNames ? '' : 'notable')
    ..a<$core.int>(50, _omitFieldNames ? '' : 'color', $pb.PbFieldType.OU3)
    ..aOM<Rect>(60, _omitFieldNames ? '' : 'boundary', subBuilder: Rect.create)
    ..a<$core.int>(100, _omitFieldNames ? '' : 'parent', $pb.PbFieldType.OU3)
    ..p<$core.int>(200, _omitFieldNames ? '' : 'tags', $pb.PbFieldType.KU3)
    ..m<$core.String, $core.String>(500, _omitFieldNames ? '' : 'meta', entryClassName: 'Skill.MetaEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('roadmap'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Skill clone() => Skill()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Skill copyWith(void Function(Skill) updates) => super.copyWith((message) => updates(message as Skill)) as Skill;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Skill create() => Skill._();
  Skill createEmptyInstance() => create();
  static $pb.PbList<Skill> createRepeated() => $pb.PbList<Skill>();
  @$core.pragma('dart2js:noInline')
  static Skill getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Skill>(create);
  static Skill? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(5)
  $core.int get level => $_getIZ(2);
  @$pb.TagNumber(5)
  set level($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(5)
  $core.bool hasLevel() => $_has(2);
  @$pb.TagNumber(5)
  void clearLevel() => clearField(5);

  @$pb.TagNumber(10)
  $core.int get sprite => $_getIZ(3);
  @$pb.TagNumber(10)
  set sprite($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(10)
  $core.bool hasSprite() => $_has(3);
  @$pb.TagNumber(10)
  void clearSprite() => clearField(10);

  @$pb.TagNumber(20)
  $core.int get experience => $_getIZ(4);
  @$pb.TagNumber(20)
  set experience($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(20)
  $core.bool hasExperience() => $_has(4);
  @$pb.TagNumber(20)
  void clearExperience() => clearField(20);

  @$pb.TagNumber(30)
  $core.bool get notable => $_getBF(5);
  @$pb.TagNumber(30)
  set notable($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(30)
  $core.bool hasNotable() => $_has(5);
  @$pb.TagNumber(30)
  void clearNotable() => clearField(30);

  @$pb.TagNumber(50)
  $core.int get color => $_getIZ(6);
  @$pb.TagNumber(50)
  set color($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(50)
  $core.bool hasColor() => $_has(6);
  @$pb.TagNumber(50)
  void clearColor() => clearField(50);

  @$pb.TagNumber(60)
  Rect get boundary => $_getN(7);
  @$pb.TagNumber(60)
  set boundary(Rect v) { setField(60, v); }
  @$pb.TagNumber(60)
  $core.bool hasBoundary() => $_has(7);
  @$pb.TagNumber(60)
  void clearBoundary() => clearField(60);
  @$pb.TagNumber(60)
  Rect ensureBoundary() => $_ensure(7);

  @$pb.TagNumber(100)
  $core.int get parent => $_getIZ(8);
  @$pb.TagNumber(100)
  set parent($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(100)
  $core.bool hasParent() => $_has(8);
  @$pb.TagNumber(100)
  void clearParent() => clearField(100);

  @$pb.TagNumber(200)
  $core.List<$core.int> get tags => $_getList(9);

  @$pb.TagNumber(500)
  $core.Map<$core.String, $core.String> get meta => $_getMap(10);
}

/// Root structure
class Roadmap extends $pb.GeneratedMessage {
  factory Roadmap({
    $core.String? version,
    $core.String? language,
    Rect? boundary,
    $core.Iterable<Area>? areas,
    $core.Iterable<Rank>? ranks,
    $core.Iterable<Level>? levels,
    $core.Iterable<Tag>? tags,
    $core.Iterable<Skill>? skills,
  }) {
    final $result = create();
    if (version != null) {
      $result.version = version;
    }
    if (language != null) {
      $result.language = language;
    }
    if (boundary != null) {
      $result.boundary = boundary;
    }
    if (areas != null) {
      $result.areas.addAll(areas);
    }
    if (ranks != null) {
      $result.ranks.addAll(ranks);
    }
    if (levels != null) {
      $result.levels.addAll(levels);
    }
    if (tags != null) {
      $result.tags.addAll(tags);
    }
    if (skills != null) {
      $result.skills.addAll(skills);
    }
    return $result;
  }
  Roadmap._() : super();
  factory Roadmap.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Roadmap.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Roadmap', package: const $pb.PackageName(_omitMessageNames ? '' : 'roadmap'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'version')
    ..aOS(3, _omitFieldNames ? '' : 'language')
    ..aOM<Rect>(10, _omitFieldNames ? '' : 'boundary', subBuilder: Rect.create)
    ..pc<Area>(20, _omitFieldNames ? '' : 'areas', $pb.PbFieldType.PM, subBuilder: Area.create)
    ..pc<Rank>(30, _omitFieldNames ? '' : 'ranks', $pb.PbFieldType.PM, subBuilder: Rank.create)
    ..pc<Level>(40, _omitFieldNames ? '' : 'levels', $pb.PbFieldType.PM, subBuilder: Level.create)
    ..pc<Tag>(50, _omitFieldNames ? '' : 'tags', $pb.PbFieldType.PM, subBuilder: Tag.create)
    ..pc<Skill>(100, _omitFieldNames ? '' : 'skills', $pb.PbFieldType.PM, subBuilder: Skill.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Roadmap clone() => Roadmap()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Roadmap copyWith(void Function(Roadmap) updates) => super.copyWith((message) => updates(message as Roadmap)) as Roadmap;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Roadmap create() => Roadmap._();
  Roadmap createEmptyInstance() => create();
  static $pb.PbList<Roadmap> createRepeated() => $pb.PbList<Roadmap>();
  @$core.pragma('dart2js:noInline')
  static Roadmap getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Roadmap>(create);
  static Roadmap? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => clearField(1);

  @$pb.TagNumber(3)
  $core.String get language => $_getSZ(1);
  @$pb.TagNumber(3)
  set language($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasLanguage() => $_has(1);
  @$pb.TagNumber(3)
  void clearLanguage() => clearField(3);

  @$pb.TagNumber(10)
  Rect get boundary => $_getN(2);
  @$pb.TagNumber(10)
  set boundary(Rect v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasBoundary() => $_has(2);
  @$pb.TagNumber(10)
  void clearBoundary() => clearField(10);
  @$pb.TagNumber(10)
  Rect ensureBoundary() => $_ensure(2);

  @$pb.TagNumber(20)
  $core.List<Area> get areas => $_getList(3);

  @$pb.TagNumber(30)
  $core.List<Rank> get ranks => $_getList(4);

  @$pb.TagNumber(40)
  $core.List<Level> get levels => $_getList(5);

  @$pb.TagNumber(50)
  $core.List<Tag> get tags => $_getList(6);

  @$pb.TagNumber(100)
  $core.List<Skill> get skills => $_getList(7);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');

//
//  Generated code. Do not modify.
//  source: roadmap.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use vectorDescriptor instead')
const Vector$json = {
  '1': 'Vector',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 2, '10': 'x'},
    {'1': 'y', '3': 2, '4': 1, '5': 2, '10': 'y'},
  ],
};

/// Descriptor for `Vector`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vectorDescriptor = $convert.base64Decode(
    'CgZWZWN0b3ISDAoBeBgBIAEoAlIBeBIMCgF5GAIgASgCUgF5');

@$core.Deprecated('Use rectDescriptor instead')
const Rect$json = {
  '1': 'Rect',
  '2': [
    {'1': 'left', '3': 1, '4': 1, '5': 2, '10': 'left'},
    {'1': 'top', '3': 2, '4': 1, '5': 2, '10': 'top'},
    {'1': 'right', '3': 3, '4': 1, '5': 2, '10': 'right'},
    {'1': 'bottom', '3': 4, '4': 1, '5': 2, '10': 'bottom'},
  ],
};

/// Descriptor for `Rect`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rectDescriptor = $convert.base64Decode(
    'CgRSZWN0EhIKBGxlZnQYASABKAJSBGxlZnQSEAoDdG9wGAIgASgCUgN0b3ASFAoFcmlnaHQYAy'
    'ABKAJSBXJpZ2h0EhYKBmJvdHRvbRgEIAEoAlIGYm90dG9t');

@$core.Deprecated('Use areaDescriptor instead')
const Area$json = {
  '1': 'Area',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'boundary', '3': 10, '4': 1, '5': 11, '6': '.roadmap.Rect', '10': 'boundary'},
    {'1': 'color', '3': 50, '4': 1, '5': 13, '10': 'color'},
  ],
};

/// Descriptor for `Area`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List areaDescriptor = $convert.base64Decode(
    'CgRBcmVhEg4KAmlkGAEgASgNUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW'
    '9uGAMgASgJUgtkZXNjcmlwdGlvbhIpCghib3VuZGFyeRgKIAEoCzINLnJvYWRtYXAuUmVjdFII'
    'Ym91bmRhcnkSFAoFY29sb3IYMiABKA1SBWNvbG9y');

@$core.Deprecated('Use rankDescriptor instead')
const Rank$json = {
  '1': 'Rank',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'color', '3': 50, '4': 1, '5': 13, '10': 'color'},
  ],
};

/// Descriptor for `Rank`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rankDescriptor = $convert.base64Decode(
    'CgRSYW5rEg4KAmlkGAEgASgNUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW'
    '9uGAMgASgJUgtkZXNjcmlwdGlvbhIUCgVjb2xvchgyIAEoDVIFY29sb3I=');

@$core.Deprecated('Use levelDescriptor instead')
const Level$json = {
  '1': 'Level',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'radius', '3': 10, '4': 1, '5': 2, '10': 'radius'},
    {'1': 'color', '3': 50, '4': 1, '5': 13, '10': 'color'},
  ],
};

/// Descriptor for `Level`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List levelDescriptor = $convert.base64Decode(
    'CgVMZXZlbBIOCgJpZBgBIAEoDVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIgCgtkZXNjcmlwdG'
    'lvbhgDIAEoCVILZGVzY3JpcHRpb24SFgoGcmFkaXVzGAogASgCUgZyYWRpdXMSFAoFY29sb3IY'
    'MiABKA1SBWNvbG9y');

@$core.Deprecated('Use tagDescriptor instead')
const Tag$json = {
  '1': 'Tag',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'sprite', '3': 10, '4': 1, '5': 13, '10': 'sprite'},
  ],
};

/// Descriptor for `Tag`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tagDescriptor = $convert.base64Decode(
    'CgNUYWcSDgoCaWQYASABKA1SAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb2'
    '4YAyABKAlSC2Rlc2NyaXB0aW9uEhYKBnNwcml0ZRgKIAEoDVIGc3ByaXRl');

@$core.Deprecated('Use skillDescriptor instead')
const Skill$json = {
  '1': 'Skill',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'level', '3': 5, '4': 1, '5': 13, '10': 'level'},
    {'1': 'sprite', '3': 10, '4': 1, '5': 13, '10': 'sprite'},
    {'1': 'experience', '3': 20, '4': 1, '5': 13, '10': 'experience'},
    {'1': 'notable', '3': 30, '4': 1, '5': 8, '10': 'notable'},
    {'1': 'color', '3': 50, '4': 1, '5': 13, '10': 'color'},
    {'1': 'boundary', '3': 60, '4': 1, '5': 11, '6': '.roadmap.Rect', '10': 'boundary'},
    {'1': 'parent', '3': 100, '4': 1, '5': 13, '10': 'parent'},
    {'1': 'tags', '3': 200, '4': 3, '5': 13, '10': 'tags'},
    {'1': 'meta', '3': 500, '4': 3, '5': 11, '6': '.roadmap.Skill.MetaEntry', '10': 'meta'},
  ],
  '3': [Skill_MetaEntry$json],
};

@$core.Deprecated('Use skillDescriptor instead')
const Skill_MetaEntry$json = {
  '1': 'MetaEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Skill`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List skillDescriptor = $convert.base64Decode(
    'CgVTa2lsbBIOCgJpZBgBIAEoDVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIUCgVsZXZlbBgFIA'
    'EoDVIFbGV2ZWwSFgoGc3ByaXRlGAogASgNUgZzcHJpdGUSHgoKZXhwZXJpZW5jZRgUIAEoDVIK'
    'ZXhwZXJpZW5jZRIYCgdub3RhYmxlGB4gASgIUgdub3RhYmxlEhQKBWNvbG9yGDIgASgNUgVjb2'
    'xvchIpCghib3VuZGFyeRg8IAEoCzINLnJvYWRtYXAuUmVjdFIIYm91bmRhcnkSFgoGcGFyZW50'
    'GGQgASgNUgZwYXJlbnQSEwoEdGFncxjIASADKA1SBHRhZ3MSLQoEbWV0YRj0AyADKAsyGC5yb2'
    'FkbWFwLlNraWxsLk1ldGFFbnRyeVIEbWV0YRo3CglNZXRhRW50cnkSEAoDa2V5GAEgASgJUgNr'
    'ZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use roadmapDescriptor instead')
const Roadmap$json = {
  '1': 'Roadmap',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    {'1': 'language', '3': 3, '4': 1, '5': 9, '10': 'language'},
    {'1': 'boundary', '3': 10, '4': 1, '5': 11, '6': '.roadmap.Rect', '10': 'boundary'},
    {'1': 'areas', '3': 20, '4': 3, '5': 11, '6': '.roadmap.Area', '10': 'areas'},
    {'1': 'ranks', '3': 30, '4': 3, '5': 11, '6': '.roadmap.Rank', '10': 'ranks'},
    {'1': 'levels', '3': 40, '4': 3, '5': 11, '6': '.roadmap.Level', '10': 'levels'},
    {'1': 'tags', '3': 50, '4': 3, '5': 11, '6': '.roadmap.Tag', '10': 'tags'},
    {'1': 'skills', '3': 100, '4': 3, '5': 11, '6': '.roadmap.Skill', '10': 'skills'},
  ],
};

/// Descriptor for `Roadmap`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roadmapDescriptor = $convert.base64Decode(
    'CgdSb2FkbWFwEhgKB3ZlcnNpb24YASABKAlSB3ZlcnNpb24SGgoIbGFuZ3VhZ2UYAyABKAlSCG'
    'xhbmd1YWdlEikKCGJvdW5kYXJ5GAogASgLMg0ucm9hZG1hcC5SZWN0Ughib3VuZGFyeRIjCgVh'
    'cmVhcxgUIAMoCzINLnJvYWRtYXAuQXJlYVIFYXJlYXMSIwoFcmFua3MYHiADKAsyDS5yb2FkbW'
    'FwLlJhbmtSBXJhbmtzEiYKBmxldmVscxgoIAMoCzIOLnJvYWRtYXAuTGV2ZWxSBmxldmVscxIg'
    'CgR0YWdzGDIgAygLMgwucm9hZG1hcC5UYWdSBHRhZ3MSJgoGc2tpbGxzGGQgAygLMg4ucm9hZG'
    '1hcC5Ta2lsbFIGc2tpbGxz');


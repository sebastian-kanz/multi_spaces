import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:multi_spaces/core/constants.dart';
import 'package:web3dart/crypto.dart';

part 'meta_model.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
@HiveType(typeId: hiveMetaModelTypeId)
class MetaModel extends HiveObject {
  @HiveField(0)
  String hash;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // type of data element. pdf, png, text, custom, ...

  @HiveField(3)
  String format; // Bytes, Text, custom, ...

  @HiveField(4)
  int created; // unixtimestamp

  @HiveField(5)
  int size; // bytes

  @HiveField(6)
  int? quality; // quality of the data element

  @HiveField(7)
  String? metaRef; // ipfs hash of a meta element that might be related to this

  @HiveField(8)
  String? tags; // json list of tags

  @HiveField(9)
  String? coordinates; // json, where was the data element created

  @HiveField(10)
  String? language; // ISO language code

  @HiveField(11)
  String? compression; // compression algorithm used on data element, e.g. zip

  @HiveField(12)
  String? deeplink;

  MetaModel(
    this.hash,
    this.name,
    this.type,
    this.format,
    this.created,
    this.size, [
    this.quality,
    this.metaRef,
    this.tags,
    this.coordinates,
    this.language,
    this.compression,
    this.deeplink,
  ]);

  factory MetaModel.fromJson(Map<String, dynamic> json) =>
      _$MetaModelFromJson(json);

  factory MetaModel.fromHex(String hex) {
    try {
      final bytes = hexToBytes(hex);
      final jsonStr = String.fromCharCodes(bytes).replaceAll(": ,", ": '',");
      return MetaModel.fromJson(json.decode(jsonStr));
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$MetaModelToJson(this);

  String toHex() {
    final bytes = Uint8List.fromList(json.encode(toJson()).codeUnits);
    return bytesToHex(bytes);
  }

  Uint8List toBytes() {
    return Uint8List.fromList(json.encode(toJson()).codeUnits);
  }
}

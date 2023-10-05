class MetaEntity {
  String hash;
  String name;
  String type;
  String format;
  int created; // unixtimestamp
  int size; // bytes
  int? quality; // quality of the data element
  String? metaRef; // ipfs hash of a meta element that might be related to this
  String? tags; // json list of tags
  String? coordinates; // json, where was the data element created
  String? language; // ISO language code
  String? compression; // compression algorithm used on data element, e.g. zip
  String? deeplink;

  bool synced = true;

  MetaEntity(
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

  static MetaEntity unsynced(String hash) {
    final entity = MetaEntity(hash, "", "", "", -1, -1);
    entity.synced = false;
    return entity;
  }

  factory MetaEntity.fromJson(Map<String, dynamic> json) => MetaEntity(
        json['hash'],
        json['name'],
        json['type'],
        json['format'],
        json['created'],
        json['size'],
        json['quality'],
        json['metaRef'],
        json['tags'],
        json['coordinates'],
        json['language'],
        json['compression'],
        json['deeplink'],
      );

  Map<String, dynamic> toJson() => {
        'hash': hash,
        'name': name,
        'type': type,
        'format': format,
        'created': created,
        'size': size,
        'quality': quality,
        'metaRef': metaRef,
        'tags': tags,
        'coordinates': coordinates,
        'language': language,
        'compression': compression,
        'deeplink': deeplink,
      };
}

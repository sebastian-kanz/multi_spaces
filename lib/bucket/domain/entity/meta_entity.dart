class MetaEntity {
  String hash;
  String name;
  String type;
  String format;
  int created; // unixtimestamp
  int? quality; // quality of the data element
  String? metaRef; // ipfs hash of a meta element that might be related to this
  String? tags; // json list of tags
  String? coordinates; // json, where was the data element created
  String? language; // ISO language code
  String? compression; // compression algorithm used on data element, e.g. zip
  String? deeplink;

  MetaEntity(
    this.hash,
    this.name,
    this.type,
    this.format,
    this.created, [
    this.quality,
    this.metaRef,
    this.tags,
    this.coordinates,
    this.language,
    this.compression,
    this.deeplink,
  ]);
}

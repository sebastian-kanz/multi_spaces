class ContainerEntity {
  final String hash;
  final String identifier;

  bool synced = true;

  ContainerEntity(this.hash, this.identifier);

  static ContainerEntity unsynced(String hash) {
    final entity = ContainerEntity(hash, "");
    entity.synced = false;
    return entity;
  }

  factory ContainerEntity.fromJson(Map<String, dynamic> json) =>
      ContainerEntity(
        json['hash'],
        json['identifier'],
      );

  Map<String, dynamic> toJson() => {
        'hash': hash,
        'identifier': identifier,
      };
}

class BucketResponse {
  const BucketResponse(this.bucket, this.isActive, this.isExternal);

  final String bucket;
  final bool isActive;
  final bool isExternal;
}

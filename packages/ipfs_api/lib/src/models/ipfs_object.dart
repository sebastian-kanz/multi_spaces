import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A single IpfsObject.
class IpfsObject extends Equatable {
  IpfsObject({
    required this.hash,
    required this.data,
  }) : assert(
          hash.isNotEmpty,
          'hash can not be empty',
        );

  /// The unique hash of the ipfs object.
  final String hash;

  /// The raw data of the ipfs object.
  final Uint8List data;

  @override
  List<Object> get props => [hash, data];
}

import 'package:equatable/equatable.dart';

/// The result of uploaded data to IPFS.
class IpfsUploadResult extends Equatable {
  IpfsUploadResult({
    required this.hash,
    required int successes,
    required int failures,
  })  : assert(
          hash.isNotEmpty,
          'hash can not be empty',
        ),
        successRatio = successes / (successes + failures) * 1.0;

  /// The unique hash of the ipfs object.
  final String hash;

  /// The ratio of sucessful and failed uploads. Below 1 means something failed.
  final double successRatio;

  @override
  List<Object> get props => [hash, successRatio];
}

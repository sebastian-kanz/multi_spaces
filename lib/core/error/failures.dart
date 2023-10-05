import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String failure;
  const Failure(this.failure);

  @override
  List<Object> get props => [failure];
}

class RepositoryFailure extends Failure {
  const RepositoryFailure(failure) : super(failure);
}

class MissingKeyFailure extends Failure {
  final String address;
  final int block;
  final int epoch;
  const MissingKeyFailure(this.address, this.block, this.epoch)
      : super("Missing key for address $address and block $block!");
}

class UseCaseFailure extends Failure {
  const UseCaseFailure(failure) : super(failure);
}

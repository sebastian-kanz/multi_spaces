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

class UseCaseFailure extends Failure {
  const UseCaseFailure(failure) : super(failure);
}

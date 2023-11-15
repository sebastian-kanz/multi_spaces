import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/repository/bucket_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';

import '../../../core/usecases/usecase.dart';

class KeysExistingUseCase implements UseCase<bool, void> {
  final BucketRepository bucketRepository;

  KeysExistingUseCase(
    this.bucketRepository,
  );

  @override
  Future<Either<Failure, bool>> call([
    void params,
  ]) async {
    try {
      final allEpochsCount = await bucketRepository.getAllEpochsCount();
      return Right(allEpochsCount > 0);
    } catch (e) {
      return Left(UseCaseFailure('Checking for existing keys failed: $e'));
    }
  }
}

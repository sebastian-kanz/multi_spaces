import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/entity/full_element_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/container_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/element_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/meta_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';

import '../../../core/usecases/usecase.dart';

class UpdateElementUseCaseParams {
  final FullElementEntity toBeUpdated;
  // final Uint8List updatedContent;
  final String updatedName;
  // final List<FullElementEntity> parents;

  UpdateElementUseCaseParams(this.toBeUpdated, this.updatedName);
}

class UpdateElementUseCase
    implements UseCase<String, UpdateElementUseCaseParams> {
  final ElementRepository elementRepository;
  final MetaRepository metaRepository;
  final ContainerRepository containerRepository;

  UpdateElementUseCase(
    this.elementRepository,
    this.metaRepository,
    this.containerRepository,
  );

  @override
  Future<Either<Failure, String>> call(
    UpdateElementUseCaseParams params,
  ) async {
    try {
      final container = await containerRepository.createContainer();
      final meta = await metaRepository.createMeta(
        CreateMetaDto.fromEntity(params.toBeUpdated.meta).copyWith(
          name: params.updatedName,
          created: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
      );
      final transactionHash = await elementRepository.updateElement(
        params.toBeUpdated.element.element,
        meta.hash,
        params.toBeUpdated.data?.hash ?? "",
        container.hash,
        params.toBeUpdated.element.parentElement,
      );
      return Right(transactionHash);
    } catch (e) {
      return Left(UseCaseFailure('Updating elemens failed: $e'));
    }
  }
}

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/repository/container_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/data_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/element_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/meta_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';

import '../../../core/usecases/usecase.dart';
import '../entity/full_element_entity.dart';

class GetFullElementsUseCase implements UseCase<List<FullElementEntity>, bool> {
  final ElementRepository elementRepository;
  final MetaRepository metaRepository;
  final DataRepository dataRepository;
  final ContainerRepository containerRepository;

  GetFullElementsUseCase(
    this.elementRepository,
    this.metaRepository,
    this.dataRepository,
    this.containerRepository,
  );

  @override
  Future<Either<Failure, List<FullElementEntity>>> call(
    bool withData,
  ) async {
    try {
      final allElements = await elementRepository.getAllLocalElements();
      final allFullElements =
          await Future.wait(allElements.map((element) async {
        final meta = await metaRepository.getMeta(
          element.metaHash,
          creationBlockNumber: element.created,
        );
        final data = await dataRepository.getData(
          element.dataHash,
          creationBlockNumber: element.created,
        );
        final container =
            await containerRepository.getContainer(element.containerHash);
        if (withData) {
          return FullElementEntity(element, container, meta, data: data);
        }
        return FullElementEntity(element, container, meta);
      }));
      return Right(allFullElements);
    } catch (e) {
      return Left(UseCaseFailure('Getting elemens failed: $e'));
    }
  }
}

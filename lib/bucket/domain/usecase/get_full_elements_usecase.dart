import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/entity/container_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/meta_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/container_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/data_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/element_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/meta_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';

import '../../../core/usecases/usecase.dart';
import '../entity/full_element_entity.dart';

class GetFullElementsUseCaseParams {
  final bool syncData;
  final List<FullElementEntity> parents;
  final String? nameFilter;
  GetFullElementsUseCaseParams(
    this.syncData,
    this.parents, {
    this.nameFilter,
  });
}

class GetFullElementsUseCase
    implements UseCase<List<FullElementEntity>, GetFullElementsUseCaseParams> {
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
    GetFullElementsUseCaseParams params,
  ) async {
    try {
      List<ElementEntity> allElements = [];
      if (params.nameFilter != null) {
        allElements = await elementRepository.getLatest();
      } else {
        allElements = await elementRepository.getLatestChildren(
          parent: params.parents.lastOrNull?.element,
        );
      }
      final allFullElements =
          await Future.wait(allElements.map((element) async {
        try {
          final meta = await metaRepository.getMeta(
            element.metaHash,
            creationBlockNumber: element.created,
          );

          // apply filter
          if (params.nameFilter != null) {
            if (!meta.name.contains(params.nameFilter!)) {
              return null;
            }
          }

          final data = await dataRepository.getData(
            element.dataHash,
            meta.name,
            params.parents.map((e) => e.meta.name).toList(),
            creationBlockNumber: element.created,
          );
          final container =
              await containerRepository.getContainer(element.containerHash);
          if (params.syncData) {
            return FullElementEntity(element, container, meta, data: data);
          }
          return FullElementEntity(element, container, meta);
        } catch (e) {
          print(e);
          return FullElementEntity(
            element,
            ContainerEntity(element.containerHash, "UNKNOWN"),
            MetaEntity(
              element.metaHash,
              "UNKNOWN",
              "UNKNOWN",
              "UNKNOWN",
              -1,
              -1,
            ),
          );
        }
      }));
      final result = allFullElements.whereType<FullElementEntity>().toList();
      result.sort(((a, b) => b.meta.created - a.meta.created));
      return Right(result);
    } catch (e) {
      return Left(UseCaseFailure('Getting elemens failed: $e'));
    }
  }
}

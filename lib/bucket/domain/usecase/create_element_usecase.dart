import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/full_element_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/bucket_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/container_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/data_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/element_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/ipfs_vault_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/meta_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/participant_repository.dart';
import 'package:multi_spaces/core/constants.dart';
import 'package:multi_spaces/core/error/failures.dart';

import '../../../core/usecases/usecase.dart';

class CreateElementUseCaseParams {
  final Uint8List data;
  final CreateMetaDto createMetaDto;
  final List<FullElementEntity> parents;

  CreateElementUseCaseParams(this.data, this.createMetaDto, this.parents);
}

class CreateElementUseCase
    implements UseCase<String, CreateElementUseCaseParams> {
  final BucketRepository bucketRepository;
  final ElementRepository elementRepository;
  final MetaRepository metaRepository;
  final DataRepository dataRepository;
  final ContainerRepository containerRepository;
  final ParticipantRepository participantRepository;
  final IPFSVaultRepository ipfsVaultRepository;

  CreateElementUseCase(
    this.bucketRepository,
    this.elementRepository,
    this.metaRepository,
    this.dataRepository,
    this.containerRepository,
    this.participantRepository,
    this.ipfsVaultRepository,
  );

  @override
  Future<Either<Failure, String>> call(
    CreateElementUseCaseParams params,
  ) async {
    String containerHash = "";
    String metaHash = "";
    bool dataCreated = false;
    String metaName = "";
    List<String> parents = [];
    try {
      final container = await containerRepository.createContainer();
      containerHash = container.hash;
      final meta = await metaRepository.createMeta(
        params.createMetaDto,
      );
      metaHash = meta.hash;
      parents = params.parents.map((e) => e.meta.name).toList();
      final data = await dataRepository.createData(
        params.data,
        meta.name,
        parents,
      );
      dataCreated = true;
      metaName = meta.name;

      // TODO: Check balance, if limit depleted send via walletconnect, otherwise internally
      final transactionHash = await elementRepository.createElement(
        meta.hash,
        data.hash,
        container.hash,
        params.parents.lastOrNull?.element.element ?? zeroAddress,
        ContentType.file,
        // internal: false,
        // baseFee: some Value
      );
      return Right(transactionHash);
    } catch (e) {
      if (containerHash != "") {
        await containerRepository.removeContainer(containerHash);
      }
      if (metaHash != "") {
        await metaRepository.removeMeta(metaHash);
      }
      if (dataCreated) {
        await dataRepository.removeData(metaName, parents);
      }
      return Left(UseCaseFailure('Creating elemens failed: $e'));
    }
  }
}

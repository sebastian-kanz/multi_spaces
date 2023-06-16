import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/participant_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/bucket_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/container_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/data_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/element_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/ipfs_vault_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/meta_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/participant_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/usecases/usecase.dart';

class CreateElementUseCaseParams {
  final Uint8List data;
  final CreateMetaDto createMetaDto;
  final EthereumAddress parent;

  CreateElementUseCaseParams(this.data, this.createMetaDto, this.parent);
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
    try {
      final container = await containerRepository.createContainer();
      final meta = await metaRepository.createMeta(
        params.createMetaDto,
      );
      final data = await dataRepository.createData(params.data);
      final transactionHash = await elementRepository.createElement(
        meta.hash,
        data.hash,
        container.hash,
        params.parent,
        ContentType.file,
      );
      return Right(transactionHash);
    } catch (e) {
      return Left(UseCaseFailure('Creating elemens failed: $e'));
    }
  }
}

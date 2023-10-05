import 'dart:async';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/repository/bucket_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/ipfs_vault_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/participant_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/usecases/usecase.dart';

class AddDeviceParticipationUseCase implements UseCase<String, void> {
  final BucketRepository bucketRepository;
  final IPFSVaultRepository ipfsVaultRepository;
  final ParticipantRepository participantRepository;

  AddDeviceParticipationUseCase(
    this.bucketRepository,
    this.ipfsVaultRepository,
    this.participantRepository,
  );

  @override
  Future<Either<Failure, String>> call([void params]) async {
    try {
      final txHash = await bucketRepository.addParticipation(
        '\$device:${BlockchainProviderManager().internalProvider.getAccount().hex}',
        BlockchainProviderManager().internalProvider.getAccount(),
        BlockchainProviderManager().internalProvider.getPublicKey(),
      );

      return Right(txHash);
    } catch (e) {
      return Left(UseCaseFailure('Adding device participation failed: $e'));
    }
  }
}

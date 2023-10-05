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

class AcceptParticipationUseCaseParams {
  final EthereumAddress requestor;
  AcceptParticipationUseCaseParams(
    this.requestor,
  );
}

class AcceptParticipationUseCase
    implements UseCase<String, AcceptParticipationUseCaseParams> {
  final BucketRepository bucketRepository;
  final IPFSVaultRepository ipfsVaultRepository;
  final ParticipantRepository participantRepository;

  AcceptParticipationUseCase(
    this.bucketRepository,
    this.ipfsVaultRepository,
    this.participantRepository,
  );

  @override
  Future<Either<Failure, String>> call(
    AcceptParticipationUseCaseParams params,
  ) async {
    try {
      final allParticipants = await participantRepository.getAllParticipants();
      final participant = allParticipants.firstWhere(
        (element) => element.address.hex == params.requestor.hex,
      );
      final request =
          await participantRepository.getRequest(participant.address);
      final requestorPubkeyHex = bytesToHex(participant.publicKey);
      final device = allParticipants.firstWhere(
        (element) => element.address.hex == request.device.hex,
      );
      final devicePubkeyHex = bytesToHex(device.publicKey);

      final allEpochsCount = await bucketRepository.getAllEpochsCount();
      List<KeyCreation> keyCreations = [];
      //TODO: Problem: adding keys for many epoch leads to many transactions
      for (var i = 0; i < allEpochsCount; i++) {
        final epoch = await bucketRepository.getEpoch(i);
        // Export key does not work for newly added device (when external providers tries to add internal), as the key does not exist on the new device.
        // Key management is done by internal not by external provider
        final keyForParticipant = await ipfsVaultRepository.exportKey(
          requestorPubkeyHex,
          blockNumber: await bucketRepository.epochToBlock(epoch),
        );
        final keyForDevice = await ipfsVaultRepository.exportKey(
          devicePubkeyHex,
          blockNumber: await bucketRepository.epochToBlock(epoch),
        );
        final keyCreationParticipant =
            await bucketRepository.setKeyForParticipant(
          participant.address,
          keyForParticipant,
          epoch,
        );
        final keyCreationDevice = await bucketRepository.setKeyForParticipant(
          device.address,
          keyForDevice,
          epoch,
        );
        keyCreations.add(keyCreationParticipant);
        keyCreations.add(keyCreationDevice);
      }

      final txHash = await bucketRepository.acceptParticipation(
        params.requestor,
        baseFee: 1000000000000000,
      );

      return Right(txHash);
    } catch (e) {
      return Left(UseCaseFailure('Accepting participation failed: $e'));
    }
  }
}

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/entity/participant_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/bucket_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/ipfs_vault_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/participant_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:web3dart/crypto.dart';

import '../../../core/usecases/usecase.dart';

class CreateKeysUseCase implements UseCase<KeyCreation?, void> {
  final BucketRepository bucketRepository;
  final ParticipantRepository participantRepository;
  final IPFSVaultRepository ipfsVaultRepository;

  CreateKeysUseCase(
    this.bucketRepository,
    this.participantRepository,
    this.ipfsVaultRepository,
  );

  @override
  Future<Either<Failure, KeyCreation?>> call(
    void params,
  ) async {
    try {
      final allParticipants = await participantRepository.getAllParticipants();
      final hexOwnPublicKey = ipfsVaultRepository.getOwnPublicKey();
      final List<ParticipantEntity> participants = [];
      final List<String> keys = [];
      for (var participant in allParticipants) {
        final keyBundle = await bucketRepository.getCurrentKeyForParticipant(
          participant.address,
        );
        if (keyBundle.key.isEmpty) {
          final key = await ipfsVaultRepository.exportKey(
            bytesToHex(participant.publicKey),
          );
          participants.add(participant);
          keys.add(key);
        }
      }
      if (participants.isNotEmpty) {
        final keyCreationTxHash = await bucketRepository.addKeys(
          participants.map((e) => e.address).toList(),
          keys,
          hexOwnPublicKey,
        );
        return Right(keyCreationTxHash);
      }
      return const Right(null);
    } catch (e) {
      return Left(UseCaseFailure('Creating keys failed: $e'));
    }
  }
}

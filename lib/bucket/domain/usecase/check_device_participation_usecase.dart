import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/repository/ipfs_vault_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/participant_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:web3dart/crypto.dart';

import '../../../core/usecases/usecase.dart';

class CheckDeviceParticipationUseCase implements UseCase<bool, void> {
  final ParticipantRepository participantRepository;
  final IPFSVaultRepository ipfsVaultRepository;

  CheckDeviceParticipationUseCase(
    this.participantRepository,
    this.ipfsVaultRepository,
  );

  @override
  Future<Either<Failure, bool>> call([void params]) async {
    try {
      final devicePublicKeyHex = ipfsVaultRepository.getOwnPublicKey();
      final allParticipants = await participantRepository.getAllParticipants();
      final filteredParticipants = allParticipants.where(
        (participant) =>
            bytesToHex(participant.publicKey) == devicePublicKeyHex,
      );
      if (filteredParticipants.isNotEmpty) {
        final request = await participantRepository
            .getRequest(filteredParticipants.first.address);
        if (!request.accepted &&
            filteredParticipants.firstOrNull?.initialized == false) {
          return const Right(false);
        } else {
          return const Right(true);
        }
      }
      return const Right(false);
    } catch (e) {
      return Left(UseCaseFailure('Checking device participation failed: $e'));
    }
  }
}

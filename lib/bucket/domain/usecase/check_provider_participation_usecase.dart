import 'dart:async';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/repository/participant_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:web3dart/crypto.dart';

import '../../../core/usecases/usecase.dart';

class CheckProviderParticipationUseCase implements UseCase<bool, void> {
  final ParticipantRepository participantRepository;

  CheckProviderParticipationUseCase(
    this.participantRepository,
  );

  @override
  Future<Either<Failure, bool>> call([void params]) async {
    try {
      final publicKeyHex =
          BlockchainProviderManager().authenticatedProvider!.getPublicKeyHex();
      final allParticipants = await participantRepository.getAllParticipants();
      final filteredParticipants = allParticipants.where(
        (participant) => bytesToHex(participant.publicKey) == publicKeyHex,
      );
      if (filteredParticipants.isNotEmpty) {
        final request = await participantRepository
            .getRequest(filteredParticipants.first.address);
        if (!request.accepted && request.requestor.hex != ZERO_ADDRESS.hex) {
          return const Right(false);
        } else {
          return const Right(true);
        }
      }
      return const Right(false);
    } catch (e) {
      return Left(UseCaseFailure('Checking participation failed: $e'));
    }
  }
}

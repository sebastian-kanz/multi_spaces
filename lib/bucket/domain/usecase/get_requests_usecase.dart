import 'dart:async';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/repository/participant_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/usecases/usecase.dart';

class GetActiveRequestsUseCase implements UseCase<List<EthereumAddress>, void> {
  final ParticipantRepository participantRepository;

  GetActiveRequestsUseCase(
    this.participantRepository,
  );

  @override
  Future<Either<Failure, List<EthereumAddress>>> call([void params]) async {
    try {
      final participants = await participantRepository.getAllParticipants();
      List<EthereumAddress> activeRequests = [];
      for (var participant in participants) {
        final request =
            await participantRepository.getRequest(participant.address);
        if (request.requestor.hex != ZERO_ADDRESS.hex && !request.accepted) {
          activeRequests.add(request.requestor);
        }
      }
      return Right(activeRequests);
    } catch (e) {
      return Left(UseCaseFailure('Getting active requests failed: $e'));
    }
  }
}

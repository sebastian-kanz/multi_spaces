import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/repository/bucket_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/ipfs_vault_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/participant_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:web3dart/crypto.dart';

import '../../../core/usecases/usecase.dart';

class RequestParticipationUseCase implements UseCase<String, void> {
  final BucketRepository bucketRepository;
  final ParticipantRepository participantRepository;

  RequestParticipationUseCase(
    this.bucketRepository,
    this.participantRepository,
  );

  @override
  Future<Either<Failure, String>> call([void params]) async {
    try {
      final user = BlockchainProviderManager().authenticatedProvider!;
      final device = BlockchainProviderManager().internalProvider;
      final request = await participantRepository.getRequest(user.getAccount());
      if (request.requestor.hex == ZERO_ADDRESS.hex) {
        final name = "\$user:${user.getAccount()}";
        final deviceName = "\$device:${device.getAccount()}";
        final hash = keccakUtf8(name);
        final signature = await user.sign(
          message: bytesToHex(hash, include0x: false),
        );

        final txHash = await bucketRepository.requestParticipation(
          name,
          user.getAccount(),
          user.getPublicKey(),
          deviceName,
          device.getAccount(),
          device.getPublicKey(),
          hexToBytes(signature),
        );

        return Right(txHash);
      }
      return Right("");
    } catch (e) {
      return Left(UseCaseFailure('Requesting participation failed: $e'));
    }
  }
}

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:multi_spaces/bucket/domain/entity/participant_entity.dart';
import 'package:multi_spaces/core/contracts/ParticipantManager.g.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:retry/retry.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';

import '../../domain/repository/participant_repository.dart';

class ParticipantRepositoryImpl implements ParticipantRepository {
  ParticipantRepositoryImpl(String participantManagerContractAddress)
      : _participantManager = ParticipantManager(
          address: EthereumAddress.fromHex(participantManagerContractAddress),
          client: MultiSpaceClient().client,
          chainId: Env.chain_id,
        );

  final ParticipantManager _participantManager;

  @override
  Future<List<ParticipantEntity>> getAllParticipants() async {
    final count = (await retry(
      () => _participantManager.participantCount(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
    final List<EthereumAddress> addresses = [];
    for (var i = 0; i < count; i++) {
      final address = await retry(
        () => _participantManager.allParticipantAddresses(
          BigInt.from(i),
        ),
        retryIf: (e) => e is RPCError,
      );
      addresses.add(address);
    }
    final List<ParticipantEntity> participants = [];
    for (var address in addresses) {
      final participant = await retry(
        () => _participantManager.allParticipants(address),
        retryIf: (e) => e is RPCError,
      );
      participants.add(
        ParticipantEntity(
          participant.adr,
          participant.name,
          participant.publicKey,
          participant.initialized,
        ),
      );
    }
    return participants;
  }

  @override
  Future<AllRequests> getRequest(EthereumAddress requestor) async {
    return retry(
      () => _participantManager.allRequests(requestor),
      retryIf: (e) => e is RPCError,
    );
  }

  @override
  Stream<EthereumAddress> get listenParticipants {
    // yield* _participantManager
    //     .addParticipantEvents()
    //     .asyncMap((event) => event.participant);
    return _participantManager
        .addParticipantEvents()
        .asyncMap((event) => event.participant);
  }

  @override
  Stream<EthereumAddress> get listenRequestors {
    // yield* _participantManager
    //     .addRequestorEvents()
    //     .asyncMap((event) => event.requestor);
    return _participantManager
        .addRequestorEvents()
        .asyncMap((event) => event.requestor);
  }

  // @override
  // Future<String> addParticipant(
  //   String inviteeName,
  //   String invitee,
  //   String inviteePubKeyHex,
  // ) async {
  //   var r = Random.secure();
  //   const chars =
  //       'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  //   final randomCode = List.generate(
  //     10,
  //     (index) => chars[r.nextInt(chars.length)],
  //   ).join();
  //   final hash = keccakUtf8(randomCode);

  //   final signature = await BlockchainProviderManager()
  //       .authenticatedProvider!
  //       .sign(message: bytesToHex(hash));
  //   return _participantManager.redeemParticipationCode(
  //     inviteeName,
  //     BlockchainProviderManager().authenticatedProvider!.getAccount(),
  //     EthereumAddress.fromPublicKey(hexToBytes(inviteePubKeyHex)),
  //     hexToBytes(signature),
  //     randomCode,
  //     hexToBytes(inviteePubKeyHex),
  //     credentials:
  //         BlockchainProviderManager().authenticatedProvider!.getCredentails(),
  //     transaction: Transaction(
  //       from: BlockchainProviderManager().authenticatedProvider!.getAccount(),
  //       maxGas: 3000000,
  //     ),
  //   );
  // }
}

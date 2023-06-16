import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:multi_spaces/bucket/domain/entity/participant_entity.dart';
import 'package:multi_spaces/core/contracts/ParticipantManager.g.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import '../../domain/repository/participant_repository.dart';

class ParticipantRepositoryImpl implements ParticipantRepository {
  ParticipantRepositoryImpl(List<BlockchainProvider> providers,
      String participantManagerContractAddress)
      : _participantManager = ParticipantManager(
          address: EthereumAddress.fromHex(participantManagerContractAddress),
          client: Web3Client(Env.eth_url, Client()),
          chainId: Env.chain_id,
        ) {
    for (var provider in providers) {
      if (provider.isAuthenticated()) {
        _provider = provider;
      }
    }
  }

  final ParticipantManager _participantManager;
  late BlockchainProvider _provider;

  @override
  Future<List<ParticipantEntity>> getAllParticipants() async {
    final count = (await _participantManager.participantCount()).toInt();
    final List<EthereumAddress> addresses = [];
    for (var i = 0; i < count; i++) {
      final address = await _participantManager.allParticipantAddresses(
        BigInt.from(i),
      );
      addresses.add(address);
    }
    final List<ParticipantEntity> participants = [];
    for (var address in addresses) {
      final participant = await _participantManager.allParticipants(address);
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
}

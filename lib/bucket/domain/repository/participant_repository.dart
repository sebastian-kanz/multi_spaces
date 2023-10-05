import 'package:multi_spaces/bucket/domain/entity/participant_entity.dart';
import 'package:multi_spaces/core/contracts/ParticipantManager.g.dart';
import 'package:web3dart/web3dart.dart';

abstract class ParticipantRepository {
  Future<List<ParticipantEntity>> getAllParticipants();
  Future<AllRequests> getRequest(EthereumAddress requestor);

  Stream<EthereumAddress> get listenParticipants;
  Stream<EthereumAddress> get listenRequestors;

  // Future<String> addParticipant(
  //   String inviteeName,
  //   String inviteeAddressHex,
  //   String inviteePubKeyHex,
  // );
}

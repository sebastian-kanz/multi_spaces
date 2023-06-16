import 'package:multi_spaces/bucket/domain/entity/participant_entity.dart';
import 'package:web3dart/web3dart.dart';

abstract class ParticipantRepository {
  Future<List<ParticipantEntity>> getAllParticipants();
}

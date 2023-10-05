import 'dart:async';
import 'package:multi_spaces/bucket/domain/repository/participant_repository.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/usecases/usecase.dart';

class ListenParticipationEventsUseCase
    implements StreamUseCase<EthereumAddress, void> {
  final ParticipantRepository repository;

  ListenParticipationEventsUseCase(this.repository);

  @override
  Future<Stream<EthereumAddress>> call([void params]) async {
    try {
      return Future.value(
        repository.listenParticipants,
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}

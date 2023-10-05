import 'dart:async';
import 'package:multi_spaces/bucket/domain/repository/participant_repository.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/usecases/usecase.dart';

class ListenRequestEventsUseCase
    implements StreamUseCase<EthereumAddress, void> {
  final ParticipantRepository repository;

  ListenRequestEventsUseCase(this.repository);

  @override
  Future<Stream<EthereumAddress>> call([void params]) async {
    try {
      return Future.value(
        repository.listenRequestors,
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}

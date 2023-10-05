import 'dart:async';
import 'package:multi_spaces/bucket/domain/entity/element_event_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/element_repository.dart';
import 'package:web3dart/web3dart.dart';
import '../../../core/usecases/usecase.dart';

class ListenElementUseCaseParams {
  final EthereumAddress element;
  ListenElementUseCaseParams(this.element);
}

class ListenElementUseCase
    implements StreamUseCase<ElementEventEntity, ListenElementUseCaseParams> {
  final ElementRepository elementRepository;

  ListenElementUseCase(
    this.elementRepository,
  );

  @override
  Future<Stream<ElementEventEntity>> call(
      ListenElementUseCaseParams? params) async {
    try {
      return Future.value(
        elementRepository.listenElementRequests(params!.element),
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}

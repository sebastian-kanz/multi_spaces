import 'dart:async';

import 'package:multi_spaces/bucket/domain/entity/element_event_entity.dart';

import '../../../core/usecases/usecase.dart';
import '../repository/bucket_repository.dart';
import 'package:async/async.dart' show StreamGroup;

class ListenBucketEventsUseCase
    implements StreamUseCase<ElementEventEntity, void> {
  final BucketRepository repository;

  ListenBucketEventsUseCase(this.repository);

  @override
  Future<Stream<ElementEventEntity>> call([void params]) async {
    try {
      return StreamGroup.merge([
        repository.listenCreate,
        repository.listenUpdate,
        repository.listenDelete,
        repository.listenUpdateParent,
      ]);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}

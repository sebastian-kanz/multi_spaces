import 'dart:async';
import '../../../core/usecases/usecase.dart';
import '../repository/bucket_repository.dart';

class ListenKeyEventsUseCase implements StreamUseCase<int, void> {
  final BucketRepository repository;

  ListenKeyEventsUseCase(this.repository);

  @override
  Future<Stream<int>> call([void params]) async {
    try {
      return Future.value(
        repository.listenKey,
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}

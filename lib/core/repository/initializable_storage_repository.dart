import 'package:hive/hive.dart';
import 'package:multi_spaces/core/error/failures.dart';

mixin InitializableStorageRepository<T> {
  // ignore: unused_field
  late Box<T> _box;
  Box<T> get box => _isInitialized
      ? _box
      : throw RepositoryFailure(
          "Box uninitialized for ${T.toString()}!",
        );

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(String identifier) async {
    if (!_isInitialized) {
      _box = await Hive.openBox<T>("${T}_$identifier");
      _isInitialized = true;
    }
  }
}

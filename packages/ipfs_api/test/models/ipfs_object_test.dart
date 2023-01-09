// ignore_for_file: avoid_redundant_argument_values
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:ipfs_api/ipfs_api.dart';

void main() {
  group('IpfsObject', () {
    IpfsObject createSubject({
      required String hash,
      required Uint8List data,
    }) {
      return IpfsObject(
        hash: hash,
        data: data,
      );
    }

    group('constructor', () {
      test('works correctly', () {
        expect(
          () =>
              createSubject(hash: 'Qm...', data: Uint8List.fromList([1, 2, 3])),
          returnsNormally,
        );
      });

      test('throws AssertionError when hash is empty', () {
        expect(
          () => createSubject(hash: '', data: Uint8List(0)),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    test('supports value equality', () {
      expect(
        createSubject(hash: '123', data: Uint8List(0)),
        equals(createSubject(hash: '123', data: Uint8List(0))),
      );
    });
  });
}

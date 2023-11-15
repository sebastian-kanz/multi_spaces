import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:multi_spaces/core/contracts/Space.g.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/space/models/bucket_instance_model.dart';
import 'package:retry/retry.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';

import '../../core/contracts/Bucket.g.dart' hide Initialized, Create;

class SpaceRepository {
  SpaceRepository(String spaceContractAddress)
      : _space = Space(
            address: EthereumAddress.fromHex(spaceContractAddress),
            client: MultiSpaceClient().client,
            chainId: Env.chain_id),
        _client = MultiSpaceClient().client;

  final Web3Client _client;
  final Space _space;

  Stream<Create> get listenCreate => _space.createEvents();

  Stream<Remove> get listenRemove {
    // yield* _space.removeEvents();
    return _space.removeEvents();
  }

  Stream<Rename> get listenRename {
    // yield* _space.renameEvents();
    return _space.renameEvents();
  }

  Stream<Initialized> get listenInitialize {
    // yield* _space.initializedEvents();
    return _space.initializedEvents();
  }

  Future<SpaceOwner> getSpaceOwner() async {
    return retry(
      () => _space.spaceOwner(),
      retryIf: (e) => e is RPCError,
    );
  }

  EthereumAddress getSpaceAddress() {
    return _space.self.address;
  }

  Future<List<BucketInstance>> getAllBuckets() async {
    final buckets = await retry(
      () => _space.getAllBuckets(),
      retryIf: (e) => e is RPCError,
    );
    final bucketResponses = buckets.toList().map((element) async {
      final index = buckets.toList().indexOf(element);
      final bucketName = await retry(
        () => _space.allBucketNames(BigInt.from(index)),
        retryIf: (e) => e is RPCError,
      );

      final code =
          await _client.getCode(EthereumAddress.fromHex(element[0].toString()));
      if (code.isEmpty) {
        await retry(
          () => _space.removeBucket(
            bucketName,
            credentials: BlockchainProviderManager()
                .authenticatedProvider!
                .getCredentails(),
            transaction: Transaction(
              from: BlockchainProviderManager()
                  .authenticatedProvider!
                  .getAccount(),
              maxGas: 3000000,
            ),
          ),
          retryIf: (e) => e is RPCError,
        );
        return null;
      }

      final bucket = Bucket(
          address: EthereumAddress.fromHex(element[0].toString()),
          client: _client,
          chainId: Env.chain_id);
      final creation = await retry(
        () => bucket.GENESIS(),
        retryIf: (e) => e is RPCError,
      );
      final block = await retry(
        () => _client.getBlockInformation(
          blockNumber: BlockNum.exact(creation.toInt()).toBlockParam(),
        ),
        retryIf: (e) => e is RPCError,
      );

      final minRedundancy = await retry(
        () => bucket.minElementRedundancy(),
        retryIf: (e) => e is RPCError,
      );
      final allElements = await retry(
        () => bucket.getAll(),
        retryIf: (e) => e is RPCError,
      );

      return BucketInstance(
        bucketName,
        element[0],
        block.timestamp,
        minRedundancy.toInt(),
        allElements.length,
        element[1],
        element[2],
      );
    }).toList();
    final result = (await Future.wait(bucketResponses))
        .where((element) => element != null)
        .map((element) => element!)
        .toList();
    result.sort((a, b) =>
        b.creation.toUtc().millisecondsSinceEpoch -
        a.creation.toUtc().millisecondsSinceEpoch);
    return result;
  }

  Future<String> getBucketNameByIndex(int index) async {
    return retry(
      () => _space.allBucketNames(BigInt.from(index)),
      retryIf: (e) => e is RPCError,
    );
  }

  Future<String> addExternalBucket(
    String bucketName,
    EthereumAddress bucketAddress,
  ) async {
    return _space.addExternalBucket(
      bucketName,
      bucketAddress,
      credentials:
          BlockchainProviderManager().authenticatedProvider!.getCredentails(),
      transaction: Transaction(
        from: BlockchainProviderManager().authenticatedProvider!.getAccount(),
        maxGas: 3000000,
      ),
    );
  }

  Future<String> createBucket(String bucketName, {int? baseFee}) async {
    if (baseFee != null) {
      return _space.addBucket(
        bucketName,
        credentials:
            BlockchainProviderManager().authenticatedProvider!.getCredentails(),
        transaction: Transaction(
          from: BlockchainProviderManager().authenticatedProvider!.getAccount(),
          maxGas: 3000000,
          value: EtherAmount.inWei(BigInt.from(baseFee)),
        ),
      );
    }
    return _space.addBucket(
      bucketName,
      credentials:
          BlockchainProviderManager().authenticatedProvider!.getCredentails(),
      transaction: Transaction(
        from: BlockchainProviderManager().authenticatedProvider!.getAccount(),
        maxGas: 3000000,
      ),
    );
  }

  Future<String> renameBucket(String oldName, String newName) async {
    return _space.renameBucket(
      oldName,
      newName,
      credentials:
          BlockchainProviderManager().authenticatedProvider!.getCredentails(),
      transaction: Transaction(
        from: BlockchainProviderManager().authenticatedProvider!.getAccount(),
        maxGas: 3000000,
      ),
    );
  }

  Future<String> removeBucket(String bucketName) async {
    return _space.removeBucket(
      bucketName,
      credentials:
          BlockchainProviderManager().authenticatedProvider!.getCredentails(),
      transaction: Transaction(
        from: BlockchainProviderManager().authenticatedProvider!.getAccount(),
        maxGas: 3000000,
      ),
    );
  }
}

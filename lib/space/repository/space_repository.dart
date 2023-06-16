import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:multi_spaces/core/contracts/Space.g.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/space/models/bucket_instance_model.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import '../../core/contracts/Bucket.g.dart' hide Initialized, Create;

class SpaceRepository {
  SpaceRepository(
      List<BlockchainProvider> providers, String spaceContractAddress)
      : _space = Space(
            address: EthereumAddress.fromHex(spaceContractAddress),
            client: Web3Client(Env.eth_url, Client()),
            chainId: Env.chain_id),
        _client = Web3Client(Env.eth_url, Client()) {
    for (var provider in providers) {
      if (provider.isAuthenticated()) {
        _provider = provider;
      }
    }
  }

  final Web3Client _client;
  final Space _space;
  late BlockchainProvider _provider;

  Stream<Create> get listenCreate => _space.createEvents();

  Stream<Remove> get listenRemove async* {
    yield* _space.removeEvents();
  }

  Stream<Rename> get listenRename async* {
    yield* _space.renameEvents();
  }

  Stream<Initialized> get listenInitialize async* {
    yield* _space.initializedEvents();
  }

  Future<SpaceOwner> getSpaceOwner() async {
    return _space.spaceOwner();
  }

  EthereumAddress getSpaceAddress() {
    return _space.self.address;
  }

  Future<List<BucketInstance>> getAllBuckets() async {
    final buckets = await _space.getAllBuckets();
    final bucketResponses = buckets.toList().map((element) async {
      final index = buckets.toList().indexOf(element);
      final bucketName = await _space.allBucketNames(BigInt.from(index));
      final bucket = Bucket(
          address: EthereumAddress.fromHex(element[0].toString()),
          client: _client,
          chainId: Env.chain_id);
      final creation = await bucket.GENESIS();
      final block = await _client.getBlockInformation(
        blockNumber: BlockNum.exact(creation.toInt()).toBlockParam(),
      );
      final minRedundancy = await bucket.minElementRedundancy();
      final allElements = await bucket.getAll();

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
    return await Future.wait(bucketResponses);
  }

  Future<String> getBucketNameByIndex(int index) async {
    return _space.allBucketNames(BigInt.from(index));
  }

  Future<String> addExternalBucket(
    String bucketName,
    EthereumAddress bucketAddress,
  ) async {
    return _space.addExternalBucket(
      bucketName,
      bucketAddress,
      credentials: _provider.getCredentails(),
      transaction: Transaction(
        from: _provider.getAccount(),
        maxGas: 3000000,
      ),
    );
  }

  Future<String> createBucket(String bucketName, {int? baseFee}) async {
    if (baseFee != null) {
      return _space.addBucket(
        bucketName,
        credentials: _provider.getCredentails(),
        transaction: Transaction(
          from: _provider.getAccount(),
          maxGas: 3000000,
          value: EtherAmount.inWei(BigInt.from(baseFee)),
        ),
      );
    }
    return _space.addBucket(
      bucketName,
      credentials: _provider.getCredentails(),
      transaction: Transaction(
        from: _provider.getAccount(),
        maxGas: 3000000,
      ),
    );
  }

  Future<String> renameBucket(String oldName, String newName) async {
    return _space.renameBucket(
      oldName,
      newName,
      credentials: _provider.getCredentails(),
      transaction: Transaction(
        from: _provider.getAccount(),
        maxGas: 3000000,
      ),
    );
  }

  Future<String> removeBucket(String bucketName) async {
    return _space.removeBucket(
      bucketName,
      credentials: _provider.getCredentails(),
      transaction: Transaction(
        from: _provider.getAccount(),
        maxGas: 3000000,
      ),
    );
  }
}

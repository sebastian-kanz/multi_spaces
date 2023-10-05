// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_addr","type":"address"},{"indexed":false,"internalType":"address","name":"_sender","type":"address"}],"name":"Create","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint8","name":"version","type":"uint8"}],"name":"Initialized","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_addr","type":"address"},{"indexed":false,"internalType":"address","name":"_sender","type":"address"}],"name":"Remove","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_addr","type":"address"},{"indexed":false,"internalType":"address","name":"_sender","type":"address"}],"name":"Rename","type":"event"},{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"addBucket","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"adr","type":"address"}],"name":"addExternalBucket","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"allBucketNames","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"","type":"string"}],"name":"allBuckets","outputs":[{"internalType":"contract IBucket","name":"bucket","type":"address"},{"internalType":"bool","name":"active","type":"bool"},{"internalType":"bool","name":"isExternal","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"bucketFactory","outputs":[{"internalType":"contract IBucketFactory","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getAllBuckets","outputs":[{"components":[{"internalType":"contract IBucket","name":"bucket","type":"address"},{"internalType":"bool","name":"active","type":"bool"},{"internalType":"bool","name":"isExternal","type":"bool"}],"internalType":"struct Space.BucketContainer[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"string","name":"name","type":"string"},{"internalType":"bytes","name":"pubKey","type":"bytes"},{"internalType":"address","name":"bFactory","type":"address"},{"internalType":"address","name":"pManager","type":"address"}],"name":"initialize","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"removeBucket","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"string","name":"newBucketName","type":"string"}],"name":"renameBucket","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"spaceOwner","outputs":[{"internalType":"address","name":"adr","type":"address"},{"internalType":"string","name":"name","type":"string"},{"internalType":"bytes","name":"publicKey","type":"bytes"},{"internalType":"bool","name":"initialized","type":"bool"}],"stateMutability":"view","type":"function"}]',
  'Space',
);

class Space extends _i1.GeneratedContract {
  Space({
    required _i1.EthereumAddress address,
    required _i1.Web3Client client,
    int? chainId,
  }) : super(
          _i1.DeployedContract(
            _contractAbi,
            address,
          ),
          client,
          chainId,
        );

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> addBucket(
    String name, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, 'da303f38'));
    final params = [name];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> addExternalBucket(
    String name,
    _i1.EthereumAddress adr, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '148c4b8d'));
    final params = [
      name,
      adr,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<String> allBucketNames(
    BigInt $param3, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '868f2278'));
    final params = [$param3];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as String);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<AllBuckets> allBuckets(
    String $param4, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, '0364f996'));
    final params = [$param4];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return AllBuckets(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> bucketFactory({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, '986fe9bd'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<List<dynamic>> getAllBuckets({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, '051cd27e'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as List<dynamic>).cast<dynamic>();
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> initialize(
    _i1.EthereumAddress owner,
    String name,
    _i2.Uint8List pubKey,
    _i1.EthereumAddress bFactory,
    _i1.EthereumAddress pManager, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, '050df607'));
    final params = [
      owner,
      name,
      pubKey,
      bFactory,
      pManager,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> removeBucket(
    String name, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '606a6a98'));
    final params = [name];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> renameBucket(
    String name,
    String newBucketName, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, '70f180b0'));
    final params = [
      name,
      newBucketName,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<SpaceOwner> spaceOwner({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, '340260f1'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return SpaceOwner(response);
  }

  /// Returns a live stream of all Create events emitted by this contract.
  Stream<Create> createEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('Create');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return Create(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all Initialized events emitted by this contract.
  Stream<Initialized> initializedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('Initialized');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return Initialized(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all Remove events emitted by this contract.
  Stream<Remove> removeEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('Remove');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return Remove(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all Rename events emitted by this contract.
  Stream<Rename> renameEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('Rename');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return Rename(
        decoded,
        result,
      );
    });
  }
}

class AllBuckets {
  AllBuckets(List<dynamic> response)
      : bucket = (response[0] as _i1.EthereumAddress),
        active = (response[1] as bool),
        isExternal = (response[2] as bool);

  final _i1.EthereumAddress bucket;

  final bool active;

  final bool isExternal;
}

class SpaceOwner {
  SpaceOwner(List<dynamic> response)
      : adr = (response[0] as _i1.EthereumAddress),
        name = (response[1] as String),
        publicKey = (response[2] as _i2.Uint8List),
        initialized = (response[3] as bool);

  final _i1.EthereumAddress adr;

  final String name;

  final _i2.Uint8List publicKey;

  final bool initialized;
}

class Create {
  Create(
    List<dynamic> response,
    this.event,
  )   : addr = (response[0] as _i1.EthereumAddress),
        sender = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress addr;

  final _i1.EthereumAddress sender;

  final _i1.FilterEvent event;
}

class Initialized {
  Initialized(
    List<dynamic> response,
    this.event,
  ) : version = (response[0] as BigInt);

  final BigInt version;

  final _i1.FilterEvent event;
}

class Remove {
  Remove(
    List<dynamic> response,
    this.event,
  )   : addr = (response[0] as _i1.EthereumAddress),
        sender = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress addr;

  final _i1.EthereumAddress sender;

  final _i1.FilterEvent event;
}

class Rename {
  Rename(
    List<dynamic> response,
    this.event,
  )   : addr = (response[0] as _i1.EthereumAddress),
        sender = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress addr;

  final _i1.EthereumAddress sender;

  final _i1.FilterEvent event;
}

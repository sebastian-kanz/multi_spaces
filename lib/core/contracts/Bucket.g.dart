// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_elem","type":"address"},{"indexed":true,"internalType":"uint256","name":"_blockNumber","type":"uint256"},{"indexed":true,"internalType":"address","name":"_sender","type":"address"}],"name":"Create","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_elem","type":"address"},{"indexed":false,"internalType":"uint256","name":"_blockNumber","type":"uint256"},{"indexed":true,"internalType":"address","name":"_sender","type":"address"}],"name":"Delete","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint8","name":"version","type":"uint8"}],"name":"Initialized","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"epoch","type":"uint256"}],"name":"KeysAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_prevElem","type":"address"},{"indexed":true,"internalType":"address","name":"_newElemt","type":"address"},{"indexed":false,"internalType":"uint256","name":"_blockNumber","type":"uint256"},{"indexed":true,"internalType":"address","name":"_sender","type":"address"}],"name":"Update","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_elem","type":"address"},{"indexed":true,"internalType":"address","name":"_parent","type":"address"},{"indexed":false,"internalType":"uint256","name":"_blockNumber","type":"uint256"},{"indexed":true,"internalType":"address","name":"_sender","type":"address"}],"name":"UpdateParent","type":"event"},{"inputs":[],"name":"EPOCH","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"GENESIS","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"requestor","type":"address"}],"name":"acceptParticipation","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"string[]","name":"keys","type":"string[]"},{"internalType":"address[]","name":"participants","type":"address[]"},{"internalType":"string","name":"keyCreatorPubKey","type":"string"}],"name":"addKeys","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"newParticipantName","type":"string"},{"internalType":"address","name":"newParticipantAdr","type":"address"},{"internalType":"bytes","name":"newParticipantPubKey","type":"bytes"}],"name":"addParticipation","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"allElements","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"allEpochs","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"allEpochsCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"closeBucket","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string[]","name":"newMetaHashes","type":"string[]"},{"internalType":"string[]","name":"newDataHashes","type":"string[]"},{"internalType":"string[]","name":"newContainerHashes","type":"string[]"},{"internalType":"address[]","name":"parents","type":"address[]"},{"internalType":"uint256","name":"contentType","type":"uint256"}],"name":"createElements","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"elementImpl","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"address","name":"","type":"address"}],"name":"epochToParticipantToKeyMapping","outputs":[{"internalType":"string","name":"key","type":"string"},{"internalType":"string","name":"keyCreatorPubKey","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getAll","outputs":[{"internalType":"address[]","name":"","type":"address[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getHistory","outputs":[{"components":[{"internalType":"address","name":"elem","type":"address"},{"internalType":"enum LibElement.OperationType","name":"operationType","type":"uint8"},{"internalType":"uint256","name":"blockNumber","type":"uint256"}],"internalType":"struct LibElement.Operation[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"participant","type":"address"},{"internalType":"uint256","name":"blockNumber","type":"uint256"}],"name":"getKeyBundle","outputs":[{"internalType":"string","name":"","type":"string"},{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"","type":"string"}],"name":"hashExists","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"history","outputs":[{"internalType":"address","name":"elem","type":"address"},{"internalType":"enum LibElement.OperationType","name":"operationType","type":"uint8"},{"internalType":"uint256","name":"blockNumber","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"pManager","type":"address"},{"internalType":"address","name":"partManager","type":"address"},{"internalType":"address","name":"impl","type":"address"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"minElementRedundancy","outputs":[{"internalType":"enum LibElement.RedundancyLevel","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"sender","type":"address"}],"name":"notifyCreation","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"contract Element","name":"elem","type":"address"},{"internalType":"address","name":"sender","type":"address"}],"name":"notifyDelete","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"contract Element","name":"elem","type":"address"},{"internalType":"address","name":"sender","type":"address"}],"name":"notifyUpdate","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"contract Element","name":"elem","type":"address"},{"internalType":"address","name":"sender","type":"address"}],"name":"notifyUpdateParent","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"participantManager","outputs":[{"internalType":"contract IParticipantManager","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"contract Element","name":"elem","type":"address"}],"name":"preRegisterElement","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"registeredElements","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"removeParticipation","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"requestor","type":"address"},{"internalType":"bytes","name":"pubKey","type":"bytes"},{"internalType":"string","name":"deviceName","type":"string"},{"internalType":"address","name":"device","type":"address"},{"internalType":"bytes","name":"devicePubKey","type":"bytes"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"requestParticipation","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"impl","type":"address"}],"name":"setElementImplementation","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"key","type":"string"},{"internalType":"address","name":"participant","type":"address"},{"internalType":"string","name":"keyCreatorPubKey","type":"string"},{"internalType":"uint256","name":"blockNumber","type":"uint256"}],"name":"setKeyForParticipant","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"enum LibElement.RedundancyLevel","name":"level","type":"uint8"}],"name":"setMinElementRedundancy","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"elemAdr","type":"address"},{"internalType":"address","name":"parentAdr","type":"address"}],"name":"updateParent","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
  'Bucket',
);

class Bucket extends _i1.GeneratedContract {
  Bucket({
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

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> EPOCH({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, 'a0dc2758'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> GENESIS({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, 'b7dec1b7'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> acceptParticipation(
    _i1.EthereumAddress requestor, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '5698e40e'));
    final params = [requestor];
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
  Future<String> addKeys(
    List<String> keys,
    List<_i1.EthereumAddress> participants,
    String keyCreatorPubKey, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, '0bb5c9f5'));
    final params = [
      keys,
      participants,
      keyCreatorPubKey,
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
  Future<String> addParticipation(
    String newParticipantName,
    _i1.EthereumAddress newParticipantAdr,
    _i2.Uint8List newParticipantPubKey, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, '186034d7'));
    final params = [
      newParticipantName,
      newParticipantAdr,
      newParticipantPubKey,
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
  Future<_i1.EthereumAddress> allElements(
    BigInt $param7, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, '5598e24f'));
    final params = [$param7];
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
  Future<BigInt> allEpochs(
    BigInt $param8, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, '4a6513e3'));
    final params = [$param8];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> allEpochsCount({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '30f178b6'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> closeBucket({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, '3d4f10ff'));
    final params = [];
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
  Future<String> createElements(
    List<String> newMetaHashes,
    List<String> newDataHashes,
    List<String> newContainerHashes,
    List<_i1.EthereumAddress> parents,
    BigInt contentType, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, 'a41bbac6'));
    final params = [
      newMetaHashes,
      newDataHashes,
      newContainerHashes,
      parents,
      contentType,
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
  Future<_i1.EthereumAddress> elementImpl({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[10];
    assert(checkSignature(function, '0a1847e8'));
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
  Future<EpochToParticipantToKeyMapping> epochToParticipantToKeyMapping(
    BigInt $param14,
    _i1.EthereumAddress $param15, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[11];
    assert(checkSignature(function, 'cc1de539'));
    final params = [
      $param14,
      $param15,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return EpochToParticipantToKeyMapping(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<List<_i1.EthereumAddress>> getAll({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[12];
    assert(checkSignature(function, '53ed5143'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as List<dynamic>).cast<_i1.EthereumAddress>();
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<List<dynamic>> getHistory({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[13];
    assert(checkSignature(function, 'aa15efc8'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as List<dynamic>).cast<dynamic>();
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetKeyBundle> getKeyBundle(
    _i1.EthereumAddress participant,
    BigInt blockNumber, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[14];
    assert(checkSignature(function, 'e4601393'));
    final params = [
      participant,
      blockNumber,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return GetKeyBundle(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> hashExists(
    String $param18, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[15];
    assert(checkSignature(function, '9871e510'));
    final params = [$param18];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as bool);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<History> history(
    BigInt $param19, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[16];
    assert(checkSignature(function, 'a7a38f0b'));
    final params = [$param19];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return History(response);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> initialize(
    _i1.EthereumAddress pManager,
    _i1.EthereumAddress partManager,
    _i1.EthereumAddress impl, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[17];
    assert(checkSignature(function, 'c0c53b8b'));
    final params = [
      pManager,
      partManager,
      impl,
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
  Future<BigInt> minElementRedundancy({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[18];
    assert(checkSignature(function, '70ede1ba'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> notifyCreation(
    _i1.EthereumAddress sender, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[19];
    assert(checkSignature(function, '57f826da'));
    final params = [sender];
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
  Future<String> notifyDelete(
    _i1.EthereumAddress elem,
    _i1.EthereumAddress sender, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[20];
    assert(checkSignature(function, 'e3879b5f'));
    final params = [
      elem,
      sender,
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
  Future<String> notifyUpdate(
    _i1.EthereumAddress elem,
    _i1.EthereumAddress sender, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[21];
    assert(checkSignature(function, '3eb5a183'));
    final params = [
      elem,
      sender,
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
  Future<String> notifyUpdateParent(
    _i1.EthereumAddress elem,
    _i1.EthereumAddress sender, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[22];
    assert(checkSignature(function, '0b2ff4e5'));
    final params = [
      elem,
      sender,
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
  Future<_i1.EthereumAddress> participantManager(
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[23];
    assert(checkSignature(function, '464dbe6e'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> preRegisterElement(
    _i1.EthereumAddress elem, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[24];
    assert(checkSignature(function, '9d05e762'));
    final params = [elem];
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
  Future<bool> registeredElements(
    _i1.EthereumAddress $param31, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[25];
    assert(checkSignature(function, 'c26d8e10'));
    final params = [$param31];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as bool);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> removeParticipation({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[26];
    assert(checkSignature(function, '7450da72'));
    final params = [];
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
  Future<String> requestParticipation(
    String name,
    _i1.EthereumAddress requestor,
    _i2.Uint8List pubKey,
    String deviceName,
    _i1.EthereumAddress device,
    _i2.Uint8List devicePubKey,
    _i2.Uint8List signature, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[27];
    assert(checkSignature(function, '39811935'));
    final params = [
      name,
      requestor,
      pubKey,
      deviceName,
      device,
      devicePubKey,
      signature,
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
  Future<String> setElementImplementation(
    _i1.EthereumAddress impl, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[28];
    assert(checkSignature(function, '6e60e116'));
    final params = [impl];
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
  Future<String> setKeyForParticipant(
    String key,
    _i1.EthereumAddress participant,
    String keyCreatorPubKey,
    BigInt blockNumber, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[29];
    assert(checkSignature(function, '49b22aa0'));
    final params = [
      key,
      participant,
      keyCreatorPubKey,
      blockNumber,
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
  Future<String> setMinElementRedundancy(
    BigInt level, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[30];
    assert(checkSignature(function, '87fb41cf'));
    final params = [level];
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
  Future<String> updateParent(
    _i1.EthereumAddress elemAdr,
    _i1.EthereumAddress parentAdr, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[31];
    assert(checkSignature(function, '6bc94414'));
    final params = [
      elemAdr,
      parentAdr,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
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

  /// Returns a live stream of all Delete events emitted by this contract.
  Stream<Delete> deleteEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('Delete');
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
      return Delete(
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

  /// Returns a live stream of all KeysAdded events emitted by this contract.
  Stream<KeysAdded> keysAddedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('KeysAdded');
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
      return KeysAdded(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all Update events emitted by this contract.
  Stream<Update> updateEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('Update');
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
      return Update(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all UpdateParent events emitted by this contract.
  Stream<UpdateParent> updateParentEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('UpdateParent');
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
      return UpdateParent(
        decoded,
        result,
      );
    });
  }
}

class EpochToParticipantToKeyMapping {
  EpochToParticipantToKeyMapping(List<dynamic> response)
      : key = (response[0] as String),
        keyCreatorPubKey = (response[1] as String);

  final String key;

  final String keyCreatorPubKey;
}

class GetKeyBundle {
  GetKeyBundle(List<dynamic> response)
      : var1 = (response[0] as String),
        var2 = (response[1] as String);

  final String var1;

  final String var2;
}

class History {
  History(List<dynamic> response)
      : elem = (response[0] as _i1.EthereumAddress),
        operationType = (response[1] as BigInt),
        blockNumber = (response[2] as BigInt);

  final _i1.EthereumAddress elem;

  final BigInt operationType;

  final BigInt blockNumber;
}

class Create {
  Create(
    List<dynamic> response,
    this.event,
  )   : elem = (response[0] as _i1.EthereumAddress),
        blockNumber = (response[1] as BigInt),
        sender = (response[2] as _i1.EthereumAddress);

  final _i1.EthereumAddress elem;

  final BigInt blockNumber;

  final _i1.EthereumAddress sender;

  final _i1.FilterEvent event;
}

class Delete {
  Delete(
    List<dynamic> response,
    this.event,
  )   : elem = (response[0] as _i1.EthereumAddress),
        blockNumber = (response[1] as BigInt),
        sender = (response[2] as _i1.EthereumAddress);

  final _i1.EthereumAddress elem;

  final BigInt blockNumber;

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

class KeysAdded {
  KeysAdded(
    List<dynamic> response,
    this.event,
  ) : epoch = (response[0] as BigInt);

  final BigInt epoch;

  final _i1.FilterEvent event;
}

class Update {
  Update(
    List<dynamic> response,
    this.event,
  )   : prevElem = (response[0] as _i1.EthereumAddress),
        newElemt = (response[1] as _i1.EthereumAddress),
        blockNumber = (response[2] as BigInt),
        sender = (response[3] as _i1.EthereumAddress);

  final _i1.EthereumAddress prevElem;

  final _i1.EthereumAddress newElemt;

  final BigInt blockNumber;

  final _i1.EthereumAddress sender;

  final _i1.FilterEvent event;
}

class UpdateParent {
  UpdateParent(
    List<dynamic> response,
    this.event,
  )   : elem = (response[0] as _i1.EthereumAddress),
        parent = (response[1] as _i1.EthereumAddress),
        blockNumber = (response[2] as BigInt),
        sender = (response[3] as _i1.EthereumAddress);

  final _i1.EthereumAddress elem;

  final _i1.EthereumAddress parent;

  final BigInt blockNumber;

  final _i1.EthereumAddress sender;

  final _i1.FilterEvent event;
}

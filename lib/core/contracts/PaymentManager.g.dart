// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"inputs":[{"internalType":"uint256","name":"baseFee","type":"uint256"},{"internalType":"uint256","name":"baseLimit","type":"uint256"},{"internalType":"uint256","name":"price","type":"uint256"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"enum IPaymentManager.LimitedAction","name":"_action","type":"uint8"},{"indexed":true,"internalType":"address","name":"_sender","type":"address"},{"indexed":true,"internalType":"address","name":"_owner","type":"address"},{"indexed":false,"internalType":"uint256","name":"limitLeftOver","type":"uint256"},{"indexed":false,"internalType":"bool","name":"unlimited","type":"bool"}],"name":"LimitedActionEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"enum IPaymentManager.PayableAction","name":"_action","type":"uint8"},{"indexed":true,"internalType":"address","name":"_sender","type":"address"},{"indexed":false,"internalType":"uint256","name":"fee","type":"uint256"},{"indexed":false,"internalType":"bool","name":"voucher","type":"bool"},{"indexed":false,"internalType":"bool","name":"unlimited","type":"bool"}],"name":"PayableActionEvent","type":"event"},{"stateMutability":"payable","type":"fallback"},{"inputs":[{"internalType":"enum IPaymentManager.LimitedAction","name":"","type":"uint8"}],"name":"DEFAULT_LIMITS","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"enum IPaymentManager.PayableAction","name":"","type":"uint8"}],"name":"DEFAULT_PAYMENTS","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"adr","type":"address"},{"internalType":"enum IPaymentManager.LimitedAction","name":"action","type":"uint8"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"addLimit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"adr","type":"address"},{"internalType":"enum IPaymentManager.PayableAction","name":"action","type":"uint8"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"addVoucher","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"enum IPaymentManager.PayableAction","name":"action","type":"uint8"}],"name":"chargeFee","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"enum IPaymentManager.LimitedAction","name":"action","type":"uint8"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"decreaseLimit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"getBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"enum IPaymentManager.LimitedAction","name":"action","type":"uint8"}],"name":"getLimit","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"enum IPaymentManager.PayableAction","name":"action","type":"uint8"}],"name":"getVoucherCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"receiver","type":"address"}],"name":"increaseCredits","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"enum IPaymentManager.LimitedAction","name":"action","type":"uint8"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"address","name":"bucket","type":"address"}],"name":"increaseLimit","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"enum IPaymentManager.PayableAction","name":"action","type":"uint8"}],"name":"isFreeOfCharge","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"enum IPaymentManager.LimitedAction","name":"action","type":"uint8"}],"name":"isUnlimited","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"limitPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"manufacturerWithdraw","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"receiver","type":"address"},{"internalType":"uint256","name":"credit","type":"uint256"},{"internalType":"string","name":"random","type":"string"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"redeemCredit","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"enum IPaymentManager.PayableAction","name":"action","type":"uint8"},{"internalType":"bool","name":"enable","type":"bool"}],"name":"setAccountFreeOfCharge","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"enum IPaymentManager.LimitedAction","name":"action","type":"uint8"},{"internalType":"bool","name":"enable","type":"bool"}],"name":"setAccountUnlimited","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"newBaseFee","type":"uint256"}],"name":"setDefaultFee","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"newBaseLimit","type":"uint256"}],"name":"setDefaultLimit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"price","type":"uint256"}],"name":"setLimitPrice","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"address","name":"receiver","type":"address"}],"name":"transferCredits","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}]',
  'PaymentManager',
);

class PaymentManager extends _i1.GeneratedContract {
  PaymentManager({
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
  Future<BigInt> DEFAULT_LIMITS(
    BigInt $param0, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, 'e348baf8'));
    final params = [$param0];
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
  Future<BigInt> DEFAULT_PAYMENTS(
    BigInt $param1, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, 'ffcc153d'));
    final params = [$param1];
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
  Future<String> addLimit(
    _i1.EthereumAddress adr,
    BigInt action,
    BigInt amount, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, 'b1e25b1b'));
    final params = [
      adr,
      action,
      amount,
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
  Future<String> addVoucher(
    _i1.EthereumAddress adr,
    BigInt action,
    BigInt amount, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, 'b280b000'));
    final params = [
      adr,
      action,
      amount,
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
  Future<String> chargeFee(
    BigInt action, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, 'd43c83b7'));
    final params = [action];
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
  Future<String> decreaseLimit(
    BigInt action,
    BigInt amount, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '0aec5d23'));
    final params = [
      action,
      amount,
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
  Future<BigInt> getBalance(
    _i1.EthereumAddress account, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, 'f8b2cb4f'));
    final params = [account];
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
  Future<String> getLimit(
    _i1.EthereumAddress account,
    BigInt action, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, '4b15c7f0'));
    final params = [
      account,
      action,
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
  Future<BigInt> getVoucherCount(
    _i1.EthereumAddress account,
    BigInt action, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[10];
    assert(checkSignature(function, '5cc8fc0e'));
    final params = [
      account,
      action,
    ];
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
  Future<String> increaseCredits(
    _i1.EthereumAddress receiver, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[11];
    assert(checkSignature(function, '676755e4'));
    final params = [receiver];
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
  Future<String> increaseLimit(
    BigInt action,
    BigInt amount,
    _i1.EthereumAddress bucket, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[12];
    assert(checkSignature(function, '75732cf6'));
    final params = [
      action,
      amount,
      bucket,
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
  Future<bool> isFreeOfCharge(
    _i1.EthereumAddress account,
    BigInt action, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[13];
    assert(checkSignature(function, '3644a17b'));
    final params = [
      account,
      action,
    ];
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
  Future<bool> isUnlimited(
    _i1.EthereumAddress account,
    BigInt action, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[14];
    assert(checkSignature(function, '0ab35163'));
    final params = [
      account,
      action,
    ];
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
  Future<BigInt> limitPrice({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[15];
    assert(checkSignature(function, 'b94df913'));
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
  Future<String> manufacturerWithdraw({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[16];
    assert(checkSignature(function, '8d3c82e2'));
    final params = [];
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
  Future<_i1.EthereumAddress> owner({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[17];
    assert(checkSignature(function, '8da5cb5b'));
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
  Future<String> redeemCredit(
    _i1.EthereumAddress receiver,
    BigInt credit,
    String random,
    _i2.Uint8List signature, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[18];
    assert(checkSignature(function, 'f8fd0e41'));
    final params = [
      receiver,
      credit,
      random,
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
  Future<String> renounceOwnership({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[19];
    assert(checkSignature(function, '715018a6'));
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
  Future<String> setAccountFreeOfCharge(
    _i1.EthereumAddress account,
    BigInt action,
    bool enable, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[20];
    assert(checkSignature(function, 'd1b465d4'));
    final params = [
      account,
      action,
      enable,
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
  Future<String> setAccountUnlimited(
    _i1.EthereumAddress account,
    BigInt action,
    bool enable, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[21];
    assert(checkSignature(function, '9f611aa8'));
    final params = [
      account,
      action,
      enable,
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
  Future<String> setDefaultFee(
    BigInt newBaseFee, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[22];
    assert(checkSignature(function, 'c93a6c84'));
    final params = [newBaseFee];
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
  Future<String> setDefaultLimit(
    BigInt newBaseLimit, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[23];
    assert(checkSignature(function, '995284b1'));
    final params = [newBaseLimit];
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
  Future<String> setLimitPrice(
    BigInt price, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[24];
    assert(checkSignature(function, 'c4b137fd'));
    final params = [price];
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
  Future<String> transferCredits(
    BigInt amount,
    _i1.EthereumAddress receiver, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[25];
    assert(checkSignature(function, 'd93b2dd0'));
    final params = [
      amount,
      receiver,
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
  Future<String> transferOwnership(
    _i1.EthereumAddress newOwner, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[26];
    assert(checkSignature(function, 'f2fde38b'));
    final params = [newOwner];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// Returns a live stream of all LimitedActionEvent events emitted by this contract.
  Stream<LimitedActionEvent> limitedActionEventEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('LimitedActionEvent');
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
      return LimitedActionEvent(decoded);
    });
  }

  /// Returns a live stream of all OwnershipTransferred events emitted by this contract.
  Stream<OwnershipTransferred> ownershipTransferredEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('OwnershipTransferred');
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
      return OwnershipTransferred(decoded);
    });
  }

  /// Returns a live stream of all PayableActionEvent events emitted by this contract.
  Stream<PayableActionEvent> payableActionEventEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('PayableActionEvent');
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
      return PayableActionEvent(decoded);
    });
  }
}

class LimitedActionEvent {
  LimitedActionEvent(List<dynamic> response)
      : action = (response[0] as BigInt),
        sender = (response[1] as _i1.EthereumAddress),
        owner = (response[2] as _i1.EthereumAddress),
        limitLeftOver = (response[3] as BigInt),
        unlimited = (response[4] as bool);

  final BigInt action;

  final _i1.EthereumAddress sender;

  final _i1.EthereumAddress owner;

  final BigInt limitLeftOver;

  final bool unlimited;
}

class OwnershipTransferred {
  OwnershipTransferred(List<dynamic> response)
      : previousOwner = (response[0] as _i1.EthereumAddress),
        newOwner = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress previousOwner;

  final _i1.EthereumAddress newOwner;
}

class PayableActionEvent {
  PayableActionEvent(List<dynamic> response)
      : action = (response[0] as BigInt),
        sender = (response[1] as _i1.EthereumAddress),
        fee = (response[2] as BigInt),
        voucher = (response[3] as bool),
        unlimited = (response[4] as bool);

  final BigInt action;

  final _i1.EthereumAddress sender;

  final BigInt fee;

  final bool voucher;

  final bool unlimited;
}

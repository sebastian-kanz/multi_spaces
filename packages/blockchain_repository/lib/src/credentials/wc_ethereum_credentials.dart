import 'dart:typed_data';
import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class WcEthereumCredentials extends CustomTransactionSender {
  WcEthereumCredentials({required this.provider});

  final BlockchainProvider provider;

  @override
  Future<String> sendTransaction(Transaction transaction) async {
    return provider.sendTransaction(
      from: transaction.from!.hex,
      to: transaction.to!.hex,
      data: transaction.data,
      gas: transaction.maxGas,
      gasPrice: transaction.gasPrice?.getInWei,
      value: transaction.value?.getInWei,
      nonce: transaction.nonce,
    );
  }

  @override
  EthereumAddress get address => provider.getAccount();

  @override
  Future<EthereumAddress> extractAddress() =>
      Future.value(provider.getAccount());

  @override
  MsgSignature signToEcSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    // TODO: implement signToEcSignature
    throw UnimplementedError();
  }

  @override
  Future<MsgSignature> signToSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) async {
    // TODO: implement extractAddress
    throw UnimplementedError();
  }
}

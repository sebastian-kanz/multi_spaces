import 'dart:typed_data';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:eth_sig_util/util/bytes.dart';

import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class WcEthereumCredentials extends CustomTransactionSender {
  WcEthereumCredentials({required this.provider});

  final EthereumWalletConnectProvider provider;

  @override
  Future<String> sendTransaction(Transaction transaction) async {
    final hash = await provider.sendTransaction(
      from: transaction.from!.hex,
      to: transaction.to?.hex,
      data: transaction.data,
      gas: transaction.maxGas,
      gasPrice: transaction.gasPrice?.getInWei,
      value: transaction.value?.getInWei,
      nonce: transaction.nonce,
    );

    return hash;
  }

  @override
  // TODO: implement address
  EthereumAddress get address =>
      EthereumAddress.fromHex(provider.connector.session.accounts[0]);

  @override
  Future<EthereumAddress> extractAddress() {
    // TODO: implement extractAddress
    throw UnimplementedError();
  }

  @override
  MsgSignature signToEcSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    // TODO: implement signToEcSignature
    throw UnimplementedError();
  }

  @override
  Future<MsgSignature> signToSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) async {
    final sigHex = await provider.sign(
      message: bufferToHex(payload),
      address: provider.connector.session.accounts[0],
    );
    final sig = SignatureUtil.fromRpcSig(sigHex);
    return MsgSignature(sig.r, sig.s, sig.v);
  }
}

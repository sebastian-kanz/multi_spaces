import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:blockchain_repository/blockchain_repository.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class EthereumWcProvider extends EthereumWalletConnectProvider
    implements BlockchainProvider {
  final Web3Client _client;
  WcEthereumCredentials? credentials;

  static late EthereumWcProvider _instance;

  factory EthereumWcProvider.withStorage(
    SessionStorage storage,
    WalletConnectSession? session,
  ) {
    _instance = EthereumWcProvider._internal(
      session: session,
      storage: storage,
    );
    return _instance;
  }

  factory EthereumWcProvider() => _instance;

  EthereumWcProvider._internal({
    WalletConnectSession? session,
    SessionStorage? storage,
  })  : _client = Web3Client(Env.eth_url, Client()),
        super(
            WalletConnect(
              bridge: Env.walletconnect_bridge,
              session: session,
              sessionStorage: storage,
              clientMeta: const PeerMeta(
                name: Env.walletconnect_name,
                description: Env.walletconnect_description,
                url: Env.walletconnect_url,
                icons: [Env.walletconnect_icon],
              ),
            ),
            chainId: 0) {
    credentials = WcEthereumCredentials(provider: this);
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> login(Map<String, dynamic> params) async {
    connector.reconnect();
    await connector.connect(onDisplayUri: (uri) => params['onDisplayUri'](uri));
    connector.on("disconnect", (event) => params['onDisconnect']());
  }

  @override
  Future<void> logout() async {
    if (connector.session.connected) {
      await connector.killSession();
      await connector.close();
    }
  }

  @override
  Future<String> callContract(
      {required DeployedContract contract,
      required ContractFunction function,
      required List<dynamic> params,
      required int value}) async {
    if (credentials != null) {
      final transaction = Transaction.callContract(
        contract: contract,
        function: function,
        parameters: params,
        from: credentials?.address,
        value: EtherAmount.fromUnitAndValue(EtherUnit.wei, value),
      );
      return _client.sendTransaction(credentials!, transaction);
    } else {
      throw Exception("No valid credentials available");
    }
  }

  @override
  bool isAuthenticated() {
    return connector.session.connected;
  }

  @override
  EthereumAddress? getAccount() {
    return credentials?.address;
  }

  @override
  Future<Map<String, String?>> getUserInfo() async {
    return {};
  }
}

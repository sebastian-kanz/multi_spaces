import 'package:envied/envied.dart';

part 'Env.g.dart';

@Envied(
    name: 'Env',
    path: ".env.${const String.fromEnvironment(
      'ENV',
      defaultValue: 'dev',
    )}")
abstract class Env {
  @EnviedField(varName: 'ETH_URL')
  static const String eth_url = _Env.eth_url;

  @EnviedField(varName: 'ETH_WS')
  static const String eth_ws = _Env.eth_ws;

  @EnviedField(varName: 'CHAIN_ID')
  static const int chain_id = _Env.chain_id;

  @EnviedField(varName: 'CHAIN_NAMESPACE')
  static const String chain_namespace = _Env.chain_namespace;

  @EnviedField(varName: 'CLIENT_ID')
  static const String client_id = _Env.client_id;

  @EnviedField(varName: 'WALLETCONNECT_BRIDGE')
  static const String walletconnect_bridge = _Env.walletconnect_bridge;

  @EnviedField(varName: 'WALLETCONNECT_NAME')
  static const String walletconnect_name = _Env.walletconnect_name;

  @EnviedField(varName: 'WALLETCONNECT_DESCRIPTION')
  static const String walletconnect_description =
      _Env.walletconnect_description;

  @EnviedField(varName: 'WALLETCONNECT_URL')
  static const String walletconnect_url = _Env.walletconnect_url;

  @EnviedField(varName: 'WALLETCONNECT_ICON')
  static const String walletconnect_icon = _Env.walletconnect_icon;

  @EnviedField(varName: 'WALLETCONNECT_PROJECT_ID')
  static const String walletconnect_project_id = _Env.walletconnect_project_id;

  @EnviedField(varName: 'MULTI_SPACES_CONTRACT_ADDRESS')
  static const String multi_spaces_contract_address =
      _Env.multi_spaces_contract_address;

  @EnviedField(varName: 'INFURA_PROJECT_ID')
  static const String infura_project_id = _Env.infura_project_id;

  @EnviedField(varName: 'INFURA_API_KEY')
  static const String infura_api_key = _Env.infura_api_key;

  @EnviedField(varName: 'PINATA_JWT')
  static const String pinata_jwt = _Env.pinata_jwt;

  @EnviedField(varName: 'PINATA_API_KEY')
  static const String pinata_api_key = _Env.pinata_api_key;

  @EnviedField(varName: 'PINATA_API_SECRET')
  static const String pinata_api_secret = _Env.pinata_api_secret;

  @EnviedField(varName: 'WEB_STORAGE_JWT')
  static const String web_storage_jwt = _Env.web_storage_jwt;
}

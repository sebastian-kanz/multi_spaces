import 'package:flutter_envify/flutter_envify.dart';
part 'Env.g.dart';

@Envify(
    name: 'Env',
    path: ".env.${const String.fromEnvironment(
      'ENV',
      defaultValue: 'dev',
    )}")
abstract class Env {
  static const client_id = _Env.client_id;

  static const eth_url = _Env.eth_url;
  static const int chain_id = _Env.chain_id;

  static const walletconnect_bridge = _Env.walletconnect_bridge;

  static const walletconnect_name = _Env.walletconnect_name;

  static const walletconnect_description = _Env.walletconnect_description;

  static const walletconnect_url = _Env.walletconnect_url;

  static const walletconnect_icon = _Env.walletconnect_icon;

  static const multi_spaces_contract_address =
      _Env.multi_spaces_contract_address;

  static const infura_project_id = _Env.infura_project_id;

  static const infura_api_key = _Env.infura_api_key;

  static const pinata_jwt = _Env.pinata_jwt;

  static const pinata_api_key = _Env.pinata_api_key;

  static const pinata_api_secret = _Env.pinata_api_secret;

  static const web_storage_jwt = _Env.web_storage_jwt;
}

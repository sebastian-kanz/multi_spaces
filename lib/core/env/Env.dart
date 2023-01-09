import 'package:flutter_envify/flutter_envify.dart';
part 'Env.g.dart';

@Envify(
    name: 'Env',
    path: ".env.${const String.fromEnvironment(
      'ENV',
      defaultValue: 'dev',
    )}")
abstract class Env {
  /// Holds the API_KEY.
  static const api_key = _Env.api_key;

  /// Holds the SITE_KEY.
  static const site_key = _Env.site_key;

  /// Holds the CLIENT_SECRET.
  static const client_secret = _Env.client_secret;

  /// Holds the CLIENT_ID.
  static const client_id = _Env.client_id;

  static const eth_url = _Env.eth_url;

  static const walletconnect_bridge = _Env.walletconnect_bridge;

  static const walletconnect_name = _Env.walletconnect_name;

  static const walletconnect_description = _Env.walletconnect_description;

  static const walletconnect_url = _Env.walletconnect_url;

  static const walletconnect_icon = _Env.walletconnect_icon;
}

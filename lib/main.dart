import 'dart:convert';
import 'dart:io';
import 'package:cryptography_flutter/cryptography_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_theme/json_theme.dart';
import 'package:multi_spaces/core/repository/ethereum_address_adapter.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:multi_spaces/core/blockchain_providers/ethereum_internal_provider.dart';
import 'package:multi_spaces/core/blockchain_providers/ethereum_wc_provider.dart';
import 'package:provider/provider.dart';
import 'core/blockchain_providers/ethereum_web3auth_provider.dart';
import 'core/storage/wc_secure_storage.dart';

// TODO: Remove for production
class MultiSpaceHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterCryptography.enable();

  HttpOverrides.global = MultiSpaceHttpOverrides();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationSupportDirectory(),
  );
  final providers = await setupProviders();

  final root = await getApplicationDocumentsDirectory();
  final path = '${root.path}/multi_spaces';
  Hive
    ..init(path)
    ..registerAdapter(EthereumAddressAdapter());

  runApp(
    Provider<List<BlockchainProvider>>(
      create: (_) => providers,
      child: App(
        providers: providers,
      ),
    ),
  );
}

Future<List<BlockchainProvider>> setupProviders() async {
  final sessionStorage = WalletConnectSecureStorage();
  final session = await sessionStorage.getSession();
  final providers = [
    EthereumWcProvider.withStorage(sessionStorage, session),
    EthereumInternalProvider()
  ];
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    providers.add(EthereumWeb3AuthProvider());
  }
  for (var provider in providers) {
    await provider.init();
  }
  return providers;
}

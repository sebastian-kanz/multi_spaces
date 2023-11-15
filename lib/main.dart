import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:multi_spaces/core/repository/ethereum_address_adapter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:multi_spaces/core/blockchain_providers/ethereum_internal_provider.dart';
import 'package:multi_spaces/core/blockchain_providers/ethereum_wc_provider.dart';
import 'core/blockchain_providers/ethereum_web3auth_provider.dart';

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

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('first_run') ?? true) {
    SecureStorage storage = SecureStorage();
    await storage.deleteAll();
    prefs.setBool('first_run', false);
  }
  HttpOverrides.global = MultiSpaceHttpOverrides();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationSupportDirectory(),
  );

  final initialAppLink = await getInitialAppLink();
  BlockchainProviderManager().providers = await setupProviders();

  if (!kIsWeb) {
    final root = await getApplicationDocumentsDirectory();
    final path = '${root.path}/multi_spaces/database';
    Hive
      ..init(path)
      ..registerAdapter(EthereumAddressAdapter());
  }

  runApp(
    App(appLink: initialAppLink),
  );
}

Future<List<BlockchainProvider>> setupProviders() async {
  final providers = [EthereumWcProvider(), EthereumInternalProvider()];
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    providers.add(EthereumWeb3AuthProvider());
  }
  for (var provider in providers) {
    await provider.init();
  }
  return providers;
}

Future<Uri?> getInitialAppLink() async {
  final appLinks = AppLinks();
  return appLinks.getInitialAppLink();
}

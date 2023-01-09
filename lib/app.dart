import 'package:blockchain_authentication_repository/blockchain_authentication_repository.dart';
import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:blockchain_repository/blockchain_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_spaces/authentication/bloc/authentication_bloc.dart';
import 'package:multi_spaces/core/blockchain_providers/ethereum_internal_provider.dart';
import 'package:multi_spaces/core/blockchain_providers/ethereum_wc_provider.dart';
import 'package:multi_spaces/core/blockchain_repository/internal_blockchain_repository.dart';
import 'package:multi_spaces/home/home.dart';
import 'package:multi_spaces/login/screens/login/login_page.dart';
import 'package:multi_spaces/splash/splash.dart';
import 'package:user_repository/user_repository.dart';

import 'core/blockchain_providers/ethereum_web3auth_provider.dart';
import 'core/storage/wc_secure_storage.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  Future<List<BlockchainProvider>> setupProviders() async {
    final sessionStorage = WalletConnectSecureStorage();
    final session = await sessionStorage.getSession();
    final providers = [
      EthereumWcProvider.withStorage(sessionStorage, session),
      EthereumWeb3AuthProvider(),
      EthereumInternalProvider()
    ];
    for (var provider in providers) {
      await provider.init();
    }
    return providers;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BlockchainProvider>>(
        future: setupProviders(),
        builder: (context, AsyncSnapshot<List<BlockchainProvider>> snapshot) {
          if (snapshot.hasData) {
            return MultiRepositoryProvider(
              providers: [
                RepositoryProvider<InternalBlockchainRepository>(
                  create: (context) =>
                      InternalBlockchainRepository(snapshot.data!),
                ),
                RepositoryProvider<BlockchainRepository>(
                  create: (context) => BlockchainRepository(snapshot.data!),
                ),
                RepositoryProvider<BlockchainAuthenticationRepository>(
                  create: (context) =>
                      BlockchainAuthenticationRepository(snapshot.data!),
                ),
                RepositoryProvider<UserRepository>(
                  create: (context) => UserRepository(snapshot.data!),
                ),
              ],
              child: BlocProvider(
                create: (context) => AuthenticationBloc(
                  authenticationRepository:
                      context.read<BlockchainAuthenticationRepository>(),
                  userRepository: context.read<UserRepository>(),
                ),
                child: const AppView(),
              ),
            );
          } else {
            return MaterialApp(
              builder: (context, child) {
                return const SplashPage();
              },
            );
          }
        });
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  AppViewState createState() => AppViewState();
}

class AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  HomePage.route(),
                  (route) => false,
                );
                break;
              case AuthenticationStatus.unauthenticated:
                _navigator.pushAndRemoveUntil<void>(
                  LoginPage.route(),
                  (route) => false,
                );
                break;
              default:
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}

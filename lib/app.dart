import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:blockchain_authentication_repository/blockchain_authentication_repository.dart';
import 'package:blockchain_repository/blockchain_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_spaces/authentication/bloc/authentication_bloc.dart';
import 'package:multi_spaces/bucket/presentation/screens/bucket_page.dart';
import 'package:multi_spaces/core/blockchain_repository/internal_blockchain_repository.dart';
import 'package:multi_spaces/core/constants.dart';
import 'package:multi_spaces/core/theme/cubit/theme_cubit.dart';
import 'package:multi_spaces/login/screens/login/login_page.dart';
import 'package:multi_spaces/multi_spaces/repository/multi_spaces_repository.dart';
import 'package:multi_spaces/multi_spaces/screens/multi_spaces_page.dart';
import 'package:multi_spaces/payment/bloc/payment_bloc.dart';
import 'package:multi_spaces/space/screens/space_page.dart';
import 'package:multi_spaces/splash/splash.dart';
import 'package:multi_spaces/transaction/bloc/transaction_bloc.dart';
import 'package:provider/provider.dart';
import 'package:user_repository/user_repository.dart';
import 'package:web3dart/web3dart.dart';

import 'multi_spaces/bloc/multi_spaces_bloc.dart';
import 'payment/repository/payment_repository.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
    Uri? appLink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<InternalBlockchainRepository>(
          create: (context) => InternalBlockchainRepository(),
        ),
        RepositoryProvider<BlockchainRepository>(
          create: (context) => BlockchainRepository(),
        ),
        RepositoryProvider<BlockchainAuthenticationRepository>(
          create: (context) => BlockchainAuthenticationRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(),
        ),
        RepositoryProvider<MultiSpacesRepository>(
          create: (context) => MultiSpacesRepository(),
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(
            create: (context) => AuthenticationBloc(
              authenticationRepository:
                  context.read<BlockchainAuthenticationRepository>(),
              userRepository: context.read<UserRepository>(),
            ),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final StreamSubscription<Uri> _linkSubscription;
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState!;

  _AppViewState() {
    final appLinks = AppLinks();

    // Handle link when app is in warm state (front or background)
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
      print('onAppLink: $uri');
      print('onAppLink: ${uri.path}');
      _navigator.pushNamedAndRemoveUntil<void>(
        uri.path,
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  void dispose() {
    _linkSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color.fromRGBO(0, 200, 83, 1.0),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color.fromRGBO(0, 200, 83, 1.0),
        useMaterial3: true,
      ),
      themeMode: Provider.of<ThemeCubit>(context).state,
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return MultiBlocListener(
          listeners: [
            BlocListener<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) {
                switch (state.status) {
                  case AuthenticationStatus.authenticated:
                    _navigator.pushNamedAndRemoveUntil<void>(
                      MultiSpacesPage.routeName,
                      (Route<dynamic> route) => false,
                    );
                    break;
                  case AuthenticationStatus.unauthenticated:
                    _navigator.pushNamedAndRemoveUntil<void>(
                      LoginPage.routeName,
                      (Route<dynamic> route) => false,
                    );
                    break;
                  default:
                    break;
                }
              },
            ),
          ],
          child: child ?? const SplashPage(),
        );
      },
      home: const Scaffold(
        body: SplashPage(),
      ),
      routes: <String, WidgetBuilder>{
        LoginPage.routeName: (context) => const LoginPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.contains(MultiSpacesPage.routeName) == true) {
          if (settings.name == MultiSpacesPage.routeName) {
            return MultiSpacesPage.route();
          } else {
            final parts = settings.name?.split("/").toList();
            final externalBucket = parts!.last;
            return MultiSpacesPage.route(
              externalBucket: EthereumAddress.fromHex(
                externalBucket,
              ),
            );
          }
        } else if (settings.name == BucketPage.routeName) {
          final args = settings.arguments as BucketPageArguments;
          return MaterialPageRoute<BucketPage>(
            builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => TransactionBloc(),
                  ),
                ],
                child: BucketPage(
                  bucketName: args.bucketName,
                  bucketAddress: args.bucketAddress,
                  ownerName: args.ownerName,
                  ownerAddress: args.ownerAddress,
                  isExternal: args.isExternal,
                ),
              );
            },
          );
        } else if (settings.name == SpacePage.routeName) {
          final args = settings.arguments as SpacePageArguments;
          return MaterialPageRoute<SpacePage>(
            builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => MultiSpacesBloc(
                      multiSpacesRepository:
                          RepositoryProvider.of<MultiSpacesRepository>(
                        context,
                      ),
                      authenticationBloc:
                          BlocProvider.of<AuthenticationBloc>(context),
                    ),
                  ),
                  BlocProvider(
                    create: (context) => TransactionBloc(),
                  ),
                  BlocProvider(
                    lazy: false,
                    create: (context) {
                      final paymentRepository = PaymentRepository(
                        args.paymentManagerAddress.hex,
                      );
                      return PaymentBloc(
                        paymentRepository: paymentRepository,
                        transactionBloc: BlocProvider.of<TransactionBloc>(
                          context,
                        ),
                      );
                    },
                  ),
                ],
                child: SpacePage(
                  spaceAddress: args.spaceAddress,
                  paymentManagerAddress: args.paymentManagerAddress,
                  externalBucketToAdd: args.externalBucketToAdd,
                ),
              );
            },
          );
        } else {
          return SplashPage.route();
        }
      },
      onUnknownRoute: (settings) {
        print(settings);
        return SplashPage.route();
      },
    );
  }
}

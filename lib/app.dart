import 'package:blockchain_authentication_repository/blockchain_authentication_repository.dart';
import 'package:blockchain_repository/blockchain_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_spaces/authentication/bloc/authentication_bloc.dart';
import 'package:multi_spaces/core/blockchain_repository/internal_blockchain_repository.dart';
import 'package:multi_spaces/core/theme/cubit/theme_cubit.dart';
import 'package:multi_spaces/login/screens/login/login_page.dart';
import 'package:multi_spaces/multi_spaces/screens/multi_spaces_page.dart';
import 'package:multi_spaces/splash/splash.dart';
import 'package:provider/provider.dart';
import 'package:user_repository/user_repository.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
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
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState!;

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
                    _navigator.pushAndRemoveUntil<void>(
                      MultiSpacesPage.route(),
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
            ),
          ],
          child: child ?? const SplashPage(),
        );
      },
      home: const Scaffold(
        body: SplashPage(),
      ),
      onGenerateRoute: (bla) {
        print(bla);
        return SplashPage.route();
      },
    );
  }
}

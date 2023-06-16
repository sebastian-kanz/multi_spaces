import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_spaces/multi_spaces/bloc/multi_spaces_bloc.dart';
import 'package:multi_spaces/multi_spaces/repository/multi_spaces_repository.dart';
import 'package:multi_spaces/payment/bloc/payment_bloc.dart';
import 'package:multi_spaces/payment/repository/payment_repository.dart';
import 'package:multi_spaces/space/screens/space_page.dart';
import 'package:multi_spaces/core/widgets/nav_drawer.dart';
import 'package:multi_spaces/transaction/bloc/transaction_bloc.dart';
import 'package:provider/provider.dart';

import '../../authentication/authentication.dart';

class MultiSpacesPage extends StatelessWidget {
  const MultiSpacesPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (context) => MultiSpacesBloc(
          multiSpacesRepository: context.read<MultiSpacesRepository>(),
          authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
        )..add(const MultiSpacesStarted()),
        child: const MultiSpacesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final multiSpacesBloc = Provider.of<MultiSpacesBloc>(
      context,
    );
    return BlocConsumer<MultiSpacesBloc, MultiSpaceState>(
      listener: (context, state) {
        if (state.runtimeType == MultiSpacesReady) {
          Navigator.of(context).pushAndRemoveUntil<void>(
            MaterialPageRoute<SpacePage>(
              builder: (_) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                      value: multiSpacesBloc,
                    ),
                    BlocProvider(
                      create: (context) => TransactionBloc(),
                    ),
                    BlocProvider(
                      lazy: false,
                      create: (context) {
                        final providers = Provider.of<List<BlockchainProvider>>(
                          context,
                          listen: false,
                        );
                        final multiSpacesState =
                            BlocProvider.of<MultiSpacesBloc>(
                          context,
                        ).state as MultiSpacesReady;
                        final paymentRepository = PaymentRepository(providers,
                            multiSpacesState.paymentManagerAddress.hex);
                        return PaymentBloc(
                          paymentRepository: paymentRepository,
                          transactionBloc: BlocProvider.of<TransactionBloc>(
                            context,
                          ),
                        );
                      },
                    ),
                  ],
                  child: const SpacePage(),
                );
              },
            ),
            (route) => false,
          );
        }
      },
      buildWhen: (previous, current) {
        return current.runtimeType == NoSpaceExisting;
      },
      builder: (context, state) {
        if (state.runtimeType == NoSpaceExisting) {
          return Scaffold(
            drawer: const NavDrawer(hidePayment: true),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.fill,
                            child: Image.asset(
                              'assets/images/undraw_my_files_swob.png',
                            ),
                          ),
                          // Image.asset(
                          //   'assets/images/undraw_my_files_swob.png',
                          //   fit: BoxFit.fitWidth,
                          // ),
                          // Text("Add image and name here"),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Flexible(
                          child: Text(
                            "Add image and description of what a space is and how it works here",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Builder(
              builder: (context) {
                if (state.runtimeType == NoSpaceExisting) {
                  return FloatingActionButton.extended(
                    elevation: 4.0,
                    icon: const Icon(Icons.add),
                    label: const Text('Create a Space'),
                    onPressed: () {
                      multiSpacesBloc.add(const CreateSpacePressed());
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
            bottomNavigationBar: BottomAppBar(
              color: Theme.of(context).bottomAppBarTheme.color,
              child: SizedBox(
                height: 60.0,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Builder(
                      builder: (context) {
                        return IconButton(
                          // padding: EdgeInsets.all(35),
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

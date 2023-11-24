import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_spaces/authentication/bloc/authentication_bloc.dart';
import 'package:multi_spaces/core/theme/cubit/theme_cubit.dart';
import 'package:multi_spaces/payment/bloc/payment_bloc.dart';
import 'package:provider/provider.dart';

class NavDrawer extends StatelessWidget {
  final bool hidePayment;
  const NavDrawer({
    super.key,
    required this.hidePayment,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              // image: DecorationImage(
              //     fit: BoxFit.fill,
              //     image: AssetImage('assets/images/cover.jpg'))
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Side menu',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                Builder(
                  builder: (context) {
                    if (hidePayment) {
                      return Container();
                    } else {
                      return BlocBuilder<PaymentBloc, PaymentState>(
                        builder: (context, state) {
                          Widget freeBuckets = const Text("loading...");
                          if (state.runtimeType == PaymentInitialized) {
                            if ((state as PaymentInitialized)
                                .addBucketIsFreeOfCharge) {
                              freeBuckets = const Text("∞");
                            } else {
                              print(state);
                              freeBuckets = Text(
                                "${state.addBucketVouchers + (state.balance ~/ state.defaultPayment)}",
                              );
                            }
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Free Buckets left:"),
                              freeBuckets
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Toggle dark / light mode'),
            onTap: () => {
              context.read<ThemeCubit>().toggle(),
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => {
              context
                  .read<AuthenticationBloc>()
                  .add(AuthenticationLogoutRequested())
            },
          ),
        ],
      ),
    );
  }
}

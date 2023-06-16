import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multi_spaces/bucket/presentation/screens/bucket_page.dart';
import 'package:multi_spaces/multi_spaces/bloc/multi_spaces_bloc.dart';
import 'package:multi_spaces/payment/bloc/payment_bloc.dart';
import 'package:multi_spaces/space/bloc/space_bloc.dart';
import 'package:multi_spaces/space/repository/space_repository.dart';
import 'package:multi_spaces/core/widgets/nav_drawer.dart';
import 'package:multi_spaces/transaction/bloc/transaction_bloc.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class SpacePage extends StatelessWidget {
  const SpacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) {
            final providers =
                Provider.of<List<BlockchainProvider>>(context, listen: false);
            final multiSpacesState = BlocProvider.of<MultiSpacesBloc>(
              context,
            ).state as MultiSpacesReady;
            final address = multiSpacesState.spaceAddress.hex;
            final spaceRepository = SpaceRepository(providers, address);
            return SpaceBloc(
              spaceRepository: spaceRepository,
              transactionBloc: BlocProvider.of<TransactionBloc>(
                context,
              ),
              paymentBloc: BlocProvider.of<PaymentBloc>(
                context,
              ),
            )..add(const InitSpaceEvent());
          },
        ),
      ],
      child: const SpacePageView(),
    );
  }
}

class SpacePageView extends StatefulWidget {
  const SpacePageView({super.key});

  @override
  _SpacePageViewState createState() => _SpacePageViewState();
}

class _SpacePageViewState extends State<SpacePageView> {
  final TextEditingController _textFieldController = TextEditingController();
  String newBucketName = "";

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SpaceBloc, SpaceState>(
      listener: (context, state) {
        if (state.runtimeType == SpaceInitialized) {
          BlocProvider.of<PaymentBloc>(context).add(
            LoadPaymentEvent(
              account: context.read<SpaceBloc>().state.address,
            ),
          );
        } else if (state.runtimeType == SpaceError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text((state as SpaceError).error.toString())),
            );
          BlocProvider.of<SpaceBloc>(context).add(const InitSpaceEvent());
        }
      },
      builder: (context, state) => Scaffold(
        drawer: const NavDrawer(hidePayment: false),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).splashColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          // child: const FlutterLogo(
                          //   size: 80.0,
                          // ),

                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 100,
                            width: 100,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        GradientText(
                          'MultiSpaces',
                          style: const TextStyle(
                            fontSize: 20.0,
                          ),
                          colors: [
                            // Color.fromARGB(255, 216, 68, 27),
                            Color.fromARGB(255, 205, 27, 119),
                            // Color.fromARGB(255, 10, 92, 151),
                            Color.fromARGB(255, 81, 178, 108),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          child: BlocBuilder<PaymentBloc, PaymentState>(
                            builder: (context, state) {
                              Widget freeBuckets = const Text("loading...");
                              if (state.runtimeType == PaymentInitialized) {
                                if ((state as PaymentInitialized)
                                    .addBucketIsFreeOfCharge) {
                                  freeBuckets = const Text("∞");
                                } else {
                                  freeBuckets = Text(
                                    "${state.addBucketVouchers + state.balance ~/ state.defaultPayment}",
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
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        if (state.transactionHashes.isNotEmpty) {
                          return const LinearProgressIndicator();
                        }
                        return Container();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: BlocBuilder<SpaceBloc, SpaceState>(
                builder: (context, state) {
                  if (state.runtimeType == SpaceInitialized) {
                    return RefreshIndicator(
                      onRefresh: () async => Provider.of<SpaceBloc>(
                        context,
                        listen: false,
                      ).add(
                        const GetBucketsEvent(),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 4),
                        scrollDirection: Axis.vertical,
                        itemCount: (state as SpaceInitialized).buckets.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: Slidable(
                              key: const ValueKey(1),
                              groupTag: '0',
                              startActionPane: ActionPane(
                                motion: const BehindMotion(),
                                children: [
                                  SlideAction(
                                    color: Colors.green,
                                    icon: Icons.share,
                                    fct: (context) => print("Share"),
                                    label: 'Share',
                                  ),
                                ],
                              ),
                              endActionPane: ActionPane(
                                motion: const BehindMotion(),
                                children: [
                                  SlideAction(
                                    color: Colors.blue,
                                    icon: Icons.change_circle,
                                    fct: (_) {
                                      _displayTextInputDialog(context, 'Rename',
                                          (String name) {
                                        Provider.of<SpaceBloc>(
                                          context,
                                          listen: false,
                                        ).add(
                                          RenameBucketEvent(
                                            state.buckets[index].name,
                                            newBucketName,
                                          ),
                                        );
                                      });
                                    },
                                    label: 'Rename',
                                  ),
                                  SlideAction(
                                    color: Colors.red,
                                    icon: Icons.delete_forever,
                                    fct: (_) {
                                      context.read<SpaceBloc>().add(
                                            RemoveBucketEvent(
                                              state.buckets[index].name,
                                            ),
                                          );
                                    },
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              child: SpaceListTile(
                                spaceState: state,
                                index: index,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton.extended(
          elevation: 4.0,
          icon: const Icon(Icons.add),
          label: const Text('Add a Bucket'),
          onPressed: () =>
              _displayTextInputDialog(context, 'Create', (String name) {
            context.read<SpaceBloc>().add(
                  CreateBucketEvent(newBucketName),
                );
          }),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).bottomAppBarColor,
          child: SizedBox(
            height: 60.0,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Builder(
                  builder: (context) {
                    return IconButton(
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
      ),
    );
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, String label, Function fct) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bucket Name'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                newBucketName = value;
              });
            },
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Enter a name"),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              child: Text(label),
              onPressed: () {
                fct(newBucketName);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class SpaceListTile extends StatelessWidget {
  const SpaceListTile({
    Key? key,
    required this.spaceState,
    required this.index,
  }) : super(key: key);

  final SpaceInitialized spaceState;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: spaceState.buckets[index].isExternal
          ? const Icon(Icons.travel_explore)
          : const Icon(Icons.public),
      trailing: const Icon(Icons.keyboard_arrow_right),
      title: Text(spaceState.buckets[index].name),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<SpacePage>(
          builder: (_) {
            return MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: Provider.of<MultiSpacesBloc>(
                    context,
                  ),
                ),
                BlocProvider.value(
                  value: Provider.of<SpaceBloc>(
                    context,
                  ),
                ),
                BlocProvider.value(
                  value: Provider.of<TransactionBloc>(
                    context,
                  ),
                ),
              ],
              child: BucketPage(
                bucketName: spaceState.buckets[index].name,
                bucketAddress: spaceState.buckets[index].address,
                ownerName: spaceState.owner.name,
                ownerAddress: spaceState.owner.adr,
              ),
            );
          },
        ),
      ),
      subtitle: Builder(
        builder: (context) {
          final count = (spaceState.buckets[index].elementCount).toString();
          final diff =
              DateTime.now().difference(spaceState.buckets[index].creation);
          var creationWidget = Text("${diff.inDays} day(s) ago");
          if (diff.inHours == 0 && diff.inMinutes == 0) {
            creationWidget = const Text("Just now");
          } else if (diff.inHours == 0 && diff.inMinutes > 0) {
            creationWidget = Text("${diff.inMinutes} minutes(s) ago");
          } else if (diff.inDays == 0) {
            creationWidget = Text("${diff.inHours} hour(s) ago");
          }
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              creationWidget,
              Text("$count items"),
            ],
          );
        },
      ),
    );
  }
}

class SlideAction extends StatelessWidget {
  const SlideAction({
    Key? key,
    required this.color,
    required this.icon,
    required this.label,
    required this.fct,
    this.flex = 1,
  }) : super(key: key);

  final Color color;
  final IconData icon;
  final int flex;
  final Function fct;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      flex: flex,
      backgroundColor: color,
      foregroundColor: Colors.white,
      onPressed: (BuildContext context) => fct(context),
      icon: icon,
      label: label,
    );
  }
}

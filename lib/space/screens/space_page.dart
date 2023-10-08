import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:web3dart/web3dart.dart';

class SpacePage extends StatelessWidget {
  const SpacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) {
            final multiSpacesState = BlocProvider.of<MultiSpacesBloc>(
              context,
            ).state as MultiSpacesReady;
            final address = multiSpacesState.spaceAddress.hex;
            final spaceRepository = SpaceRepository(address);
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
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: GradientText(
                        'MultiSpaces',
                        textScaleFactor: 2.5,
                        colors: [
                          // Color.fromARGB(255, 216, 68, 27),
                          Color.fromARGB(255, 205, 27, 119),
                          // Color.fromARGB(255, 10, 92, 151),
                          Color.fromARGB(255, 81, 178, 108),
                        ],
                      ),
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
              flex: 4,
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
                          final bucketLink =
                              "multispaces://www.multi-spaces.eth/buckets/add/${state.buckets[index].address}";
                          return Card(
                            child: Slidable(
                              key: const ValueKey(1),
                              groupTag: '0',
                              startActionPane: ActionPane(
                                motion: const BehindMotion(),
                                children: [
                                  SlideAction(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    icon: Icons.share,
                                    fct: (context) => showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            children: [
                                              QrImageView(
                                                data: bucketLink,
                                                padding:
                                                    const EdgeInsets.all(80),
                                                eyeStyle: QrEyeStyle(
                                                  eyeShape: QrEyeShape.square,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                dataModuleStyle:
                                                    QrDataModuleStyle(
                                                  dataModuleShape:
                                                      QrDataModuleShape.square,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              IconButton(
                                                icon: const Icon(Icons.share),
                                                onPressed: () {
                                                  Share.share(
                                                    bucketLink,
                                                  );
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    label: 'Share',
                                  ),
                                ],
                              ),
                              endActionPane: ActionPane(
                                motion: const BehindMotion(),
                                children: [
                                  SlideAction(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
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
                                    foregroundColor:
                                        Theme.of(context).colorScheme.tertiary,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
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
        floatingActionButton: InkWell(
          splashColor: Colors.blue,
          onLongPress: () {
            context.read<SpaceBloc>().add(
                  AddExternalBucketEvent(
                    "external${Random.secure().nextInt(999999)}",
                    EthereumAddress.fromHex(
                      "0x247272ea3e248055ddc7770b8d28673348fccd1a",
                    ),
                  ),
                );
          },
          child: FloatingActionButton.extended(
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
          actionsAlignment: MainAxisAlignment.spaceBetween,
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
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
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
            print(spaceState.buckets[index].address.hex);
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
                isExternal: spaceState.buckets[index].isExternal,
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
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    required this.fct,
    this.flex = 1,
  }) : super(key: key);

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final int flex;
  final Function fct;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      flex: flex,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      onPressed: (BuildContext context) => fct(context),
      icon: icon,
      label: label,
    );
  }
}

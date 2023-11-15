import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multi_spaces/bucket/presentation/screens/bucket_page.dart';
import 'package:multi_spaces/core/utils/input_dialog.dart';
import 'package:multi_spaces/core/widgets/slide_action.dart';
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

class SpacePageArguments {
  final EthereumAddress spaceAddress;
  final EthereumAddress paymentManagerAddress;
  final EthereumAddress? externalBucketToAdd;

  SpacePageArguments(
    this.spaceAddress,
    this.paymentManagerAddress, {
    this.externalBucketToAdd,
  });
}

class SpacePage extends StatelessWidget {
  final EthereumAddress spaceAddress;
  final EthereumAddress paymentManagerAddress;
  final EthereumAddress? externalBucketToAdd;

  const SpacePage({
    super.key,
    required this.spaceAddress,
    required this.paymentManagerAddress,
    this.externalBucketToAdd,
  });

  static const routeName = '/space';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) {
            final spaceRepository = SpaceRepository(spaceAddress.hex);
            return SpaceBloc(
              spaceRepository: spaceRepository,
              transactionBloc: BlocProvider.of<TransactionBloc>(
                context,
              ),
              paymentBloc: BlocProvider.of<PaymentBloc>(
                context,
              ),
            )..add(
                InitSpaceEvent(
                  externalBucketToAdd: externalBucketToAdd,
                ),
              );
          },
        ),
      ],
      child: SpacePageView(
        spaceAddress: spaceAddress,
        paymentManagerAddress: paymentManagerAddress,
      ),
    );
  }
}

class SpacePageView extends StatefulWidget {
  final EthereumAddress spaceAddress;
  final EthereumAddress paymentManagerAddress;
  const SpacePageView({
    super.key,
    required this.spaceAddress,
    required this.paymentManagerAddress,
  });

  @override
  SpacePageViewState createState() => SpacePageViewState();
}

class SpacePageViewState extends State<SpacePageView> {
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

          if ((state as SpaceInitialized).externalBucketToAdd != null) {
            if (state.buckets.indexWhere((element) =>
                    element.address.hex == state.externalBucketToAdd?.hex) ==
                -1) {
              _showAddExternalButtonModal(context, state.externalBucketToAdd!);
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text("Bucket already exists"),
                  ),
                );
            }
          }
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
            SizedBox(
              height: 200,
              child: Container(
                color: Theme.of(context).splashColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: GradientText(
                        'MultiSpaces',
                        textScaleFactor: 2.5,
                        colors: const [
                          Color.fromARGB(255, 205, 27, 119),
                          Color.fromARGB(255, 81, 178, 108),
                        ],
                      ),
                    ),
                    BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        if (state.waitingTransactions.isNotEmpty) {
                          final description =
                              state.waitingTransactions.first.description;
                          if (description == null) {
                            return const LinearProgressIndicator();
                          }
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                description,
                                textScaleFactor: 0.8,
                              ),
                              const LinearProgressIndicator(),
                            ],
                          );
                        }
                        return Container();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: BlocBuilder<SpaceBloc, SpaceState>(
                builder: (context, state) {
                  if (state.runtimeType == SpaceInitialized) {
                    if ((state as SpaceInitialized).buckets.isEmpty) {
                      return SizedBox(
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Looks empty here...",
                              textScaleFactor: 1.3,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Click on the button below to add a Bucket.",
                            ),
                          ],
                        ),
                      );
                    }

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
                          return _getBucketCard(context, index, state);
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
            // TODO:
            print("Open link for new bucket");
          },
          child: FloatingActionButton.extended(
            elevation: 4.0,
            icon: const Icon(Icons.add),
            label: const Text('Add a Bucket'),
            onPressed: () async {
              await displayTextInputDialog(
                context,
                'Create Bucket',
                'Create',
                (String name) {
                  context.read<SpaceBloc>().add(
                        CreateBucketEvent(name),
                      );
                },
              );
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text("Please confirm transaction."),
                  ),
                );
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
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

  Future<void> _showAddExternalButtonModal(
      BuildContext context, EthereumAddress externalBucketToAdd) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text(
                "Adding external bucket to your space:",
                textScaleFactor: 1.4,
              ),
              const SizedBox(height: 40),
              Text(externalBucketToAdd.hex),
              const SizedBox(height: 40),
              TextField(
                onChanged: (value) {
                  setState(() {
                    newBucketName = value;
                  });
                },
                controller: _textFieldController,
                decoration: const InputDecoration(hintText: "Enter a name"),
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  context.read<SpaceBloc>().add(
                        AddExternalBucketEvent(
                          newBucketName.isEmpty
                              ? "external${Random.secure().nextInt(999999)}"
                              : newBucketName,
                          externalBucketToAdd,
                        ),
                      );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getBucketCard(
    BuildContext context,
    int index,
    SpaceInitialized state,
  ) {
    final bucketLink =
        "multispaces://www.multi-spaces.eth/multispaces/${state.buckets[index].address.hex}";
    return Card(
      child: Slidable(
        key: const ValueKey(1),
        groupTag: '0',
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlideAction(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
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
                          padding: const EdgeInsets.all(80),
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Theme.of(context).colorScheme.primary,
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
              foregroundColor: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              icon: Icons.change_circle,
              fct: (_) {
                displayTextInputDialog(
                  context,
                  'Rename Bucket',
                  'Rename',
                  (String name) {
                    Provider.of<SpaceBloc>(
                      context,
                      listen: false,
                    ).add(
                      RenameBucketEvent(
                        state.buckets[index].name,
                        name,
                      ),
                    );
                  },
                  initialValue: state.buckets[index].name,
                );
              },
              label: 'Rename',
            ),
            SlideAction(
              foregroundColor: Theme.of(context).colorScheme.tertiary,
              backgroundColor: Theme.of(context).colorScheme.onTertiary,
              icon: Icons.delete_forever,
              fct: (_) async {
                await displayConfirmDialog(
                  context,
                  "Are you sure?",
                  "Delete",
                  () => context.read<SpaceBloc>().add(
                        RemoveBucketEvent(
                          state.buckets[index].name,
                        ),
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
      leading: SizedBox(
        height: double.infinity,
        child: spaceState.buckets[index].isExternal
            ? const Icon(Icons.add_link)
            : const Icon(Icons.source),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right),
      title: Text(
        spaceState.buckets[index].name,
        textScaleFactor: 1.2,
      ),
      onTap: () => Navigator.pushNamed(
        context,
        BucketPage.routeName,
        arguments: BucketPageArguments(
          spaceState.buckets[index].name,
          spaceState.buckets[index].address,
          spaceState.owner.name,
          spaceState.owner.adr,
          spaceState.buckets[index].isExternal,
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  creationWidget,
                  count == "1" ? Text("$count item") : Text("$count items"),
                ],
              ),
              spaceState.buckets[index].isExternal
                  ? const Text("external")
                  : const Text("")
            ],
          );
        },
      ),
    );
  }
}

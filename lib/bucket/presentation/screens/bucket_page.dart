import 'dart:io';
import 'dart:typed_data';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:crust_ipfs_api/crust_ipfs_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_storage_repository/file_storage_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:ipfs_repository/ipfs_repository.dart';
import 'package:key_repository/key_repository.dart';
import 'package:multi_spaces/bucket/data/repository/bucket_repository_impl.dart';
import 'package:multi_spaces/bucket/data/repository/container_repository_impl.dart';
import 'package:multi_spaces/bucket/data/repository/data_repository_impl.dart';
import 'package:multi_spaces/bucket/data/repository/element_repository_impl.dart';
import 'package:multi_spaces/bucket/data/repository/history_repository_impl.dart';
import 'package:multi_spaces/bucket/data/repository/ipfs_vault_repository_impl.dart';
import 'package:multi_spaces/bucket/data/repository/meta_repository_impl.dart';
import 'package:multi_spaces/bucket/data/repository/participant_repository_impl.dart';
import 'package:multi_spaces/bucket/domain/usecase/accept_participation_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/add_device_participation_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/check_device_participation_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/check_provider_participation_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/create_element_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/create_keys_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/get_full_elements_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/get_requests_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/keys_existing_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_bucket_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_element_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_key_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_participation_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_request_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/request_participation_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/sync_elements_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/sync_history_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/update_element_usecase.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/error/error.dart';
import 'package:multi_spaces/core/utils/input_dialog.dart';
import 'package:multi_spaces/core/widgets/slide_action.dart';
import 'package:multi_spaces/transaction/bloc/transaction_bloc.dart';
import 'package:web3dart/web3dart.dart';
import '../../../core/utils/string.utils.dart';
import '../bloc/bucket_bloc.dart';
import 'package:multi_spaces/core/contracts/Bucket.g.dart';
import 'package:badges/badges.dart' as badges;
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';

class BucketPageArguments {
  final String bucketName;
  final EthereumAddress bucketAddress;
  final String ownerName;
  final EthereumAddress ownerAddress;
  final bool isExternal;

  BucketPageArguments(
    this.bucketName,
    this.bucketAddress,
    this.ownerName,
    this.ownerAddress,
    this.isExternal,
  );
}

class BucketBlocUseCases {
  final ListenBucketEventsUseCase listenElementsInBucketUseCase;
  final GetFullElementsUseCase getFullElementsUseCase;
  final SyncElementsUseCase syncElementsUseCase;
  final SyncHistoryUseCase syncHistoryUseCase;
  final CreateElementUseCase createElementUseCase;
  final CreateKeysUseCase createKeysUseCase;
  final ListenKeyEventsUseCase listenKeyEventsUseCase;
  final CheckDeviceParticipationUseCase checkDeviceParticipationUseCase;
  final CheckProviderParticipationUseCase checkProviderParticipationUseCase;
  final RequestParticipationUseCase requestParticipationUseCase;
  final AcceptParticipationUseCase acceptParticipationUseCase;
  final GetActiveRequestsUseCase getActiveRequestsUseCase;
  final AddDeviceParticipationUseCase addDeviceParticipationUseCase;
  final ListenElementUseCase listenElementUseCase;
  final ListenParticipationEventsUseCase listenParticipationEventsUseCase;
  final ListenRequestEventsUseCase listenRequestEventsUseCase;
  final KeysExistingUseCase keysExistingUseCase;
  final UpdateElementUseCase updateElementUseCase;

  BucketBlocUseCases(
    this.listenElementsInBucketUseCase,
    this.getFullElementsUseCase,
    this.syncElementsUseCase,
    this.syncHistoryUseCase,
    this.createElementUseCase,
    this.createKeysUseCase,
    this.listenKeyEventsUseCase,
    this.checkDeviceParticipationUseCase,
    this.checkProviderParticipationUseCase,
    this.requestParticipationUseCase,
    this.acceptParticipationUseCase,
    this.getActiveRequestsUseCase,
    this.addDeviceParticipationUseCase,
    this.listenElementUseCase,
    this.listenParticipationEventsUseCase,
    this.listenRequestEventsUseCase,
    this.keysExistingUseCase,
    this.updateElementUseCase,
  );
}

class BucketPage extends StatelessWidget {
  final String bucketName;
  final EthereumAddress bucketAddress;
  final String ownerName;
  final EthereumAddress ownerAddress;
  final bool isExternal;

  static const routeName = '/bucket';

  const BucketPage({
    super.key,
    required this.bucketName,
    required this.bucketAddress,
    required this.ownerName,
    required this.ownerAddress,
    required this.isExternal,
  });

  Future<BucketBlocUseCases> _setup(BuildContext context) async {
    final bucketRepository = BucketRepositoryImpl(
      bucketAddress.hex,
    );
    final listenElementsInBucketUseCase =
        ListenBucketEventsUseCase(bucketRepository);
    final bucket = Bucket(
      address: EthereumAddress.fromHex(bucketAddress.hex),
      client: MultiSpaceClient().client,
      chainId: Env.chain_id,
    );
    final elementRepository = ElementRepositoryImpl(bucket);
    await elementRepository.initialize(bucketAddress.hex);
    final ipfsRepository = IpfsRepository(apis: [
      CrustIpfsApi(
        address: BlockchainProviderManager().internalProvider.getAccount().hex,
        signature: await BlockchainProviderManager().internalProvider.sign(
              message:
                  BlockchainProviderManager().internalProvider.getAccount().hex,
            ),
        client: Client(),
      ),
    ]);

    final keyRepository = KeyRepository(
      ownerName,
      bucketAddress.hex,
      BlockchainProviderManager().internalProvider.getPrivateKeyHex(),
    );
    final ipfsVaultRepository = IPFSVaultRepositoryImpl(
      ipfsRepository,
      keyRepository,
      bucket,
      ownerAddress,
    );
    final metaRepository = MetaRepositoryImpl(ipfsVaultRepository);
    await metaRepository.initialize(bucketAddress.hex);
    final fileStorageRepository = FileStorageRepository(ownerName, bucketName);
    final dataRepository = DataRepositoryImpl(
      ipfsVaultRepository,
      fileStorageRepository,
    );
    final containerRepository = ContainerRepositoryImpl(ipfsRepository);
    await containerRepository.initialize(bucketAddress.hex);
    final getFullElementsUseCase = GetFullElementsUseCase(
      elementRepository,
      metaRepository,
      dataRepository,
      containerRepository,
    );
    final historyRepository = HistoryRepositoryImpl(bucket);
    await historyRepository.initialize(bucketAddress.hex);
    final syncElementsUseCase = SyncElementsUseCase(
      historyRepository,
      metaRepository,
      dataRepository,
      containerRepository,
      elementRepository,
    );
    final syncHistoryUseCase = SyncHistoryUseCase(historyRepository);
    final participantManagerContractAddress = await bucket.participantManager();
    final participantRepository = ParticipantRepositoryImpl(
      participantManagerContractAddress.hex,
    );
    final createElementUseCase = CreateElementUseCase(
      bucketRepository,
      elementRepository,
      metaRepository,
      dataRepository,
      containerRepository,
      participantRepository,
      ipfsVaultRepository,
    );
    final createKeysUseCase = CreateKeysUseCase(
      bucketRepository,
      participantRepository,
      ipfsVaultRepository,
    );
    final listenKeyEventsUseCase = ListenKeyEventsUseCase(bucketRepository);
    final checkDeviceParticipationUseCase = CheckDeviceParticipationUseCase(
      participantRepository,
      ipfsVaultRepository,
    );
    final checkProviderParticipationUseCase =
        CheckProviderParticipationUseCase(participantRepository);
    final requestParticipationUseCase =
        RequestParticipationUseCase(bucketRepository, participantRepository);
    final acceptParticipationUseCase = AcceptParticipationUseCase(
      bucketRepository,
      ipfsVaultRepository,
      participantRepository,
    );
    final getActiveRequestsUseCase =
        GetActiveRequestsUseCase(participantRepository);
    final addDeviceParticipationUseCase = AddDeviceParticipationUseCase(
      bucketRepository,
      ipfsVaultRepository,
      participantRepository,
    );
    final listenElementUseCase = ListenElementUseCase(elementRepository);
    final listenParticipationEventsUseCase =
        ListenParticipationEventsUseCase(participantRepository);
    final listenRequestEventsUseCase =
        ListenRequestEventsUseCase(participantRepository);
    final keysExistingUseCase = KeysExistingUseCase(bucketRepository);
    final updateElementUseCase = UpdateElementUseCase(
      elementRepository,
      metaRepository,
      containerRepository,
    );
    return BucketBlocUseCases(
      listenElementsInBucketUseCase,
      getFullElementsUseCase,
      syncElementsUseCase,
      syncHistoryUseCase,
      createElementUseCase,
      createKeysUseCase,
      listenKeyEventsUseCase,
      checkDeviceParticipationUseCase,
      checkProviderParticipationUseCase,
      requestParticipationUseCase,
      acceptParticipationUseCase,
      getActiveRequestsUseCase,
      addDeviceParticipationUseCase,
      listenElementUseCase,
      listenParticipationEventsUseCase,
      listenRequestEventsUseCase,
      keysExistingUseCase,
      updateElementUseCase,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BucketBlocUseCases>(
        future: _setup(context),
        builder: (context, AsyncSnapshot<BucketBlocUseCases> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return const ErrorContainer();
          } else if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text("Bucket loading..."),
                  ],
                ),
              ),
            );
          } else {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  lazy: false,
                  create: (_) {
                    return BucketBloc(
                      listenBucketEventsUseCase:
                          snapshot.data!.listenElementsInBucketUseCase,
                      getFullElementsUseCase:
                          snapshot.data!.getFullElementsUseCase,
                      syncElementsUseCase: snapshot.data!.syncElementsUseCase,
                      syncHistoryUseCase: snapshot.data!.syncHistoryUseCase,
                      createElementUseCase: snapshot.data!.createElementUseCase,
                      createKeysUseCase: snapshot.data!.createKeysUseCase,
                      listenKeyEventsUseCase:
                          snapshot.data!.listenKeyEventsUseCase,
                      checkDeviceParticipationUseCase:
                          snapshot.data!.checkDeviceParticipationUseCase,
                      checkProviderParticipationUseCase:
                          snapshot.data!.checkProviderParticipationUseCase,
                      requestParticipationUseCase:
                          snapshot.data!.requestParticipationUseCase,
                      acceptParticipationUseCase:
                          snapshot.data!.acceptParticipationUseCase,
                      getActiveRequestsUseCase:
                          snapshot.data!.getActiveRequestsUseCase,
                      addDeviceParticipationUseCase:
                          snapshot.data!.addDeviceParticipationUseCase,
                      listenElementUseCase: snapshot.data!.listenElementUseCase,
                      listenParticipationEventsUseCase:
                          snapshot.data!.listenParticipationEventsUseCase,
                      listenRequestEventsUseCase:
                          snapshot.data!.listenRequestEventsUseCase,
                      updateElementUseCase: snapshot.data!.updateElementUseCase,
                      transactionBloc: BlocProvider.of<TransactionBloc>(
                        context,
                      ),
                      keysExistingUseCase: snapshot.data!.keysExistingUseCase,
                      bucketName: bucketName,
                      tenant: ownerName,
                      bucketAddress: bucketAddress.hex,
                      isExternal: isExternal,
                    )..add(const InitBucketEvent());
                  },
                ),
              ],
              child: BucketPageView(bucketName: bucketName),
            );
          }
        });
  }
}

class BucketPageView extends StatelessWidget {
  final String bucketName;
  const BucketPageView({super.key, required this.bucketName});

  String _generateTitle(BuildContext context) {
    if (BlocProvider.of<BucketBloc>(context).state.parents.isEmpty) {
      return bucketName;
    }
    return BlocProvider.of<BucketBloc>(context).state.parents.last.meta.name;
  }

  String _generateSubtitle(BuildContext context) {
    if (BlocProvider.of<BucketBloc>(context).state.parents.isEmpty) {
      return "";
    } else {
      final parents = BlocProvider.of<BucketBloc>(context).state.parents;
      if (parents.length == 1) {
        return "$bucketName / ${parents.last.meta.name}";
      } else {
        return ".. / ${parents[parents.length - 2].meta.name} / ${parents.last.meta.name}";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _key = GlobalKey<ExpandableFabState>();

    return Scaffold(
      body: BlocConsumer<BucketBloc, BucketState>(
        listenWhen: (previous, current) => true,
        listener: (context, state) {
          if (state.status == BucketStatus.initial) {
            BlocProvider.of<BucketBloc>(context).add(const LoadBucketEvent());
          } else if (state.status == BucketStatus.initialized) {
            BlocProvider.of<BucketBloc>(context).add(
              GetElementsEvent(
                  parents: BlocProvider.of<BucketBloc>(context).state.parents),
            );
          } else if (state.status == BucketStatus.ready) {
            final event = state.nestedEvent as CreateElementEvent;
            if (event.runtimeType == CreateElementEvent) {
              BlocProvider.of<BucketBloc>(context).add(
                CreateElementEvent(
                  name: event.name,
                  data: event.data,
                  type: event.type,
                  format: event.format,
                  created: event.created,
                  size: event.size,
                  parents: event.parents,
                ),
              );
            }
          } else if (state.status == BucketStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    'Error: ${state.error.toString()}',
                  ),
                ),
              );
          }
        },
        builder: (context, state) {
          return BlocConsumer<TransactionBloc, TransactionState>(
            listener: (context, state) {
              if (state.failedTransactions.isNotEmpty) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tx failed: ${state.failedTransactions.last.description}.',
                      ),
                    ),
                  );
              }
            },
            builder: (context, transactionState) {
              return RefreshIndicator(
                onRefresh: () async => BlocProvider.of<BucketBloc>(context).add(
                  GetElementsEvent(
                    parents: BlocProvider.of<BucketBloc>(context).state.parents,
                  ),
                ),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                      leading: BackButton(
                        onPressed: () {
                          if (BlocProvider.of<BucketBloc>(context)
                              .state
                              .parents
                              .isNotEmpty) {
                            final parents = BlocProvider.of<BucketBloc>(context)
                                .state
                                .parents;
                            parents.removeLast();
                            BlocProvider.of<BucketBloc>(context).add(
                              GetElementsEvent(parents: parents),
                            );
                          } else {
                            Navigator.maybePop(context);
                          }
                        },
                      ),
                      expandedHeight: 140,
                      pinned: true,
                      title: Text(
                        _generateTitle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _generateSubtitle(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textScaleFactor: 0.8,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(flex: 1, child: Container()),
                                  state.requestors.isNotEmpty
                                      ? badges.Badge(
                                          badgeContent: Text(state
                                              .requestors.length
                                              .toString()),
                                          child: IconButton(
                                            icon: const Icon(Icons.check),
                                            onPressed: () {
                                              context.read<BucketBloc>().add(
                                                  const AcceptLatestRequestorEvent());
                                            },
                                          ),
                                        )
                                      : const IconButton(
                                          icon: Icon(Icons.check),
                                          onPressed: null,
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SliverToBoxAdapter(
                    //   child: Padding(
                    //     padding: EdgeInsets.symmetric(vertical: 4),
                    //     child: SearchBar(
                    //       hintText: "Search",
                    //       trailing: [
                    //         IconButton(
                    //           onPressed: () {},
                    //           icon: Icon(Icons.search),
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          if (state.status == BucketStatus.loading ||
                              state.status == BucketStatus.waitingForKeys) {
                            return const LinearProgressIndicator();
                          } else if (transactionState
                              .waitingTransactions.isNotEmpty) {
                            final description = transactionState
                                .waitingTransactions.last.description;
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
                    ),
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          if (state.status ==
                              BucketStatus.waitingForParticipation) {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: Text(
                                  "Waiting for your participation to be confirmed...",
                                ),
                              ),
                            );
                          } else if (state.status == BucketStatus.loading &&
                              state.confirmTx == true) {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: Text(
                                  "Waiting for transaction to be confirmed...",
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          if (state.elements.isEmpty &&
                              state.newElement?.isEmpty == true) {
                            return const SizedBox(
                              height: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Looks empty here...",
                                    textScaleFactor: 1.3,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Click on the button below to add some files.",
                                  ),
                                ],
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount:
                            (state.newElement?.isNotEmpty ?? false) ? 1 : 0,
                        (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              enabled: false,
                              leading: const Icon(Icons.sync),
                              title: Text(
                                state.newElement!,
                                textScaleFactor: 2,
                              ),
                              subtitle: Text(
                                DateFormat('dd/MM/yy, HH:mm')
                                    .format(DateTime.now())
                                    .toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: state.elements.length,
                        (BuildContext context, int index) {
                          return Card(
                            child: Slidable(
                              key: const ValueKey(1),
                              groupTag: '0',
                              endActionPane: ActionPane(
                                motion: const BehindMotion(),
                                extentRatio: 0.6,
                                children: [
                                  SlideAction(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    icon: Icons.change_circle,
                                    fct: (_) async {
                                      final initialName =
                                          state.elements[index].meta.name;
                                      await displayTextInputDialog(
                                        context,
                                        "Name",
                                        "Rename",
                                        (val) => context.read<BucketBloc>().add(
                                              RenameElementEvent(
                                                state.elements[index],
                                                val,
                                              ),
                                            ),
                                        initialValue: initialName,
                                      );
                                    },
                                    label: 'Rename',
                                  ),
                                  SlideAction(
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    icon: Icons.delete_forever,
                                    fct: (_) async {
                                      await displayConfirmDialog(
                                        context,
                                        "Are you sure?",
                                        "Delete",
                                        () => null,
                                      );
                                    },
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              child: BucketListTile(index: index),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        pos: ExpandableFabPos.right,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.add),
          fabSize: ExpandableFabSize.regular,
          shape: const CircleBorder(),
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Icons.close),
          fabSize: ExpandableFabSize.small,
          shape: const CircleBorder(),
        ),
        children: [
          FloatingActionButton.extended(
            heroTag: null,
            label: const Text("Folder"),
            icon: const Icon(Icons.folder),
            onPressed: () async {
              await displayTextInputDialog(
                context,
                "Folder Name",
                "Create",
                (val) {
                  CreateElementEvent createEvent = CreateElementEvent(
                    name: val,
                    data: Uint8List.fromList([]),
                    type: "folder",
                    format: "",
                    created: DateTime.now().toUtc().millisecondsSinceEpoch,
                    size: 0,
                    parents: BlocProvider.of<BucketBloc>(context).state.parents,
                  );
                  context.read<BucketBloc>().add(CreateKeysEvent(createEvent));
                },
              );

              _key.currentState?.toggle();
            },
          ),
          FloatingActionButton.extended(
            heroTag: null,
            label: const Text("File"),
            icon: const Icon(Icons.file_present),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result != null) {
                File file = File(result.files.single.path ?? '');
                final stats = await file.stat();
                final data = await file.readAsBytes();
                final type = result.files.single.extension ?? "";
                final name = result.files.single.name;
                final size = stats.size;
                final createEvent = CreateElementEvent(
                  name: name,
                  data: data,
                  type: type,
                  format: "",
                  created: DateTime.now().toUtc().millisecondsSinceEpoch,
                  size: size,
                  parents: BlocProvider.of<BucketBloc>(context).state.parents,
                );
                context.read<BucketBloc>().add(CreateKeysEvent(createEvent));
                _key.currentState?.toggle();
              } else {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Did you select a file?')),
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}

class BucketListTile extends StatelessWidget {
  const BucketListTile({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    final state = BlocProvider.of<BucketBloc>(context).state;
    return ListTile(
      leading: state.elements[index].meta.type == "folder"
          ? const Icon(Icons.folder)
          : const Icon(Icons.file_present),
      title: Text(
        state.elements[index].meta.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textScaleFactor: 2,
      ),
      onTap: () => BlocProvider.of<BucketBloc>(context).add(GetElementsEvent(
        parents: [...state.parents, state.elements[index]],
      )),
      subtitle: Builder(
        builder: (context) {
          final dt = DateTime.fromMicrosecondsSinceEpoch(
            state.elements[index].meta.created * 1000,
          );
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                DateFormat('dd/MM/yy, HH:mm').format(dt).toString(),
              ),
              Text(state.elements[index].meta.type != "folder"
                  ? formatBytes(state.elements[index].meta.size, 2)
                  : ''),
            ],
          );
        },
      ),
    );
  }
}

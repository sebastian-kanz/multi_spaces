import 'dart:io';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_storage_repository/file_storage_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:infura_ipfs_api/infura_ipfs_api.dart';
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
import 'package:multi_spaces/bucket/domain/usecase/create_element_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/create_keys_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/get_full_elements_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_bucket_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_key_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/sync_elements_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/sync_history_usecase.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/transaction/bloc/transaction_bloc.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import '../bloc/bucket_bloc.dart';
import 'package:multi_spaces/core/contracts/Bucket.g.dart';

class BucketBlocUseCases {
  final ListenBucketEventsUseCase listenElementsInBucketUseCase;
  final GetFullElementsUseCase getFullElementsUseCase;
  final SyncElementsUseCase syncElementsUseCase;
  final SyncHistoryUseCase syncHistoryUseCase;
  final CreateElementUseCase createElementUseCase;
  final CreateKeysUseCase createKeysUseCase;
  final ListenKeyEventsUseCase listenKeyEventsUseCase;

  BucketBlocUseCases(
      this.listenElementsInBucketUseCase,
      this.getFullElementsUseCase,
      this.syncElementsUseCase,
      this.syncHistoryUseCase,
      this.createElementUseCase,
      this.createKeysUseCase,
      this.listenKeyEventsUseCase);
}

class BucketPage extends StatelessWidget {
  final String bucketName;
  final EthereumAddress bucketAddress;
  final String ownerName;
  final EthereumAddress ownerAddress;

  const BucketPage({
    super.key,
    required this.bucketName,
    required this.bucketAddress,
    required this.ownerName,
    required this.ownerAddress,
  });

  static Future<BucketBlocUseCases> _setup(
    BuildContext context,
    EthereumAddress bucketAddress,
    String ownerName,
    EthereumAddress ownerAddress,
  ) async {
    final providers =
        Provider.of<List<BlockchainProvider>>(context, listen: false);
    final bucketRepository = BucketRepositoryImpl(
      providers,
      bucketAddress.hex,
    );
    final listenElementsInBucketUseCase =
        ListenBucketEventsUseCase(bucketRepository);
    final bucket = Bucket(
      address: EthereumAddress.fromHex(bucketAddress.hex),
      client: Web3Client(Env.eth_url, Client()),
      chainId: Env.chain_id,
    );
    final elementRepository = ElementRepositoryImpl(providers, bucket);
    await elementRepository.initialize(bucketAddress.hex);
    final ipfsRepository = IpfsRepository(apis: [
      InfuraIpfsApi(
        projectId: Env.infura_project_id,
        projectSecret: Env.infura_api_key,
        client: Client(),
      )
    ]);
    final keyRepository = KeyRepository(ownerName, bucketAddress.hex);
    await keyRepository.initialize();
    final ipfsVaultRepository = IPFSVaultRepositoryImpl(
      ipfsRepository,
      keyRepository,
      bucket,
      ownerAddress,
    );
    final metaRepository = MetaRepositoryImpl(ipfsVaultRepository);
    await metaRepository.initialize(bucketAddress.hex);
    final fileStorageRepository =
        FileStorageRepository(ownerName, bucketAddress.hex);
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
      providers,
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
    return BucketBlocUseCases(
      listenElementsInBucketUseCase,
      getFullElementsUseCase,
      syncElementsUseCase,
      syncHistoryUseCase,
      createElementUseCase,
      createKeysUseCase,
      listenKeyEventsUseCase,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BucketBlocUseCases>(
        future: _setup(context, bucketAddress, ownerName, ownerAddress),
        builder: (context, AsyncSnapshot<BucketBlocUseCases> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Container();
          } else if (!snapshot.hasData) {
            return Container();
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
                      transactionBloc: BlocProvider.of<TransactionBloc>(
                        context,
                      ),
                      bucketName: bucketName,
                      tenant: ownerName,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<BucketBloc, BucketState>(
          listenWhen: (previous, current) => true,
          listener: (context, state) {
            if (state.runtimeType == BucketInitialized) {
              BlocProvider.of<BucketBloc>(context)
                  .add(const GetElementsEvent());
            } else if (state.runtimeType == BucketReady) {
              final event = (state as BucketReady).event;
              if (event.runtimeType == CreateElementEvent) {
                BlocProvider.of<BucketBloc>(context).add(
                  CreateElementEvent(
                    name: (event as CreateElementEvent).name,
                    data: event.data,
                    type: event.type,
                    format: event.format,
                    created: event.created,
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            return BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, transactionState) {
                return RefreshIndicator(
                  onRefresh: () async =>
                      BlocProvider.of<BucketBloc>(context).add(
                    const GetElementsEvent(),
                  ),
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        backgroundColor: Colors.green,
                        title: Text(bucketName),
                        expandedHeight: 200,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(bucketName),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: transactionState.transactionHashes.isNotEmpty
                            ? const LinearProgressIndicator()
                            : Container(),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: state.elements.length,
                          (BuildContext context, int index) {
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
                                      fct: (_) {},
                                      label: 'Rename',
                                    ),
                                    SlideAction(
                                      color: Colors.red,
                                      icon: Icons.delete_forever,
                                      fct: (_) {},
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  onTap: () =>
                                      print(state.elements[index].meta.hash),
                                  // leading: Container(
                                  //     padding: EdgeInsets.all(8),
                                  //     width: 100,
                                  //     child: Placeholder()),
                                  title: Text(
                                    state.elements[index].meta.name,
                                    textScaleFactor: 2,
                                  ),
                                ),
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
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 4.0,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles();

          if (result != null) {
            File file = File(result.files.single.path ?? '');
            final stats = await file.stat();
            final data = await file.readAsBytes();
            final type = result.files.single.extension ?? "";
            final name = result.files.single.name;
            final createEvent = CreateElementEvent(
              name: name,
              data: data,
              type: type,
              format: "",
              created: stats.changed.microsecondsSinceEpoch,
            );
            context.read<BucketBloc>().add(CreateKeysEvent(createEvent));
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Did you select a file?')),
              );
          }
        },
      ),
    );
  }
}

class BucketListTile extends StatelessWidget {
  const BucketListTile({
    Key? key,
    // required this.spaceState,
    required this.index,
  }) : super(key: key);

  // final SpaceInitialized spaceState;
  final int index;

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      // leading: spaceState.buckets[index].isExternal
      //     ? const Icon(Icons.travel_explore)
      //     : const Icon(Icons.public),
      title: Text("Item"),
      // onTap: () => Navigator.of(context).push<void>(
      //   BucketPage.route(spaceState.buckets[index].name),
      // ),
      // subtitle: Builder(
      //   builder: (context) {
      //     final count =
      //         (spaceState.buckets[index].elementCount / 3).toStringAsFixed(0);
      //     final diff =
      //         DateTime.now().difference(spaceState.buckets[index].creation);
      //     var creationWidget = Text("${diff.inDays} day(s) ago");
      //     if (diff.inHours == 0 && diff.inMinutes == 0) {
      //       creationWidget = const Text("Just now");
      //     } else if (diff.inHours == 0 && diff.inMinutes > 0) {
      //       creationWidget = Text("${diff.inMinutes} minutes(s) ago");
      //     } else if (diff.inDays == 0) {
      //       creationWidget = Text("${diff.inHours} hour(s) ago");
      //     }
      //     return Row(
      //       mainAxisSize: MainAxisSize.max,
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: <Widget>[
      //         creationWidget,
      //         Text("$count items"),
      //       ],
      //     );
      //   },
      // ),
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

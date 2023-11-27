import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multi_spaces/core/utils/input_dialog.dart';
import 'package:multi_spaces/core/widgets/carousel.dart';
import 'package:multi_spaces/multi_spaces/bloc/multi_spaces_bloc.dart';
import 'package:multi_spaces/multi_spaces/repository/multi_spaces_repository.dart';
import 'package:multi_spaces/space/screens/space_page.dart';
import 'package:multi_spaces/core/widgets/nav_drawer.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../../authentication/authentication.dart';

class MultiSpacesPage extends StatelessWidget {
  final EthereumAddress? externalBucket;

  const MultiSpacesPage({super.key, this.externalBucket});

  static const routeName = '/multispace';

  static Route route({EthereumAddress? externalBucket}) {
    return MaterialPageRoute<MultiSpacesPage>(
      builder: (_) => BlocProvider(
        create: (context) => MultiSpacesBloc(
          multiSpacesRepository: context.read<MultiSpacesRepository>(),
          authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
        )..add(const MultiSpacesStarted()),
        child: MultiSpacesPage(externalBucket: externalBucket),
      ),
    );
  }

  List<Widget> _getCarouselElements(BuildContext context) {
    return [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/undraw_mobile_encryption_re_yw3o.svg',
                  width: MediaQuery.of(context).size.width / 4,
                ),
                const SizedBox(
                  width: 32.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: const Text(
                    "Your personal data is stored encrypted - only you are able to access it.",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: const Text(
                    "Sharing data is easy - you can give your family and friends access to your Space.",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(
                  width: 32.0,
                ),
                SvgPicture.asset(
                  'assets/images/undraw_sharing_articles_re_jnkp.svg',
                  width: MediaQuery.of(context).size.width / 4,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/undraw_devices_re_dxae.svg',
                  width: MediaQuery.of(context).size.width / 4,
                ),
                const SizedBox(
                  width: 32.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: const Text(
                    "You can access your stored data via smartphone, desktop or web browser.",
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
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/undraw_ethereum.svg',
                  width: MediaQuery.of(context).size.width / 4,
                ),
                const SizedBox(
                  width: 32.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: const Text(
                    "Your complete data history is linked on the Ethereum blockchain, so it will never get lost.",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: const Text(
                    "For backup and sharing data with your family and friends the IPFS network is used - all data that leaves your device is securely encrypted.",
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(
                  width: 32.0,
                ),
                SvgPicture.asset(
                  'assets/images/undraw_connected_world_wuay.svg',
                  width: MediaQuery.of(context).size.width / 4,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          )
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final multiSpacesBloc = Provider.of<MultiSpacesBloc>(
      context,
    );

    return BlocConsumer<MultiSpacesBloc, MultiSpaceState>(
      bloc: multiSpacesBloc,
      listener: (context, state) {
        if (state.runtimeType == MultiSpacesReady) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            SpacePage.routeName,
            (Route<dynamic> route) => false,
            arguments: SpacePageArguments(
              (multiSpacesBloc.state as MultiSpacesReady).spaceAddress,
              (multiSpacesBloc.state as MultiSpacesReady).paymentManagerAddress,
              externalBucketToAdd: externalBucket,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.runtimeType == NoInternetConnectionAvailable) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Waiting for internet connection...",
              ),
            ),
          );
        } else if (state.runtimeType == MultiSpacesLoading ||
            state.runtimeType == SpaceCreationInProgress) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          final elements = _getCarouselElements(context);
          return Scaffold(
            drawer: const NavDrawer(hidePayment: true),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Padding(
                        padding: const EdgeInsets.all(
                          32.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Looks empty here...",
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/undraw_upload_re_pasx.svg',
                                  width: MediaQuery.of(context).size.width / 3,
                                ),
                                const SizedBox(width: 32.0),
                                Expanded(
                                  child: Text(
                                    "A Space is a secure place for all your personal data under your control. You own it, you manage it.",
                                    maxLines: 6,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "Start below by creating your first Space.",
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        32.0,
                      ),
                      child: Carousel(
                        elements: elements,
                      ),
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
                    onPressed: () async {
                      await displayTextInputDialog(
                        context,
                        "What's your name?",
                        "Save",
                        (val) => multiSpacesBloc.add(
                          CreateSpacePressed(val),
                        ),
                      );
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
                      icon: const Icon(Icons.info),
                      onPressed: () {
                        // TODO: Show popup with more information about spaces
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

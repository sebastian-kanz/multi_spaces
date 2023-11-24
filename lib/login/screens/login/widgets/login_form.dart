import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants.dart';
import '../bloc/login_bloc.dart';
import 'custom_input_field.dart';
import 'fade_slide_transition.dart';

class LoginForm extends StatelessWidget {
  final Animation<double> animation;

  const LoginForm({
    super.key,
    required this.animation,
  });

  Widget orDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'or',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Container(
              height: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoButton(
    BuildContext context, {
    required String image,
    required VoidCallback onPressed,
  }) {
    if (kIsWeb) {
      return FloatingActionButton.extended(
        heroTag: image,
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        onPressed: onPressed,
        label: const Text("Connect your wallet"),
        icon: const Icon(Icons.wallet),
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      return FloatingActionButton(
        heroTag: image,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        onPressed: onPressed,
        child: SizedBox(
          height: 30,
          child: Image.asset(image),
        ),
      );
    }
    return FloatingActionButton.extended(
      heroTag: image,
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      onPressed: onPressed,
      label: const Text("Connect your wallet"),
      icon: const Icon(Icons.wallet),
    );
  }

  Widget _buildWalletButton(BuildContext context) {
    return _buildLogoButton(
      context,
      image: 'assets/images/walletconnect_logo.png',
      onPressed: () =>
          context.read<LoginBloc>().add(const LoginWalletQRSubmitted()),
    );
  }

  List<Widget> _buildSocialButtons(BuildContext context) {
    return [
      _buildLogoButton(
        context,
        image: 'assets/images/google_logo.png',
        onPressed: () =>
            context.read<LoginBloc>().add(const LoginGoogleSubmitted()),
      ),
      _buildLogoButton(
        context,
        image: 'assets/images/facebook_logo.png',
        onPressed: () =>
            context.read<LoginBloc>().add(const LoginFacebookSubmitted()),
      ),
      _buildLogoButton(
        context,
        image: 'assets/images/apple_logo.png',
        onPressed: () =>
            context.read<LoginBloc>().add(const LoginAppleSubmitted()),
      ),
    ];
  }

  Widget _buildLoginButtons(BuildContext context) {
    final loginButtons = [_buildWalletButton(context)];
    if (kIsWeb) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: loginButtons,
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      loginButtons.insertAll(0, _buildSocialButtons(context));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: loginButtons,
    );
  }

  List<Widget> _buildPrimaryLogin(BuildContext context, double space) {
    if (kIsWeb) {
      return [
        FadeSlideTransition(
          animation: animation,
          additionalOffset: 0.0,
          child: const Text("Please log in to continue."),
        ),
        SizedBox(height: space),
      ];
    } else if (Platform.isAndroid || Platform.isIOS) {
      return [
        FadeSlideTransition(
          animation: animation,
          additionalOffset: 0.0,
          child: CustomInputField(
            label: 'Email',
            prefixIcon: Icons.person,
            onInputChanged: (input) =>
                context.read<LoginBloc>().add(LoginEmailChanged(input)),
            obscureText: false,
          ),
        ),
        SizedBox(height: space),
        FadeSlideTransition(
          animation: animation,
          additionalOffset: 2 * space,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: double.infinity,
            ),
            child: ElevatedButton(
              child: const Text('Login'),
              onPressed: () => context.read<LoginBloc>().add(
                    const LoginEmailSubmitted(),
                  ),
            ),
          ),
        ),
        SizedBox(height: 2 * space),
        FadeSlideTransition(
          animation: animation,
          additionalOffset: 2 * space,
          child: orDivider(context),
        ),
      ];
    }
    return [
      FadeSlideTransition(
        animation: animation,
        additionalOffset: 0.0,
        child: const Text("Please log in to continue."),
      ),
      SizedBox(height: space),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    final space = height > 650 ? kSpaceM : kSpaceS;

    return BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) => previous.email != current.email,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPaddingL),
            child: Column(
              children: <Widget>[
                ..._buildPrimaryLogin(context, space),
                SizedBox(height: 2 * space),
                FadeSlideTransition(
                  animation: animation,
                  additionalOffset: 3 * space,
                  child: _buildLoginButtons(context),
                ),
              ],
            ),
          );
        });
  }
}

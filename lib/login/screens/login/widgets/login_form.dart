import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants.dart';
import '../bloc/login_bloc.dart';
import 'custom_button.dart';
import 'custom_input_field.dart';
import 'fade_slide_transition.dart';

class LoginForm extends StatelessWidget {
  final Animation<double> animation;

  const LoginForm({
    super.key,
    required this.animation,
  });

  Widget orDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 1,
              color: kBlue,
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
              color: kBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoButton({
    required String image,
    required VoidCallback onPressed,
  }) {
    if (kIsWeb) {
      return FloatingActionButton.extended(
        heroTag: image,
        backgroundColor: Colors.white,
        onPressed: onPressed,
        label: const Text("Connect your wallet"),
        icon: const Icon(Icons.wallet),
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      return FloatingActionButton(
        heroTag: image,
        backgroundColor: Colors.white,
        onPressed: onPressed,
        child: SizedBox(
          height: 30,
          child: Image.asset(image),
        ),
      );
    }
    return FloatingActionButton.extended(
      heroTag: image,
      backgroundColor: Colors.white,
      onPressed: onPressed,
      label: const Text("Connect your wallet"),
      icon: const Icon(Icons.wallet),
    );
  }

  Widget _buildWalletButton(BuildContext context) {
    return _buildLogoButton(
      image: 'assets/images/walletconnect_logo.png',
      onPressed: () => AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        showCloseIcon: true,
        title: "Walletconnect Login",
        desc: "Either open wallet app or login via qr code.",
        buttonsBorderRadius: const BorderRadius.all(
          Radius.circular(2),
        ),
        dismissOnTouchOutside: true,
        dismissOnBackKeyPress: true,
        onDismissCallback: (type) {
          if (type != DismissType.btnCancel && type != DismissType.btnOk) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Login cancelled.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        },
        headerAnimationLoop: false,
        animType: AnimType.scale,
        btnCancelOnPress: () =>
            context.read<LoginBloc>().add(const LoginWalletQRSubmitted()),
        btnCancelText: "Show QR code",
        btnOkOnPress: () =>
            context.read<LoginBloc>().add(const LoginWalletSubmitted()),
        btnOkText: "Open Wallet",
      ).show(),
    );
  }

  List<Widget> _buildSocialButtons(BuildContext context) {
    return [
      _buildLogoButton(
        image: 'assets/images/google_logo.png',
        onPressed: () =>
            context.read<LoginBloc>().add(const LoginGoogleSubmitted()),
      ),
      _buildLogoButton(
        image: 'assets/images/facebook_logo.png',
        onPressed: () =>
            context.read<LoginBloc>().add(const LoginFacebookSubmitted()),
      ),
      _buildLogoButton(
        image: 'assets/images/twitter_logo.png',
        onPressed: () =>
            context.read<LoginBloc>().add(const LoginTwitterSubmitted()),
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
          child: orDivider(),
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

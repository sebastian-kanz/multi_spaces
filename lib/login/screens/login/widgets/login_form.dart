import 'package:awesome_dialog/awesome_dialog.dart';
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

  Widget _buildSocialButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
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
        _buildLogoButton(
            image: 'assets/images/walletconnect_logo.png',
            onPressed:
                //  () => showAvatarModalBottomSheet(
                //   context: context,
                //   builder: (context) => ModalFit(),
                // ),
                // () => context.read<LoginBloc>().add(const LoginWalletSubmitted()),
                () => AwesomeDialog(
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
                        if (type != DismissType.btnCancel &&
                            type != DismissType.btnOk) {
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
                      btnCancelOnPress: () => context
                          .read<LoginBloc>()
                          .add(const LoginWalletQRSubmitted()),
                      btnCancelText: "Show QR code",
                      btnOkOnPress: () => context
                          .read<LoginBloc>()
                          .add(const LoginWalletSubmitted()),
                      btnOkText: "Open Wallet",
                    ).show())
      ],
    );
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
                  child: CustomButton(
                    color: kBlue,
                    textColor: kWhite,
                    text: 'Login',
                    onPressed: () => context
                        .read<LoginBloc>()
                        .add(const LoginEmailSubmitted()),
                  ),
                ),
                SizedBox(height: 2 * space),
                FadeSlideTransition(
                  animation: animation,
                  additionalOffset: 2 * space,
                  child: orDivider(),
                ),
                SizedBox(height: 2 * space),
                FadeSlideTransition(
                  animation: animation,
                  additionalOffset: 3 * space,
                  child: _buildSocialButtons(context),
                ),
              ],
            ),
          );
        });
  }
}

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blockchain_authentication_repository/blockchain_authentication_repository.dart';
import 'package:blockchain_repository/blockchain_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_spaces/login/screens/login/bloc/login_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:user_repository/user_repository.dart';
import '../../../core/constants.dart';
import 'widgets/custom_clippers/index.dart';
import 'widgets/header.dart';
import 'widgets/login_form.dart';
import 'package:formz/formz.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => const LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return BlocProvider(
      create: (context) {
        return LoginBloc(
          blockchainRepository:
              RepositoryProvider.of<BlockchainRepository>(context),
          authenticationRepository:
              RepositoryProvider.of<BlockchainAuthenticationRepository>(
                  context),
          userRepository: RepositoryProvider.of<UserRepository>(context),
        );
      },
      child: LoginPageView(screenHeight: screenHeight),
    );
  }
}

class LoginPageView extends StatefulWidget {
  final double screenHeight;

  const LoginPageView({
    super.key,
    required this.screenHeight,
  });

  @override
  LoginPageViewState createState() => LoginPageViewState();
}

class LoginPageViewState extends State<LoginPageView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _headerTextAnimation;
  late final Animation<double> _formElementAnimation;
  late final Animation<double> _whiteTopClipperAnimation;
  late final Animation<double> _blueTopClipperAnimation;
  late final Animation<double> _greyTopClipperAnimation;

  late BlockchainRepository repo;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: kLoginAnimationDuration,
    );

    final fadeSlideTween = Tween<double>(begin: 0.0, end: 1.0);
    _headerTextAnimation = fadeSlideTween.animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.6,
        curve: Curves.easeInOut,
      ),
    ));
    _formElementAnimation = fadeSlideTween.animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.7,
        1.0,
        curve: Curves.easeInOut,
      ),
    ));

    final clipperOffsetTween = Tween<double>(
      begin: widget.screenHeight,
      end: 0.0,
    );
    _blueTopClipperAnimation = clipperOffsetTween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.2,
          0.7,
          curve: Curves.easeInOut,
        ),
      ),
    );
    _greyTopClipperAnimation = clipperOffsetTween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.35,
          0.7,
          curve: Curves.easeInOut,
        ),
      ),
    );
    _whiteTopClipperAnimation = clipperOffsetTween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.5,
          0.7,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Authentication Failure')),
            );
        }
        if (state.deeplink.isNotEmpty) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            showCloseIcon: true,
            dismissOnTouchOutside: true,
            dismissOnBackKeyPress: true,
            width: width > 400 ? width * 0.6 : width,
            onDismissCallback: (type) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Login cancelled.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
            headerAnimationLoop: false,
            animType: AnimType.scale,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPaddingS),
              child: Column(
                children: <Widget>[
                  const Text("Scan QR code to login."),
                  const SizedBox(height: kSpaceS),
                  QrImageView(
                    data: state.deeplink,
                    backgroundColor: Theme.of(context).colorScheme.onBackground,
                  ),
                  const SizedBox(height: kSpaceS),
                ],
              ),
            ),
          ).show();
        }
      },
      builder: (context, state) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: _whiteTopClipperAnimation,
              builder: (_, Widget? child) {
                return ClipPath(
                  clipper: WhiteTopClipper(
                    yOffset: _whiteTopClipperAnimation.value,
                  ),
                  child: child,
                );
              },
              child: Container(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            AnimatedBuilder(
              animation: _greyTopClipperAnimation,
              builder: (_, Widget? child) {
                return ClipPath(
                  clipper: GreyTopClipper(
                    yOffset: _greyTopClipperAnimation.value,
                  ),
                  child: child,
                );
              },
              child: Container(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            AnimatedBuilder(
              animation: _blueTopClipperAnimation,
              builder: (_, Widget? child) {
                return ClipPath(
                  clipper: BlueTopClipper(
                    yOffset: _blueTopClipperAnimation.value,
                  ),
                  child: child,
                );
              },
              child: Container(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: kPaddingL),
                child: Column(
                  children: <Widget>[
                    Header(animation: _headerTextAnimation),
                    const Spacer(),
                    LoginForm(animation: _formElementAnimation),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

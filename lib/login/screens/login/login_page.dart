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

class LoginPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        return LoginPage(screenHeight: screenHeight);
      },
    );
  }

  final double screenHeight;

  const LoginPage({
    super.key,
    required this.screenHeight,
  });

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
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
      child: BlocListener<LoginBloc, LoginState>(
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
                padding: const EdgeInsets.symmetric(horizontal: kPaddingL),
                child: Column(
                  children: <Widget>[
                    const Text("Scan QR code to login."),
                    const SizedBox(height: kSpaceS),
                    QrImage(data: state.deeplink),
                  ],
                ),
              ),
            ).show();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: kWhite,
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
                child: Container(color: kGrey),
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
                child: Container(color: kBlue),
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
                child: Container(color: kWhite),
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
      ),
    );
  }
}

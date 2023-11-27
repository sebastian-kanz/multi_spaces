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

  static String routeName = '/login';

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
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    QrImageView(
                      data: state.deeplink,
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
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () {
                            context
                                .read<LoginBloc>()
                                .add(const LoginWalletSubmitted());
                            Navigator.of(context).pop();
                          },
                        ),
                        const Text(
                          "Open app",
                          textScaler: TextScaler.linear(0.8),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          );
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
                color: Theme.of(context).colorScheme.primaryContainer,
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
                color: Theme.of(context).colorScheme.secondaryContainer,
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
                color: Theme.of(context).colorScheme.tertiaryContainer,
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

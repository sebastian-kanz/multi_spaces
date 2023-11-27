import 'package:blockchain_authentication_repository/blockchain_authentication_repository.dart';
import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:blockchain_repository/blockchain_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:multi_spaces/core/blockchain_providers/ethereum_wc_provider.dart';
import 'package:multi_spaces/core/blockchain_providers/ethereum_web3auth_provider.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_repository/user_repository.dart';
import 'package:web3auth_flutter/enums.dart';
import '../models/models.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required BlockchainRepository blockchainRepository,
    required BlockchainAuthenticationRepository authenticationRepository,
    required UserRepository userRepository,
  })  : _blockchainRepository = blockchainRepository,
        _authenticationRepository = authenticationRepository,
        _userRepository = userRepository,
        super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginEmailSubmitted>(_onEmailSubmitted);
    on<LoginFacebookSubmitted>(_onFacebookSubmitted);
    on<LoginAppleSubmitted>(_onAppleSubmitted);
    on<LoginGoogleSubmitted>(_onGoogleSubmitted);
    on<LoginWalletSubmitted>(_onWalletSubmitted);
    on<LoginWalletQRSubmitted>(_onWalletQRSubmitted);
  }

  final BlockchainRepository _blockchainRepository;
  final BlockchainAuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;
  final logger = getLogger();

  void _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email]),
      deeplink: "",
    ));
  }

  void _initRepositories() {
    _authenticationRepository.init();
    _blockchainRepository.init();
    _userRepository.init();
  }

  void _onEmailSubmitted(
    LoginEmailSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.status.isValidated) {
      emit(state.copyWith(status: FormzStatus.submissionInProgress));
      try {
        BlockchainProviderManager().selectProvider<EthereumWeb3AuthProvider>();
        _initRepositories();
        await _authenticationRepository.logIn({
          'provider': Provider.email_passwordless,
          'email': state.email.value
        });
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      } catch (e) {
        logger.e(e);
        emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    }
  }

  void _onGoogleSubmitted(
    LoginGoogleSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    try {
      BlockchainProviderManager().selectProvider<EthereumWeb3AuthProvider>();
      _initRepositories();
      await _authenticationRepository.logIn({'provider': Provider.google});
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  void _onFacebookSubmitted(
    LoginFacebookSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    try {
      BlockchainProviderManager().selectProvider<EthereumWeb3AuthProvider>();
      _initRepositories();
      await _authenticationRepository.logIn({'provider': Provider.facebook});
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  void _onAppleSubmitted(
    LoginAppleSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    try {
      BlockchainProviderManager().selectProvider<EthereumWeb3AuthProvider>();
      _initRepositories();
      await _authenticationRepository.logIn({'provider': Provider.apple});
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  void _onWalletSubmitted(
    LoginWalletSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    try {
      BlockchainProviderManager().selectProvider<EthereumWcProvider>();
      _initRepositories();
      await _authenticationRepository.logIn({
        'onDisplayUri': (uri) async {
          final adaptedUri = Uri.parse("wc://$uri");
          logger.d(adaptedUri.toString());
          if (!await canLaunchUrl(adaptedUri)) {
            emit(state.copyWith(status: FormzStatus.submissionFailure));
            return;
          }
          await launchUrl(adaptedUri);
        }
      });
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  void _onWalletQRSubmitted(
    LoginWalletQRSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    try {
      BlockchainProviderManager().selectProvider<EthereumWcProvider>();
      _initRepositories();
      await _authenticationRepository.logIn({
        'onDisplayUri': (uri) async {
          logger.d(uri);
          emit(state.copyWith(deeplink: uri));
        }
      });
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}

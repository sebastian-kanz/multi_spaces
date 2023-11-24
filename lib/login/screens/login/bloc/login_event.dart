part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class LoginEmailSubmitted extends LoginEvent {
  const LoginEmailSubmitted();
}

class LoginGoogleSubmitted extends LoginEvent {
  const LoginGoogleSubmitted();
}

class LoginFacebookSubmitted extends LoginEvent {
  const LoginFacebookSubmitted();
}

class LoginAppleSubmitted extends LoginEvent {
  const LoginAppleSubmitted();
}

class LoginWalletSubmitted extends LoginEvent {
  const LoginWalletSubmitted();
}

class LoginWalletQRSubmitted extends LoginEvent {
  const LoginWalletQRSubmitted();
}

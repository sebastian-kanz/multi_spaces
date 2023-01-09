part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState(
      {this.status = FormzStatus.pure,
      this.email = const Email.pure(),
      this.deeplink = ""});

  final FormzStatus status;
  final Email email;
  final String deeplink;

  LoginState copyWith({FormzStatus? status, Email? email, String? deeplink}) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      deeplink: deeplink ?? this.deeplink,
    );
  }

  @override
  List<Object> get props => [status, email, deeplink];
}

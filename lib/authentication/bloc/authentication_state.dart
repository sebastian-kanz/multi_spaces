part of 'authentication_bloc.dart';

class AuthenticationState extends Equatable {
  const AuthenticationState._(
      {this.status = AuthenticationStatus.unknown, this.user = User.empty});

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(User user)
      : this._(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus status;
  final User user;

  @override
  List<Object> get props => [status, user];

  // Map<String, dynamic> toJson() {
  //   return {'status': status, 'user': user.toJson()};
  // }

  // AuthenticationState? fromJson(Map<String, dynamic> json) {
  //   final status = json['status'];
  //   switch (status) {
  //     case AuthenticationStatus.unknown:
  //       return const AuthenticationState.unknown();
  //     case AuthenticationStatus.initialized:
  //       return const AuthenticationState.unknown();
  //     case AuthenticationStatus.authenticated:
  //       return AuthenticationState.authenticated(
  //           User(json['user']['id'] ?? ''));
  //     case AuthenticationStatus.unauthenticated:
  //       return const AuthenticationState.unauthenticated();
  //   }
  //   return null;
  // }
}

part of 'auth_cubit.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

@immutable
class AuthState extends Equatable {
  final AuthStatus status;
  final NetfloxUser? user;
  final Object? message;

  bool hasError() => message is FirebaseAuthException;
  bool isAuthenticated() => status == AuthStatus.authenticated;
  bool isUnauthenticated() => status == AuthStatus.unauthenticated;
  bool isLoading() => status == AuthStatus.loading;

  const AuthState._(this.status, {this.user, this.message});

  factory AuthState.error({required Object exception}) =>
      AuthState._(AuthStatus.unauthenticated, message: exception);

  factory AuthState.loading([Object? loadingMessage]) =>
      AuthState._(AuthStatus.loading, message: loadingMessage);

  factory AuthState.signedIn({required NetfloxUser user, Object? message}) =>
      AuthState._(AuthStatus.authenticated, user: user, message: message);

  factory AuthState.signedOut() =>
      const AuthState._(AuthStatus.unauthenticated);

  AuthState copyWith({AuthStatus? status, NetfloxUser? user, Object? message}) {
    return AuthState._(status ?? this.status,
        user: user ?? this.user, message: message ?? this.message);
  }

  @override
  List<Object?> get props => [status, user, message];
}

part of 'account_manager_bloc.dart';

@immutable
abstract class AccountManagerState {}

class AccountStateSignedOut extends AccountManagerState {}

class AccountStateSignedIn extends AccountManagerState {
  final NetfloxUser user;

  AccountStateSignedIn(this.user);
}

class AccountStateError extends AccountManagerState {
  final NetfloxException exception;

  AccountStateError(this.exception);
}

class AccountStateLoading extends AccountManagerState {}

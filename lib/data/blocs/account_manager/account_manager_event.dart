part of 'account_manager_bloc.dart';

@immutable
abstract class AccountManagerEvent {}

class SignInAccountEvent extends AccountManagerEvent {}

class SignOutAccountEvent extends AccountManagerEvent {}

class DeleteAccountEvent extends AccountManagerEvent {}

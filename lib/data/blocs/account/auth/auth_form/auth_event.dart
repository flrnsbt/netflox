import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'auth_form_bloc.dart';

abstract class AuthFormEvent extends Equatable {
  const AuthFormEvent();
  @override
  List<Object?> get props => [];
}

@immutable
class SubmitAuthForm extends AuthFormEvent {
  final String password;
  final String email;

  const SubmitAuthForm(this.password, this.email);
  @override
  List<Object?> get props => [email, password];
}

@immutable
class ReauthenticateEvent extends AuthFormEvent {
  final String password;
  final String? email;

  const ReauthenticateEvent({required this.password, this.email});
  @override
  List<Object?> get props => [email, password];
}

class ChangeFormMode extends AuthFormEvent {
  final AuthFormMode state;

  const ChangeFormMode(this.state);

  @override
  List<Object?> get props => [state];
}

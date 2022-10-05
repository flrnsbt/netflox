import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/services/firestore_service.dart';
import '../../../../../services/firebase_auth_service.dart';
import 'auth_event.dart';

enum AuthFormMode { signIn, signUp, reauthenticate }

enum AuthFormStatus {
  init,
  loading,
  success,
  error;
}

class AuthFormState extends Equatable {
  final AuthFormMode mode;
  final AuthFormStatus status;
  final FirebaseAuthException? exception;

  const AuthFormState._(this.mode,
      [this.status = AuthFormStatus.init, this.exception]);

  static const signIn = AuthFormState._(AuthFormMode.signIn);

  static const signUp = AuthFormState._(AuthFormMode.signUp);
  static const reauthenticate = AuthFormState._(AuthFormMode.reauthenticate);

  AuthFormState success() => copyWith(status: AuthFormStatus.success);
  AuthFormState fail(FirebaseAuthException exception) =>
      copyWith(status: AuthFormStatus.error, exception: exception);
  AuthFormState loading() => copyWith(status: AuthFormStatus.loading);
  AuthFormState init() => copyWith(status: AuthFormStatus.init);

  bool isSignIn() => mode == AuthFormMode.signIn;
  bool isSignUp() => mode == AuthFormMode.signUp;
  bool isFinish() => status == AuthFormStatus.success;
  bool failed() => status == AuthFormStatus.error;
  bool isLoading() => status == AuthFormStatus.loading;

  @override
  List<Object?> get props => [mode, status, exception];

  AuthFormState copyWith({
    AuthFormMode? mode,
    AuthFormStatus? status,
    FirebaseAuthException? exception,
  }) {
    return AuthFormState._(
      mode ?? this.mode,
      status ?? this.status,
      exception ?? this.exception,
    );
  }
}

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  final FirebaseAuthService _authService;

  AuthFormBloc(
      {AuthFormMode initialMode = AuthFormMode.signIn,
      FirebaseAuthService? authService,
      FirestoreService? databaseService})
      : _authService = authService ?? FirebaseAuthService(),
        super(AuthFormState._(initialMode)) {
    on<SubmitAuthForm>(_submitAuthRequest);

    on<ReauthenticateEvent>(_reauthenticateEvent);

    on<ChangeFormMode>(
      (event, emit) {
        final state = AuthFormState._(event.state);
        emit(state);
      },
    );
  }

  FutureOr<void> _reauthenticateEvent(ReauthenticateEvent event, emit) async {
    emit(state.loading());
    final email = event.email;
    final password = event.password;
    if (_authService.currentUser != null) {
      try {
        await _authService.reauthenticate(password: password, email: email);
        emit(state.success());
      } on FirebaseAuthException catch (e) {
        emit(state.fail(e));
      }
    }
  }

  FutureOr<void> _submitAuthRequest(SubmitAuthForm event, emit) async {
    emit(state.loading());
    final email = event.email;
    final password = event.password;
    try {
      switch (state.mode) {
        case AuthFormMode.signIn:
          await _authService.signIn(email: email, password: password);
          break;
        case AuthFormMode.signUp:
          await _authService.signUp(email: email, password: password);
          break;
        case AuthFormMode.reauthenticate:
          if (_authService.currentUser != null) {
            await _authService.reauthenticate(password: password, email: email);
          }
          break;
      }
      emit(state.success());
    } on FirebaseAuthException catch (e) {
      emit(state.fail(e));
    }
  }
}

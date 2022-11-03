import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/ui/screens/auths/reauthenticate_screen.dart';
import 'package:netflox/ui/screens/auths/sign_in_screen.dart';
import 'package:netflox/ui/screens/auths/sign_up_screen.dart';
import 'package:netflox/ui/widgets/constrained_large_screen_widget.dart';
import 'package:provider/provider.dart';
import '../../../data/blocs/account/auth/auth_form/auth_form_bloc.dart';
import '../../widgets/custom_awesome_dialog.dart';

class AuthScreen extends StatelessWidget {
  final void Function()? onFinish;
  final AuthFormMode mode;
  const AuthScreen({Key? key, this.onFinish, this.mode = AuthFormMode.signIn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: ConstrainedLargeScreenWidget(
          child: Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: AuthFormScreen(
                    mode: mode,
                    onFinish: onFinish,
                  ))),
        ));
  }
}

class AuthFormScreen extends StatelessWidget {
  final AuthFormMode mode;
  final void Function()? onFinish;

  const AuthFormScreen({super.key, required this.mode, this.onFinish});

  @override
  Widget build(BuildContext context) {
    NetfloxCustomDialog? dialog;
    return Provider(
      dispose: (context, value) {
        dialog?.dismiss();
      },
      create: (context) => AuthFormBloc(initialMode: mode),
      child: BlocConsumer<AuthFormBloc, AuthFormState>(
        builder: (context, state) {
          switch (state.mode) {
            case AuthFormMode.signIn:
              return const SignInScreen();
            case AuthFormMode.signUp:
              return const SignUpScreen();
            case AuthFormMode.reauthenticate:
              return const ReauthenticateScreen();
          }
        },
        listener: (context, state) {
          dialog?.dismiss();
          dialog = null;
          switch (state.status) {
            case AuthFormStatus.loading:
              dialog = LoadingDialog(context);
              break;
            case AuthFormStatus.success:
              onFinish?.call();
              break;
            case AuthFormStatus.error:
              final exception = NetfloxException.from(state.exception!);
              dialog = ErrorDialog.fromException(
                exception,
                context,
              ).tr();
              break;
            case AuthFormStatus.init:
              break;
          }
          dialog?.show();
        },
      ),
    );
  }
}

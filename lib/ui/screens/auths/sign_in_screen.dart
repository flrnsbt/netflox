import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/widgets/netflox_asset_icon.dart';
import 'package:nil/nil.dart';
import '../../../data/blocs/account/auth/auth_form/auth_event.dart';
import '../../../data/blocs/account/auth/auth_form/auth_form_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const NetfloxAssetIcon(),
        const SizedBox(
          height: 35,
        ),
        const Text(
          "sign-in",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ).tr(),
        const SizedBox(
          height: 35,
        ),
        TextFormField(
          controller: emailController,
          maxLines: 1,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return "fill-out-this-field".tr(context);
            } else if (!EmailValidator.validate(value!)) {
              return "use-valid-email".tr(context);
            }
            return null;
          },
          decoration: InputDecoration(
              filled: true,
              hintText: "email-address-hint".tr(context),
              contentPadding: const EdgeInsets.symmetric(horizontal: 25),
              prefixIcon: Icon(
                Icons.email,
                color: Theme.of(context).hintColor,
              ),
              suffixIcon: ValueListenableBuilder(
                  valueListenable: emailController,
                  builder: ((context, value, child) {
                    if (value.text.isNotEmpty) {
                      return IconButton(
                          onPressed: () => emailController.clear(),
                          icon: const Icon(Icons.close));
                    }
                    return const Nil();
                  })),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none)),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(
          height: 25,
        ),
        TextFormField(
          controller: passwordController,
          maxLines: 1,
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return "fill-out-this-field".tr(context);
            }
            if ((value?.length ?? 0) <= 7) {
              return "password-too-short".tr(context);
            }
            return null;
          },
          obscureText: true,
          textInputAction: TextInputAction.send,
          onFieldSubmitted: (value) => _submit(),
          decoration: InputDecoration(
              filled: true,
              hintText: "password-hint".tr(context),
              contentPadding: const EdgeInsets.symmetric(horizontal: 25),
              prefixIcon: const Icon(
                Icons.lock,
              ),
              suffixIcon: ValueListenableBuilder(
                  valueListenable: passwordController,
                  builder: ((context, value, child) {
                    if (value.text.isNotEmpty) {
                      return IconButton(
                          onPressed: () => passwordController.clear(),
                          icon: const Icon(Icons.close));
                    }
                    return const Nil();
                  })),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none)),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {},
                style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(
                      vertical: 5,
                    )),
                    minimumSize: MaterialStatePropertyAll(Size.zero)),
                child: const Text("forgot-password").tr()),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        ElevatedButton(
            style: ButtonStyle(
                minimumSize:
                    const MaterialStatePropertyAll(Size.fromHeight(45)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)))),
            onPressed: () => _submit(),
            child: const Text("sign-in", style: TextStyle(fontSize: 14)).tr()),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(
            style: ButtonStyle(
              elevation: const MaterialStatePropertyAll(0),
              minimumSize: const MaterialStatePropertyAll(Size.fromHeight(45)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(15))),
              backgroundColor:
                  const MaterialStatePropertyAll(Colors.transparent),
            ),
            onPressed: () => context
                .read<AuthFormBloc>()
                .add(const ChangeFormMode(AuthFormMode.signUp)),
            child: Text(
              "sign-up",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ).tr()),
      ]),
    );
  }

  void _submit() {
    if (formKey.currentState?.validate() ?? false) {
      context
          .read<AuthFormBloc>()
          .add(SubmitAuthForm(passwordController.text, emailController.text));
    }
  }
}

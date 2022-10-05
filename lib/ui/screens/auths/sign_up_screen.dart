import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/widgets/netflox_asset_icon.dart';
import 'package:nil/nil.dart';
import '../../../data/blocs/account/auth/auth_form/auth_event.dart';
import '../../../data/blocs/account/auth/auth_form/auth_form_bloc.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Form(
      key: formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const NetfloxAssetIcon(),
        const Text(
          "sign-up",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ).tr(),
        const SizedBox(
          height: 15,
        ),
        const Text(
          "sign-up-desc",
          textAlign: TextAlign.center,
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
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              filled: true,
              hintText: "password-hint".tr(context),
              contentPadding: const EdgeInsets.symmetric(horizontal: 25),
              prefixIcon: Icon(
                Icons.lock,
                color: Theme.of(context).hintColor,
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
          height: 25,
        ),
        TextFormField(
          controller: confirmPasswordController,
          maxLines: 1,
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return "fill-out-this-field".tr(context);
            }
            if (value != passwordController.text) {
              return "passwords-not-matching".tr(context);
            }
            return null;
          },
          obscureText: true,
          textInputAction: TextInputAction.send,
          decoration: InputDecoration(
              filled: true,
              hintText: "confirm-password-hint".tr(context),
              contentPadding: const EdgeInsets.symmetric(horizontal: 25),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Theme.of(context).hintColor,
              ),
              suffixIcon: ValueListenableBuilder(
                  valueListenable: confirmPasswordController,
                  builder: ((context, value, child) {
                    if (value.text.isNotEmpty) {
                      return IconButton(
                          onPressed: () => confirmPasswordController.clear(),
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
                style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(
                      vertical: 5,
                    )),
                    minimumSize: MaterialStatePropertyAll(Size.zero)),
                onPressed: () => context
                    .read<AuthFormBloc>()
                    .add(const ChangeFormMode(AuthFormMode.signIn)),
                child: const Text("already-have-account").tr()),
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
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                context.read<AuthFormBloc>().add(SubmitAuthForm(
                    passwordController.text, emailController.text));
              }
            },
            child: const Text("sign-up", style: TextStyle(fontSize: 14)).tr())
      ]),
    );
  }
}

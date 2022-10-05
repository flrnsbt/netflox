import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

import 'package:nil/nil.dart';

import '../../../data/blocs/account/auth/auth_cubit.dart';
import '../../../data/blocs/account/auth/auth_form/auth_event.dart';
import '../../../data/blocs/account/auth/auth_form/auth_form_bloc.dart';

class ReauthenticateScreen extends StatelessWidget {
  const ReauthenticateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.isAuthenticated()) {
          final emailController = TextEditingController(
              text: context.read<AuthCubit>().state.user!.email!);
          final passwordController = TextEditingController();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "sign-in-again",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ).tr(),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "sign-in-again-desc",
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
                    readOnly: true,
                    decoration: InputDecoration(
                        filled: true,
                        hintText: "Your E-mail Address",
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 25),
                        prefixIcon: Icon(
                          Icons.email,
                          color: Theme.of(context).hintColor,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15))),
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
                        return "Please fill out this field";
                      }
                      return null;
                    },
                    autofocus: true,
                    obscureText: true,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                        filled: true,
                        hintText: "Your Password",
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 25),
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
                            borderRadius: BorderRadius.circular(15))),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          context.read<AuthFormBloc>().add(ReauthenticateEvent(
                              password: passwordController.text));
                        }
                      },
                      style: ButtonStyle(
                          minimumSize: const MaterialStatePropertyAll(
                              Size.fromHeight(45)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)))),
                      child: const Text("Confirm"))
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}

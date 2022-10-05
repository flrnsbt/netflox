import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [const Text("forgot-password").tr()],
                ))));
  }
}

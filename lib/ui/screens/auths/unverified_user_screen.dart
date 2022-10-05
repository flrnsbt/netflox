import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

class UnverifiedUserScreen extends StatelessWidget {
  const UnverifiedUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                    height: 100,
                    child: Image.asset(
                      'assets/images/user_verification.gif',
                      fit: BoxFit.contain,
                    )),
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  "verification-on-process",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ).tr(),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "verification-on-process-desc",
                  textAlign: TextAlign.center,
                ).tr()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

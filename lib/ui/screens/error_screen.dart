import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/exception.dart';

class ErrorScreen extends StatelessWidget {
  final Object error;
  final bool showTitle;
  final Widget? child;
  const ErrorScreen(
      {Key? key, Object? error, this.showTitle = true, this.child})
      : error = error ?? const NetfloxException(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTitle)
                const Text(
                  "error",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ).tr(),
              const SizedBox(
                height: 10,
              ),
              _buildMessageError(context),
              if (child != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: child!,
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageError(BuildContext context) {
    String errorMessage = "";
    if (error is List) {
      for (var e in error as List) {
        errorMessage += "$e\n";
      }
    } else {
      errorMessage = error.toString().tr(context);
    }
    return Text(
      errorMessage,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16),
    );
  }
}

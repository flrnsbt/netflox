import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

void showSnackBar(BuildContext context,
    {required String text,
    Widget? leading,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 10)}) {
  final snackBar = SnackBar(
    margin: const EdgeInsets.only(bottom: 25, right: 25, left: 25),
    content: Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    ),
    duration: duration,
    backgroundColor: Theme.of(context).cardColor,
    behavior: SnackBarBehavior.floating,
    action: action ??
        SnackBarAction(
          label: 'dismiss'.tr(context),
          textColor: Theme.of(context).primaryColor,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
  );
  try {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } catch (e) {
    //
  }
}

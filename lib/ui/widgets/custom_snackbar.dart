import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

void showSnackBar(BuildContext context,
    {required String text,
    Widget? leading,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 10)}) {
  final snackBar = SnackBar(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
    margin: const EdgeInsets.only(bottom: 25, right: 25, left: 25),
    content: AutoSizeText(
      text,
      maxLines: 3,
      wrapWords: false,
      minFontSize: 8,
      style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
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

  ScaffoldMessenger.maybeOf(context)?.clearSnackBars();

  ScaffoldMessenger.maybeOf(context)?.showSnackBar(snackBar);
}

import 'package:flutter/material.dart';

class RefreshButton extends StatelessWidget {
  final void Function()? onPressed;
  const RefreshButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        shape: const CircleBorder(),
        onPressed: onPressed,
        elevation: 0,
        padding: const EdgeInsets.all(15),
        color: Theme.of(context).focusColor,
        child: Icon(
          Icons.refresh,
          color: Theme.of(context).hintColor,
          size: 25,
        ));
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';

class NetfloxBackButton extends StatelessWidget {
  const NetfloxBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.router.canNavigateBack && !kIsWeb) {
      return MaterialButton(
        onPressed: () {
          Navigator.pop(context);
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        minWidth: 0,
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      );
    }
    return const Nil();
  }
}

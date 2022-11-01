import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router/router.gr.dart';

class HomeButton extends StatelessWidget {
  final Color? color;
  const HomeButton({Key? key, this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (_previousRouteIsRoot(context)) {
      return IconButton(
          onPressed: () {
            if (_hasHomeRouteInStack(context)) {
              context.router.popUntilRoot();
            } else {
              context.router.replaceAll([const StackRoute()]);
            }
          },
          icon: Icon(
            Icons.home,
            color: color,
          ));
    }
    return const SizedBox.shrink();
  }

  bool _previousRouteIsRoot(BuildContext context) {
    if (!_hasHomeRouteInStack(context)) {
      return false;
    }
    return context.router.pageCount > 2;
  }

  bool _hasHomeRouteInStack(BuildContext context) {
    return context.router.root.current.name == StackRoute.name;
  }
}

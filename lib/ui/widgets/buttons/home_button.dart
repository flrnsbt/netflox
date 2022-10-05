import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router/router.gr.dart';

class HomeButton extends StatefulWidget {
  final Color? color;
  const HomeButton({Key? key, this.color}) : super(key: key);

  @override
  State<HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  bool _mainRouteInStack = true;

  @override
  Widget build(BuildContext context) {
    if (!_previousIsMainRoute()) {
      return IconButton(
          onPressed: () {
            if (_mainRouteInStack) {
              context.router.popUntilRoot();
            } else {
              context.router.replaceAll([const StackRoute()]);
            }
          },
          icon: Icon(
            Icons.home,
            color: widget.color,
          ));
    }
    return const SizedBox.shrink();
  }

  @override
  void initState() {
    super.initState();
    _mainRouteInStack = context.router.stack.first.name == "TabHomeRoute";
  }

  bool _previousIsMainRoute() {
    if (!_mainRouteInStack) {
      return false;
    }
    return context.router.stack.length <= 2;
  }
}

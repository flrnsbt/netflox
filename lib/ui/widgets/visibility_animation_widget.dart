import 'package:flutter/material.dart';

class VisibilityAnimationWidget extends StatefulWidget {
  const VisibilityAnimationWidget(
      {super.key, this.controller, required this.child});
  final EasyVisibilityController? controller;
  final Widget child;

  @override
  State<VisibilityAnimationWidget> createState() =>
      _VisibilityAnimationWidgetState();
}

class _VisibilityAnimationWidgetState extends State<VisibilityAnimationWidget>
    with TickerProviderStateMixin {
  late final AnimationController _visibility;

  @override
  void initState() {
    super.initState();
    _visibility = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 300));
    widget.controller?.addListener(_visibilityControllerListener);
  }

  void _visibilityControllerListener() {
    if (widget.controller!.isShowing()) {
      _visibility.forward();
    } else {
      _visibility.reverse();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_visibilityControllerListener);
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        builder: (context, value, child) {
          if (value == 0) {
            return const SizedBox.shrink();
          }
          return Transform.scale(scale: value, child: child);
        },
        valueListenable: _visibility,
        child: widget.child);
  }
}

class EasyVisibilityController extends ChangeNotifier {
  bool _show;

  bool isShowing() => _show;

  set __show(bool show) {
    _show = show;
    notifyListeners();
  }

  void show() => __show = true;
  void hide() => __show = false;

  EasyVisibilityController({
    bool show = false,
  }) : _show = show;
}

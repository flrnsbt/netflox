import 'package:flutter/material.dart';

class AnimatedIconButton extends StatefulWidget {
  final AnimatedIconData icon;
  final void Function()? onPressed;
  final bool defaultValue;
  const AnimatedIconButton(
      {Key? key, required this.icon, this.onPressed, this.defaultValue = false})
      : super(key: key);

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
  late final _animation =
      CurvedAnimation(parent: _animationController, curve: Curves.linear);
  late bool _flag = widget.defaultValue;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          if (widget.onPressed != null) {
            widget.onPressed!();
          }
          if (_flag) {
            _animationController.reverse();
          } else {
            _animationController.forward();
          }
          _flag = !_flag;
        },
        icon: AnimatedIcon(icon: widget.icon, progress: _animation));
  }
}

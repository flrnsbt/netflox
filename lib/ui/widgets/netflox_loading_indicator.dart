import 'dart:math';

import 'package:flutter/material.dart';

class NetfloxLoadingIndicator extends StatefulWidget {
  const NetfloxLoadingIndicator({Key? key}) : super(key: key);

  @override
  State<NetfloxLoadingIndicator> createState() =>
      _NetfloxLoadingIndicatorState();
}

class _NetfloxLoadingIndicatorState extends State<NetfloxLoadingIndicator>
    with SingleTickerProviderStateMixin {
  final transform = Matrix4.identity()..setEntry(3, 2, 0.001);
  var _controller;
  var _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat(period: const Duration(milliseconds: 500), reverse: true);
    _animation = Matrix4Tween(
            begin: transform, end: transform.clone()..setRotationY(pi))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInToLinear));
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: SizedBox.square(dimension: 40, child: _build()));
  }

  Widget _build() {
    return AnimatedBuilder(
      animation: _animation,
      child: Image.asset(
        "assets/icons/netflox_letter.png",
        fit: BoxFit.scaleDown,
      ),
      builder: (context, child) {
        return Transform(
          transform: _animation.value,
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

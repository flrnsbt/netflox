import 'package:flutter/material.dart';

class NetfloxBackgroundImage extends StatelessWidget {
  final Widget child;
  final Widget? Function(BuildContext context)? backgroundImage;
  final double opacityStrength;
  final bool overlay;
  final Color? color;

  NetfloxBackgroundImage(
      {super.key,
      required this.child,
      this.backgroundImage,
      this.color,
      double opacityStrength = 0.8,
      this.overlay = true})
      : opacityStrength = opacityStrength.clamp(0, 1);

  Widget _buildOverlay(BuildContext context) {
    final color = this.color ?? Theme.of(context).scaffoldBackgroundColor;
    final backgroundImage = this.backgroundImage?.call(context);
    return ShaderMask(
        shaderCallback: (Rect rect) {
          return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [
                0,
                0.5,
                1
              ],
              colors: [
                color.withOpacity(opacityStrength),
                color.withOpacity(opacityStrength - 0.2),
                color
              ]).createShader(rect);
        },
        blendMode: BlendMode.srcOver,
        child: backgroundImage);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      if (overlay && backgroundImage != null) _buildOverlay(context),
      child
    ]);
  }
}

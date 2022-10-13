import 'package:flutter/material.dart';

class FadedEdgeWidget extends StatelessWidget {
  final Widget child;
  final Axis axis;
  final double startStop;
  final double endStop;
  final bool show;
  final Color? color;
  const FadedEdgeWidget(
      {Key? key,
      required this.child,
      this.show = true,
      this.startStop = 0.1,
      this.endStop = 0.1,
      this.color,
      this.axis = Axis.vertical})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).backgroundColor;
    if (show) {
      final begin =
          axis == Axis.vertical ? Alignment.topCenter : Alignment.centerLeft;
      final end = axis == Axis.vertical
          ? Alignment.bottomCenter
          : Alignment.centerRight;
      final colors = [color, Colors.transparent, Colors.transparent, color];
      return ShaderMask(
          shaderCallback: (Rect rect) {
            return LinearGradient(
              begin: begin,
              end: end,
              colors: colors,
              stops: [0.0, startStop, 1 - endStop, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,
          child: child);
    }
    return child;
  }
}

import 'package:flutter/material.dart';

class FadedEdgeWidget extends StatelessWidget {
  final Widget child;
  final Axis axis;
  final EdgeInsets ratio;
  final bool show;
  const FadedEdgeWidget(
      {Key? key,
      required this.child,
      this.show = true,
      this.ratio = const EdgeInsets.symmetric(vertical: 0.1),
      this.axis = Axis.vertical})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (show) {
      final begin =
          axis == Axis.vertical ? Alignment.topCenter : Alignment.centerLeft;
      final end = axis == Axis.vertical
          ? Alignment.bottomCenter
          : Alignment.centerRight;
      final colors = [
        Colors.black87,
        Colors.transparent,
        Colors.transparent,
        Colors.black87
      ];
      final beginStop = axis == Axis.horizontal ? ratio.left : ratio.top;
      final endStop = axis == Axis.horizontal ? ratio.right : ratio.bottom;
      return ShaderMask(
          shaderCallback: (Rect rect) {
            return LinearGradient(
              begin: begin,
              end: end,
              colors: colors,
              stops: [0.0, beginStop, 1 - endStop, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,
          child: child);
    }
    return child;
  }
}

import 'package:flutter/material.dart';

class FadedEdgeWidget extends StatelessWidget {
  final Widget child;
  final Axis axis;
  final EdgeInsets ratio;
  final bool show;
  final Color color;
  FadedEdgeWidget(
      {Key? key,
      required this.child,
      this.show = true,
      EdgeInsets? ratio,
      this.color = Colors.black87,
      this.axis = Axis.vertical})
      : ratio = ratio ??
            EdgeInsets.symmetric(
              vertical: axis == Axis.vertical ? 0.1 : 0,
              horizontal: axis == Axis.horizontal ? 0.1 : 0,
            ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (show) {
      final begin =
          axis == Axis.vertical ? Alignment.topCenter : Alignment.centerLeft;
      final end = axis == Axis.vertical
          ? Alignment.bottomCenter
          : Alignment.centerRight;
      final colors = [color, Colors.transparent, Colors.transparent, color];
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

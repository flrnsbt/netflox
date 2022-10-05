import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DefaultShimmer extends StatelessWidget {
  const DefaultShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
        gradient: LinearGradient(colors: [
          Theme.of(context).canvasColor,
          Theme.of(context).highlightColor
        ], stops: const [
          0,
          0.5
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        child: const Material());
  }
}

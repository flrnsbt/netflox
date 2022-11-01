import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DefaultShimmer extends StatelessWidget {
  final Widget? child;
  const DefaultShimmer({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        period: const Duration(seconds: 2),
        highlightColor: Theme.of(context).canvasColor,
        baseColor: Theme.of(context).cardColor,
        child: child ?? const Material());
  }
}

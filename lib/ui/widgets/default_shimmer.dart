import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DefaultShimmer extends StatelessWidget {
  const DefaultShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        period: const Duration(seconds: 2),
        highlightColor: Theme.of(context).disabledColor,
        baseColor: Theme.of(context).highlightColor,
        child: const Material());
  }
}

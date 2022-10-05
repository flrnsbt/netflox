import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_grid.dart';

class DefaultSliverGrid extends StatelessWidget {
  final SliverChildBuilderDelegate sliverChildBuilderDelegate;
  const DefaultSliverGrid(
      {super.key, required this.sliverChildBuilderDelegate});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: defaultGridDelegate,
      delegate: sliverChildBuilderDelegate,
    );
  }

  static const defaultGridDelegate = ResponsiveGridDelegate(
      childAspectRatio: 2 / 3,
      minCrossAxisExtent: 100,
      maxCrossAxisExtent: 200,
      mainAxisSpacing: 20,
      crossAxisSpacing: 10);
}

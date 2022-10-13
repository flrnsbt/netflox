import 'package:flutter/material.dart';
import 'package:netflox/data/constants/app_configuration.dart';
import 'package:responsive_framework/responsive_grid.dart';

class DefaultSliverGrid extends StatelessWidget {
  final SliverChildBuilderDelegate sliverChildBuilderDelegate;
  final SliverGridDelegate? gridDelegate;
  final EdgeInsets padding;
  const DefaultSliverGrid(
      {super.key,
      this.gridDelegate,
      this.padding = const EdgeInsets.only(top: 5),
      required this.sliverChildBuilderDelegate})
      : _pageSize = null;
  final int? _pageSize;
  const DefaultSliverGrid.paged(
      {super.key,
      required this.sliverChildBuilderDelegate,
      this.padding = const EdgeInsets.only(top: 5),
      int pageSize = kDefaultPageItemNumber})
      : _pageSize = pageSize,
        gridDelegate = null;

  @override
  Widget build(BuildContext context) {
    var gridDelegate = this.gridDelegate;
    if (_pageSize != null) {
      gridDelegate =
          defaultPagedGridDelegate(context, pageItemNumber: _pageSize!);
    }
    if (gridDelegate == null) {
      final crossAxisCount =
          (MediaQuery.of(context).size.width ~/ 200).clamp(2, 7);
      gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 2 / 3,
          mainAxisSpacing: 15,
          crossAxisSpacing: 20);
    }
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: gridDelegate,
        delegate: sliverChildBuilderDelegate,
      ),
    );
  }

  static const defaultGridDelegate = ResponsiveGridDelegate(
      childAspectRatio: 2 / 3,
      minCrossAxisExtent: 100,
      maxCrossAxisExtent: 200,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20);

  static SliverGridDelegateWithFixedCrossAxisCount defaultPagedGridDelegate(
      BuildContext context,
      {int pageItemNumber = kDefaultPageItemNumber,
      double maximumSize = 150,
      bool mustBeMultiple = false}) {
    final screenSize = MediaQuery.of(context).size;
    int crossCount =
        (screenSize.width ~/ maximumSize).clamp(1, pageItemNumber ~/ 2);

    if (mustBeMultiple && pageItemNumber % crossCount != 0) {
      crossCount = _getNearestDivider(pageItemNumber, crossCount);
    }

    final double crossSpacing = (40 / crossCount).clamp(5, 40);

    return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        childAspectRatio: 2 / 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: crossSpacing);
  }

  static int _getNearestDivider(int of, int from) {
    // final int adder = from > of / 2 ? -1 : 1;
    while (of % from != 0) {
      // from += adder;
      from--;
    }
    return from;
  }
}

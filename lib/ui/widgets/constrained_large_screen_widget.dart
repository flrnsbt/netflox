import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ConstrainedLargeScreenWidget extends StatelessWidget {
  final Widget child;

  const ConstrainedLargeScreenWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ResponsiveWrapper(
          maxWidth: 600,
          maxWidthLandscape: 800,
          shrinkWrap: false,
          breakpointsLandscape: const [
            ResponsiveBreakpoint.resize(300, name: MOBILE),
            ResponsiveBreakpoint.autoScale(600, scaleFactor: 1.2, name: TABLET),
            ResponsiveBreakpoint.resize(1000, name: DESKTOP),
            ResponsiveBreakpoint.resize(1700, scaleFactor: 1.2, name: "XL"),
          ],
          child: child),
    );
  }
}

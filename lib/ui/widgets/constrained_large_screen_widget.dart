import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ConstrainedLargeScreenWidget extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double maxWidthLandscape;

  const ConstrainedLargeScreenWidget({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.maxWidthLandscape = 800,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ResponsiveWrapper(
          maxWidth: maxWidth,
          maxWidthLandscape: maxWidthLandscape,
          alignment: Alignment.center,
          shrinkWrap: false,
          breakpointsLandscape: const [
            ResponsiveBreakpoint.resize(300, name: MOBILE),
            ResponsiveBreakpoint.autoScale(600, scaleFactor: 1.2, name: TABLET),
            ResponsiveBreakpoint.resize(1000, name: DESKTOP),
            ResponsiveBreakpoint.resize(1700, scaleFactor: 1.2, name: "XL"),
          ],
          breakpoints: const [
            ResponsiveBreakpoint.resize(300, name: MOBILE),
            ResponsiveBreakpoint.resize(600, name: TABLET),
            ResponsiveBreakpoint.autoScale(1000,
                scaleFactor: 1.4, name: DESKTOP),
            ResponsiveBreakpoint.resize(1700, scaleFactor: 1.5, name: "XL"),
          ],
          child: child),
    );
  }
}

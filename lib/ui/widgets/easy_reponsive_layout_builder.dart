import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobileLayoutBuilder;
  final Widget Function(BuildContext context) layoutBuilder;

  const ResponsiveLayoutBuilder(
      {super.key,
      required this.mobileLayoutBuilder,
      required this.layoutBuilder});

  @override
  Widget build(BuildContext context) {
    if (ResponsiveWrapper.of(context).isLargerThan(MOBILE)) {
      return layoutBuilder(context);
    } else {
      return mobileLayoutBuilder(context);
    }
  }
}

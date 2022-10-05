import 'package:flutter/cupertino.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

extension ResponsiveDimension on num {
  double h(BuildContext context) =>
      ResponsiveWrapper.of(context).screenHeight * this / 100;

  double w(BuildContext context) =>
      ResponsiveWrapper.of(context).screenWidth * this / 100;

  double hw(BuildContext context) =>
      (ResponsiveWrapper.of(context).screenHeight +
          ResponsiveWrapper.of(context).screenWidth) /
      2 *
      this /
      100;

  double sp(BuildContext context) => hw(context) / 3;
}

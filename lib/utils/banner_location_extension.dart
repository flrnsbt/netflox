import 'package:flutter/widgets.dart';

extension BannerLocationExtension on BannerLocation {
  bool isBottom() =>
      this == BannerLocation.bottomStart || this == BannerLocation.bottomEnd;

  bool isTop() => !isBottom();
}

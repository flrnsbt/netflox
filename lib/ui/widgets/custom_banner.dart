import 'dart:math';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/library_media_information.dart';
import 'package:netflox/utils/banner_location_extension.dart';

const double _kHeight = 16.0;

const Color _kColor = Colors.pink;
const TextStyle _kTextStyle = TextStyle(
  color: Color(0xFFFFFFFF),
  fontSize: _kHeight,
  fontWeight: FontWeight.w900,
  height: 1.0,
);

class CustomBanner extends StatelessWidget {
  final Widget? child;

  // if height is null, the banner will be sized to fit the child proportionally
  final double height;

  final double? offset;

  final String message;

  final BannerLocation location;

  final Color color;

  final TextStyle textStyle;

  factory CustomBanner.fromOptions(CustomBannerOptions options,
      [Widget? child]) {
    return CustomBanner(
      message: options.message,
      location: options.location,
      color: options.color,
      textStyle: options.textStyle,
      height: options.height,
      offset: options.offset,
      child: child,
    );
  }

  const CustomBanner(
      {super.key,
      required this.message,
      required this.location,
      required this.color,
      required this.textStyle,
      this.height = _kHeight,
      this.offset,
      this.child});

  @override
  Widget build(BuildContext context) {
    final offset = this.offset ?? message.length * 0.8 + height * 2.2;
    return ClipRect(
      child: CustomPaint(
        foregroundPainter: CustomBannerPainter(
          height: height,
          offset: offset,
          message: message,
          textDirection: Directionality.of(context),
          location: location,
          layoutDirection: Directionality.of(context),
          color: color,
          textStyle: textStyle.copyWith(fontSize: height * 0.6),
        ),
        child: child,
      ),
    );
  }
}

class CustomBannerPainter extends CustomPainter {
  CustomBannerPainter({
    required this.message,
    required this.textDirection,
    required this.location,
    required this.layoutDirection,
    this.height = _kHeight,
    this.offset = _kHeight * 2.5,
    this.color = _kColor,
    this.textStyle = _kTextStyle,
  }) : super(repaint: PaintingBinding.instance.systemFonts);

  final String message;
  final TextDirection textDirection;
  final double offset;
  final double height;

  final BannerLocation location;
  final TextDirection layoutDirection;

  final Color color;
  final TextStyle textStyle;

  static const BoxShadow _shadow =
      BoxShadow(color: Color(0x7F000000), blurRadius: 6.0, spreadRadius: 10);

  bool _prepared = false;
  late TextPainter _textPainter;
  late Paint _paintShadow;
  late Paint _paintBanner;

  void _prepare() {
    _paintShadow = _shadow.toPaint();
    _paintBanner = Paint()..color = color;
    _textPainter = TextPainter(
      text: TextSpan(style: textStyle, text: message),
      textAlign: TextAlign.center,
      textDirection: textDirection,
    );
    _prepared = true;
  }

  double get _kBottomOffset => offset + 0.3 * height;
  Rect get _kRect =>
      Rect.fromLTWH(-offset, offset - height, offset * 2.0, height);

  @override
  void paint(Canvas canvas, Size size) {
    if (!_prepared) {
      _prepare();
    }
    canvas
      ..translate(_translationX(size.width), _translationY(size.height))
      ..rotate(_rotation)
      ..drawRect(_kRect, _paintShadow)
      ..drawRect(_kRect, _paintBanner);
    final double width = offset * 2.0;
    _textPainter.layout(minWidth: width, maxWidth: width);
    _textPainter.paint(
        canvas,
        _kRect.topLeft +
            Offset(0.0, (_kRect.height - _textPainter.height) / 2.0));
  }

  @override
  bool shouldRepaint(CustomBannerPainter oldDelegate) {
    return message != oldDelegate.message ||
        location != oldDelegate.location ||
        color != oldDelegate.color ||
        textStyle != oldDelegate.textStyle;
  }

  @override
  bool hitTest(Offset position) => false;

  double _translationX(double width) {
    switch (layoutDirection) {
      case TextDirection.rtl:
        switch (location) {
          case BannerLocation.bottomEnd:
            return _kBottomOffset;
          case BannerLocation.topEnd:
            return 0.0;
          case BannerLocation.bottomStart:
            return width - _kBottomOffset;
          case BannerLocation.topStart:
            return width;
        }
      case TextDirection.ltr:
        switch (location) {
          case BannerLocation.bottomEnd:
            return width - _kBottomOffset;
          case BannerLocation.topEnd:
            return width;
          case BannerLocation.bottomStart:
            return _kBottomOffset;
          case BannerLocation.topStart:
            return 0.0;
        }
    }
  }

  double _translationY(double height) {
    if (location.isBottom()) {
      return height - _kBottomOffset;
    } else {
      return 0;
    }
  }

  double get _rotation {
    switch (layoutDirection) {
      case TextDirection.rtl:
        switch (location) {
          case BannerLocation.bottomStart:
          case BannerLocation.topEnd:
            return -pi / 4.0;
          case BannerLocation.bottomEnd:
          case BannerLocation.topStart:
            return pi / 4.0;
        }
      case TextDirection.ltr:
        switch (location) {
          case BannerLocation.bottomStart:
          case BannerLocation.topEnd:
            return pi / 4.0;
          case BannerLocation.bottomEnd:
          case BannerLocation.topStart:
            return -pi / 4.0;
        }
    }
  }
}

class CustomBannerOptions {
  final double height;
  final double? offset;

  final String message;

  final BannerLocation location;

  final Color color;

  final TextStyle textStyle;

  static CustomBannerOptions? mediaStatusBanner(
      BuildContext context, MediaStatus status) {
    if (status == MediaStatus.rejected || status == MediaStatus.unavailable) {
      return null;
    }
    final color = status == MediaStatus.available ? Colors.green : Colors.amber;
    return CustomBannerOptions(
        message: status.tr(context).toUpperCase(),
        color: color,
        location: BannerLocation.topEnd,
        textStyle: const TextStyle(
            color: Colors.black54,
            fontFamily: "Verdana",
            fontWeight: FontWeight.bold));
  }

  static const defaultNew = CustomBannerOptions(
      message: 'NEW', location: BannerLocation.topStart, color: Colors.pink);

  CustomBannerOptions copyWith({
    double? height,
    double? offset,
    String? message,
    BannerLocation? location,
    Color? color,
    TextStyle? textStyle,
  }) =>
      CustomBannerOptions(
          height: height ?? this.height,
          offset: offset ?? this.offset,
          message: message ?? this.message,
          location: location ?? this.location,
          color: color ?? this.color,
          textStyle: textStyle ?? this.textStyle);

  const CustomBannerOptions(
      {this.height = _kHeight,
      this.offset,
      required this.message,
      this.location = BannerLocation.topStart,
      this.color = _kColor,
      this.textStyle = const TextStyle(
          color: Colors.white,
          fontFamily: "Verdana",
          fontWeight: FontWeight.bold)});
}

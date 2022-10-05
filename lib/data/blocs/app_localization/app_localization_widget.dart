import 'package:flutter/material.dart';

import 'package:netflox/data/blocs/app_localization/extensions.dart';

class LocalizedText extends StatelessWidget implements Text {
  const LocalizedText(this.stringkey,
      {super.key,
      this.style,
      this.textAlign,
      this.maxLines,
      this.textDirection,
      this.locale,
      this.softWrap,
      this.overflow,
      this.textScaleFactor,
      this.semanticsLabel,
      this.textWidthBasis,
      this.data,
      this.selectionColor,
      this.strutStyle,
      this.textHeightBehavior,
      this.textSpan});

  final String stringkey;

  @override
  Widget build(context) {
    final data = stringkey.tr(context);
    return Text(data,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaleFactor: textScaleFactor,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        selectionColor: selectionColor,
        strutStyle: strutStyle,
        textHeightBehavior: textHeightBehavior);
  }

  @override
  final TextStyle? style;

  @override
  final TextAlign? textAlign;

  @override
  final int? maxLines;

  @override
  final TextDirection? textDirection;

  @override
  final Locale? locale;

  @override
  final bool? softWrap;

  @override
  final TextOverflow? overflow;

  @override
  final double? textScaleFactor;

  @override
  final String? semanticsLabel;

  @override
  final TextWidthBasis? textWidthBasis;

  factory LocalizedText.fromText(Text text) {
    return LocalizedText(
      text.data ?? "",
      key: text.key,
      style: text.style,
      textAlign: text.textAlign,
      maxLines: text.maxLines,
      textDirection: text.textDirection,
      locale: text.locale,
      softWrap: text.softWrap,
      overflow: text.overflow,
      textScaleFactor: text.textScaleFactor,
      semanticsLabel: text.semanticsLabel,
      textWidthBasis: text.textWidthBasis,
    );
  }

  @override
  final String? data;

  @override
  final Color? selectionColor;

  @override
  final StrutStyle? strutStyle;

  @override
  final TextHeightBehavior? textHeightBehavior;

  @override
  final InlineSpan? textSpan;
}

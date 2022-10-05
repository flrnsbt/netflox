import 'package:flutter/material.dart';

class FramedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  const FramedText({Key? key, required this.text, this.style, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(border: Border.all(color: c, width: 1)),
      child: Text(
        text.toUpperCase(),
        maxLines: 1,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: c,
        ).merge(style),
      ),
    );
  }
}

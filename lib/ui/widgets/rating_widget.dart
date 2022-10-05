import 'package:flutter/material.dart';

const kDefaultScoreWidgetHeight = 30.0;

class RatingWidget extends StatelessWidget {
  final num score;
  final double height;
  final Color? color;
  const RatingWidget(
      {Key? key,
      required this.score,
      this.height = kDefaultScoreWidgetHeight,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black26, width: 2)),
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              score.toStringAsFixed(1),
              maxLines: 1,
              style: const TextStyle(
                  color: Colors.black87,
                  fontFamily: "ArialBlack",
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

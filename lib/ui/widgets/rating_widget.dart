import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

const kDefaultScoreWidgetHeight = 18.0;

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
    return RatingBar.builder(
      itemSize: kDefaultScoreWidgetHeight,
      initialRating: score / 2,
      minRating: 0,
      direction: Axis.horizontal,
      ignoreGestures: true,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) =>
          Icon(Icons.star, color: Theme.of(context).primaryColor),
      onRatingUpdate: (double value) {},
    );
  }
}

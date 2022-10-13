import 'package:flutter/material.dart';

import '../../../../data/models/tmdb/media.dart';

class FavoriteButton extends StatelessWidget {
  final TMDBMedia media;
  const FavoriteButton({Key? key, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.favorite_border,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: () {},
    );
  }
}

import 'package:flutter/material.dart';
import 'package:netflox/data/models/tmdb/element.dart';

class DbElementCard<T extends TMDBElement> extends StatelessWidget {
  final T element;

  const DbElementCard({Key? key, required this.element}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(element.imgURL);
  }
}

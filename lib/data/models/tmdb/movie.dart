import 'package:flutter/material.dart';
import 'package:netflox/data/constants/movie_status.dart';
import 'element.dart';
import 'filter.dart';

class TMDBMovie extends TMDBElement {
  List<TMDBGenre> get genres => this['genres'];
  double get popularity => this['popularity'];
  String get title => this['title'];
  Locale get language => this['language'];
  String? get overview => this['overview'];
  DateTime get releaseDate => this['releaseDate'];
  // MovieStatus get movieStatus => this['movieStatus'] ?? MovieStatus.unavailable;

  TMDBMovie(super.map) {
    assert(containsKey('genres'));
    assert(containsKey('popularity'));
    assert(containsKey('title'));
    assert(containsKey('language'));
    // assert(containsKey('overview'));
    assert(containsKey('releaseDate'));
    // assert(containsKey('movieStatus'));
  }
}

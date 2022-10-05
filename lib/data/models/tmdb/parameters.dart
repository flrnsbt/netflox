// ignore_for_file: constant_identifier_names

import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/movie.dart';
import 'package:netflox/data/models/tmdb/tv.dart';

abstract class SortCriterion<T extends TMDBMultiMedia> {
  final String key;

  const SortCriterion(this.key);

  Comparable of(T object) {
    return object.get(key);
  }

  @override
  String toString() {
    return key;
  }
}

class LibrarySortCriterion extends SortCriterion<TMDBMultiMedia> {
  const LibrarySortCriterion._(super.key);
  static const addedOn = LibrarySortCriterion._('added_on');
}

class TMDBSortCriterion<T extends TMDBMultiMedia> extends SortCriterion<T> {
  static const popularity = TMDBSortCriterion._('popularity');
  static const releaseDate = TMDBSortCriterion._('release_date');
  static const voteAverage = TMDBSortCriterion._('vote_average');
  static const all = [popularity, releaseDate, voteAverage];

  const TMDBSortCriterion._(super.key);
}

class TMDBMovieSortCriterion extends TMDBSortCriterion<TMDBMovie> {
  const TMDBMovieSortCriterion._(String key) : super._(key);
  static const voteCount = TMDBMovieSortCriterion._('vote_count');
  static const title = TMDBMovieSortCriterion._('original_title');
  static const popularity = TMDBSortCriterion.popularity;
  static const releaseDate = TMDBSortCriterion.releaseDate;
  static const voteAverage = TMDBSortCriterion.voteAverage;
  static const all = [voteCount, title, ...TMDBSortCriterion.all];
}

mixin TMDBTVSortCriterion implements TMDBSortCriterion<TMDBTv> {
  static const popularity = TMDBSortCriterion.popularity;
  static const releaseDate = TMDBSortCriterion.releaseDate;
  static const voteAverage = TMDBSortCriterion.voteAverage;
  static const all = TMDBSortCriterion.all;
}

enum TimeWindow {
  week,
  day;
}

enum SortOrder {
  asc(1),
  desc(-1);

  final int factor;

  const SortOrder(this.factor);

  bool get isDescending => this == desc;

  @override
  String toString() {
    return name;
  }
}

class SortParameter<T extends TMDBMultiMedia> {
  final SortCriterion criterion;
  final SortOrder order;

  SortParameter({required this.criterion, this.order = SortOrder.desc});

  @override
  String toString() {
    return "${criterion.key}.${order.name}";
  }

  int comparator(T a, T b) {
    return criterion.of(a).compareTo(criterion.of(b)) * order.factor;
  }
}

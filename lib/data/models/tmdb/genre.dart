import 'package:netflox/data/models/tmdb/movie.dart';
import 'package:netflox/data/models/tmdb/tv.dart';

import 'media.dart';

enum TMDBMovieGenre with TMDBMultiMediaGenre<TMDBMovie> {
  action(28),
  adventure(12),
  animation(16),
  comedy(35),
  crime(80),
  documentary(99),
  drama(18),
  family(10751),
  fantasy(14),
  history(36),
  horror(27),
  music(10402),
  mystery(9648),
  romance(10749),
  scienceFiction(878),
  tvMovie(10770),
  thriller(53),
  war(10752),
  western(37);

  @override
  final int id;

  const TMDBMovieGenre(this.id);

  static TMDBMovieGenre? fromId(int id) {
    try {
      final value = values.singleWhere(
        (element) => element.id == id,
      );
      return value;
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return name;
  }
}

enum TMDBTVGenre with TMDBMultiMediaGenre<TMDBTv> {
  actionAndAdventure(10759),
  animation(16),
  comedy(35),
  crime(80),
  documentary(99),
  drama(18),
  family(10751),
  kids(10762),
  mystery(9648),
  news(10763),
  reality(10764),
  scifiAndFantasy(10765),
  soap(10766),
  talk(10767),
  warAndPolitics(10768),
  western(37);

  @override
  final int id;
  const TMDBTVGenre(this.id);

  static TMDBTVGenre? fromId(int id) {
    try {
      final value = values.singleWhere(
        (element) => element.id == id,
      );
      return value;
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return name;
  }
}

mixin TMDBMultiMediaGenre<T extends TMDBMultiMedia> on Enum {
  int get id;
}

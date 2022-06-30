import 'dart:ui';
import 'package:netflox/data/models/tmdb/element.dart';
import 'package:netflox/data/models/tmdb/movie.dart';
import 'package:netflox/data/models/tmdb/tv.dart';
import 'package:netflox/data/repositories/tmdb_repository.dart';

class TMDBService {
  final TMDBRepository _repository;

  const TMDBService(this._repository);

  Future<TMDBQueryResult<TMDBMovie>> getMovie(
      {required String movieId, Locale? language, bool? includeAdult}) async {
    try {
      final query = _repository.movie().getElement(movieId);
      if (language != null) {
        query.language(language);
      }
      if (includeAdult != null) {
        query.includeAdult(includeAdult);
      }
      return query.fetch();
    } catch (e) {
      rethrow;
    }
  }

  Future<TMDBQueryResult<TMDBTv>> getTvShow(
      {required String tvShowId, Locale? language, bool? includeAdult}) async {
    try {
      final query = _repository.tv().getElement(tvShowId);
      if (language != null) {
        query.language(language);
      }
      if (includeAdult != null) {
        query.includeAdult(includeAdult);
      }
      return query.fetch();
    } catch (e) {
      rethrow;
    }
  }

  Future<TMDBQueryResult<List<TMDBElement>>>? search(String searchTerms,
      {int? year, Locale? language, bool? includeAdult}) {
    final query = _repository.search();
    if (year != null) {
      query.year(year);
    }
    if (language != null) {
      query.language(language);
    }
    if (includeAdult != null) {
      query.includeAdult(includeAdult);
    }
    return query.query(searchTerms).fetch();
  }

  Future<TMDBQueryResult<List<TMDBMovie>>>? searchMovies(String searchTerms,
      {int? year, Locale? language, bool? includeAdult}) {
    final query = _repository.movie().search(searchTerms, year: year);
    if (language != null) {
      query.language(language);
    }
    if (includeAdult != null) {
      query.includeAdult(includeAdult);
    }
    final result = query.fetch();
    return result;
  }

  Future<TMDBQueryResult<List<TMDBTv>>>? searchTvShows(String searchTerms,
      {int? year, Locale? language, bool? includeAdult}) {
    final query = _repository.tv().search(searchTerms, year: year);
    if (language != null) {
      query.language(language);
    }
    if (includeAdult != null) {
      query.includeAdult(includeAdult);
    }
    return query.fetch();
  }

  Future<TMDBQueryResult<List<TMDBMovie>>>? getPopularMovies(
      {Locale? language}) {
    final query = _repository.movie().getPopulars();
    if (language != null) {
      query.language(language);
    }
    final result = query.fetch();
    return result;
  }

  Future<TMDBQueryResult<List<TMDBTv>>>? getPopularTvShows({Locale? language}) {
    final query = _repository.tv().getPopulars();
    if (language != null) {
      query.language(language);
    }
    final result = query.fetch();
    return result;
  }
}

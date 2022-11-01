import 'dart:io';
import 'dart:ui';

import 'package:netflox/data/models/tmdb/genre.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/people.dart';
import 'package:netflox/data/models/tmdb/season.dart';
import 'package:netflox/data/models/tmdb/type.dart';
import 'package:netflox/data/models/tmdb/movie.dart';
import 'package:netflox/data/models/tmdb/tv.dart';
import 'package:netflox/data/models/tmdb/video.dart';
import '../data/models/tmdb/filter_parameter.dart';
import '../data/repositories/tmdb_repository.dart';
import '../data/repositories/tmdb_result.dart';

class TMDBService {
  final String? defaultLanguage;
  final TMDBRepository _repository;

  TMDBService({required TMDBRepository repository, Locale? defaultLanguage})
      : _repository = repository,
        _client = HttpClient(),
        defaultLanguage = defaultLanguage?.languageCode;

  final HttpClient _client;

  Future<TMDBDocumentResult<TMDBMovie>> getMovie(
      {required String movieId, String? language}) async {
    final query = _repository
        .movie()
        .document(movieId)
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch();
    return result;
  }

  Future<TMDBDocumentResult<TMDBTv>> getTvShow(
      {required String tvShowId, String? language}) async {
    final query = _repository
        .tv()
        .document(tvShowId)
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch();
    return result;
  }

  Future<TMDBDocumentResult<TMDBTVEpisode>> getEpisode(
      {required String tvShowId,
      required int seasonNumber,
      required int episodeNumber,
      String? language}) async {
    final query = _repository
        .tv()
        .document(tvShowId)
        .getSeason(seasonNumber)
        .getEpisode(episodeNumber)
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch();
    return result;
  }

  Future<TMDBDocumentResult<TMDBTVSeason>> getSeason(
      {required String tvShowId,
      required int seasonNumber,
      String? language}) async {
    final query = _repository
        .tv()
        .document(tvShowId)
        .getSeason(seasonNumber)
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch();
    return result;
  }

  Future<TMDBDocumentResult<T>> getPrimaryMedia<T extends TMDBPrimaryMedia>(
      {required String id, required TMDBType<T> type, String? language}) async {
    final query = _repository
        .primaryMedia<T>(type)
        .document(id)
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch();
    return result;
  }

  Future<TMDBDocumentResult<T>> getMultimedia<T extends TMDBMultiMedia>(
      {required String id, required TMDBType<T> type, String? language}) async {
    final query = _repository
        .multimedia<T>(type)
        .document(id)
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch();
    return result;
  }

  Future<TMDBCollectionResult<T>> search<T extends TMDBPrimaryMedia>(
      String searchTerms,
      {TMDBType<T>? mediaType,
      String? language,
      int? year,
      num page = 1}) async {
    final query = _repository.search(mediaType);
    if (year != null && (mediaType?.isMultimedia() ?? false)) {
      query.year(year);
    }
    final collectionQuery = query.searchTerms(searchTerms);
    collectionQuery.setLanguage(language ?? defaultLanguage);
    final result = await collectionQuery.fetch(page: page);
    return result;
  }

  Future<TMDBCollectionResult<T>> discover<T extends TMDBMultiMedia>(
      TMDBType<T> mediaType,
      {SortParameter? sortParameter,
      List<TMDBMultiMediaGenre<T>>? genres,
      String? mediaLanguage,
      String? resultLanguage,
      int? year,
      num page = 1}) async {
    final query = _repository.discover<T>(mediaType);
    if (genres?.isNotEmpty ?? false) {
      final g = genres!.map((e) => e.id).join(",");
      query.withGenres(g);
    }
    if (year != null) {
      query.year(year);
    }
    if (mediaLanguage != null) {
      query.language(mediaLanguage);
    }
    if (sortParameter != null) {
      query.sort(sortParameter.toString());
    }
    final collectionQuery = query.submit();
    collectionQuery.setLanguage(resultLanguage ?? defaultLanguage);
    final result = await collectionQuery.fetch(page: page);
    return result;
  }

  Future<TMDBCollectionResult<T>> getPopulars<T extends TMDBPrimaryMedia>(
      {required TMDBType<T> mediaType, String? language, num page = 1}) async {
    final query = _repository
        .primaryMedia<T>(mediaType)
        .getPopulars()
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch(page: page);

    return result;
  }

  Future<TMDBCollectionResult<T>> getTopRated<T extends TMDBMultiMedia>(
      {required TMDBType<T> mediaType, String? language, num page = 1}) async {
    final query = _repository
        .multimedia<T>(mediaType)
        .getTopRated()
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch(page: page);

    return result;
  }

  Future<TMDBCollectionResult<T>> trending<T extends TMDBPrimaryMedia>(
      {required TMDBType<T> mediaType,
      TimeWindow timeWindow = TimeWindow.day,
      String? language,
      num page = 1}) async {
    final query = _repository
        .primaryMedia<T>(mediaType)
        .trending()
        .timeWindow(timeWindow)
        .get()
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch(page: page);

    return result;
  }

  Future<TMDBCollectionResult<T>> getRecommendations<T extends TMDBMultiMedia>(
      {required TMDBType<T> mediaType,
      required String id,
      String? language,
      num page = 1}) async {
    final query = _repository
        .multimedia<T>(mediaType)
        .document(id)
        .getRecommendations()
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch(page: page);

    return result;
  }

  Future<TMDBDocumentResult<List<TMDBVideo>>>
      getVideos<T extends TMDBMultiMedia>(
          {required TMDBType<T> mediaType,
          required String id,
          String? language}) async {
    final query = _repository
        .multimedia<T>(mediaType)
        .document(id)
        .getVideos()
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch();
    result.data?.sort();
    return result;
  }

  Future<TMDBCollectionResult<T>> getSimilars<T extends TMDBMultiMedia>(
      {required TMDBType<T> mediaType,
      required String id,
      String? language,
      num? page}) async {
    final query = _repository
        .multimedia<T>(mediaType)
        .document(id)
        .getSimilars()
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch(page: page);
    return result;
  }

  Future<TMDBDocumentResult<List<TMDBPerson>>> getLibraryMediaCredits(
      {required TMDBLibraryMedia media, String? language}) async {
    TMDBDocument<TMDBLibraryMedia> query;
    if (media.type.isMultimedia()) {
      query = _repository
          .multimedia((media as TMDBMultiMedia).type)
          .document(media.id);
    } else if (media.type.isTVElement()) {
      final showId = (media as TMDBTVElement).showId;
      dynamic q =
          _repository.tv().document(showId).getSeason(media.seasonNumber);
      if (media is TMDBTVEpisode) {
        q = q.getEpisode(media.episodeNumber);
      }
      query = q;
    } else {
      throw UnsupportedError('Incorrect media type');
    }

    final multiDocQuery =
        query.credits().setLanguage(language ?? defaultLanguage);
    final result = await multiDocQuery.fetch();
    return result;
  }

  Future<TMDBDocumentResult<List<TMDBMultiMedia>>> getPersonCasting(
      {required String id, String? language}) async {
    final query = _repository
        .people()
        .document(id)
        .credits()
        .setLanguage(language ?? defaultLanguage);

    final result = await query.fetch();
    return result;
  }

  void close([bool force = false]) {
    _client.close(force: force);
  }
}

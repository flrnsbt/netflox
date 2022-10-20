import 'dart:ui';

import 'package:netflox/data/models/tmdb/library_media_information.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/img.dart';
import 'package:netflox/data/models/tmdb/season.dart';
import '../../blocs/app_localization/app_localization_cubit.dart';
import 'genre.dart';
import 'type.dart';

class TMDBTv extends TMDBMultiMedia {
  final List<TMDBTVSeason> seasons;

  @override
  final TMDBImg? img;

  TMDBTv(super.id,
      {required this.name,
      required this.originalName,
      this.duration,
      this.img,
      List<TMDBTVSeason>? seasons,
      List<TMDBMultiMediaGenre<TMDBTv>>? genres,
      this.popularity,
      this.originalLanguage,
      this.backdropImg,
      this.productionCountries,
      this.overview,
      this.voteCount,
      this.date,
      this.voteAverage,
      LibraryMediaInformation? libraryInformation})
      : libraryMediaInfo = libraryInformation ??
            LibraryMediaInformation(id: id, type: TMDBType.tv),
        seasons = seasons ?? const [],
        genres = genres ?? const [];

  static Duration _getAverageDuration(List<int> durations) {
    int total = 0;
    for (final d in durations) {
      total += d;
    }
    return Duration(minutes: total ~/ durations.length);
  }

  factory TMDBTv.fromMap(Map<String, dynamic> map) {
    final genres = <TMDBTVGenre>[];
    final genreIds = map['genre_ids'] ?? map['genres']?.map(((e) => e['id']));
    if (genreIds != null) {
      for (var id in genreIds) {
        final genre = TMDBTVGenre.fromId(id);
        if (genre != null) {
          genres.add(genre);
        }
      }
    }
    Duration? duration;
    final durations = map["episode_run_time"];
    if (durations != null && durations.isNotEmpty) {
      duration = _getAverageDuration(durations.cast<int>());
    }
    TMDBImg? img;
    TMDBImg? backdropImg;
    String? posterPath = map['poster_path'];
    String? backdropPath = map['backdrop_path'];
    if (posterPath != null) {
      img = TMDBImg(posterPath, TMDBImageType.poster);
    }
    if (backdropPath != null) {
      backdropImg = TMDBImg(backdropPath, TMDBImageType.backdrop);
    }
    final id = map['id'].toString();

    return TMDBTv(id,
        name: map['name'],
        originalName: map['original_name'],
        voteAverage: map['vote_average'],
        voteCount: map['vote_count'],
        duration: duration,
        img: img,
        backdropImg: backdropImg,
        genres: genres,
        popularity: map['popularity'],
        seasons: map['seasons']
            ?.map<TMDBTVSeason>(((e) => TMDBTVSeason.fromMap(e)))
            .toList(),
        productionCountries: map['production_countries']
            ?.map((e) => e["iso_3166_1"])
            .toList()
            .cast<String>(),
        originalLanguage: map['original_language'] != null
            ? localeFromString(map['original_language'])
            : null,
        overview: map['overview'],
        date: map['first_air_date']);
  }

  @override
  TMDBType<TMDBTv> get type => TMDBType.tv;

  @override
  String toString() {
    return 'TMDBTv(seasons: $seasons, genres: $genres, title: $name, originalLanguage: $originalLanguage, productionCountries: $productionCountries, overview: $overview, releaseDate: $date, duration: $duration, vote: $voteAverage)';
  }

  @override
  LibraryMediaInformation libraryMediaInfo;

  @override
  final TMDBImg? backdropImg;

  @override
  final String? date;

  @override
  final List<TMDBMultiMediaGenre<TMDBTv>> genres;

  @override
  final String name;

  @override
  final Locale? originalLanguage;

  @override
  final String originalName;

  @override
  final String? overview;

  @override
  final List<String>? productionCountries;

  @override
  final num? popularity;

  @override
  final Duration? duration;

  @override
  final num? voteAverage;

  @override
  final int? voteCount;
}

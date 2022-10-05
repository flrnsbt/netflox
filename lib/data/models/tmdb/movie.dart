import 'dart:ui';

import 'package:netflox/data/blocs/app_localization/app_localization_cubit.dart';
import 'package:netflox/data/models/tmdb/library_media_information.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/img.dart';
import 'package:netflox/data/models/tmdb/type.dart';
import 'genre.dart';

class TMDBMovie extends TMDBMultiMedia
    with TMDBLibraryMedia, TMDBPlayableMedia {
  TMDBMovie(super.id,
      {this.img,
      this.genres = const [],
      this.popularity,
      required this.name,
      required this.originalName,
      this.originalLanguage,
      this.backdropImg,
      this.productionCountries,
      this.overview,
      this.duration,
      this.voteCount,
      this.date,
      this.voteAverage,
      LibraryMediaInformation? libraryMediaInfo})
      : libraryMediaInfo = libraryMediaInfo ??
            LibraryMediaInformation(id: id, type: TMDBType.movie);

  factory TMDBMovie.fromMap(Map<String, dynamic> map) {
    final genres = <TMDBMovieGenre>[];
    final genreIds = map['genre_ids'] ?? map['genres']?.map(((e) => e['id']));
    if (genreIds != null) {
      for (final id in genreIds) {
        final genre = TMDBMovieGenre.fromId(id);
        if (genre != null) {
          genres.add(genre);
        }
      }
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

    return TMDBMovie(map['id'].toString(),
        name: map['title'],
        originalName: map['original_title'],
        img: img,
        genres: genres,
        backdropImg: backdropImg,
        duration: map['runtime'],
        popularity: map['popularity'],
        voteAverage: map['vote_average'],
        voteCount: map['vote_count'],
        productionCountries: map['production_countries']
            ?.map((e) => e["iso_3166_1"])
            .toList()
            .cast<String>(),
        originalLanguage: map['original_language'] != null
            ? localeFromString(map['original_language'])
            : null,
        overview: map['overview'],
        date: map['release_date']);
  }

  @override
  String toString() {
    return 'TMDBMovie(genres: $genres, title: $name, originalLanguage: $originalLanguage, productionCountries: $productionCountries, overview: $overview, releaseDate: $date, duration: $duration, vote: $voteAverage)';
  }

  @override
  TMDBType<TMDBMovie> get type => TMDBType.movie;

  @override
  String get remoteFilePath => "$type/$id";

  @override
  LibraryMediaInformation libraryMediaInfo;

  @override
  final TMDBImg? img;

  @override
  final TMDBImg? backdropImg;

  @override
  final String? date;

  @override
  final List<TMDBMultiMediaGenre<TMDBMovie>> genres;

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
  final int? duration;

  @override
  final num? voteAverage;

  @override
  final int? voteCount;
}

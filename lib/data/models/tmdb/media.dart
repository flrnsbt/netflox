import 'package:flutter/material.dart';
import 'package:netflox/data/models/tmdb/people.dart';
import 'package:netflox/data/models/tmdb/img.dart';
import 'package:netflox/data/models/tmdb/season.dart';
import 'package:netflox/data/models/tmdb/tv.dart';
import 'element.dart';
import 'genre.dart';
import 'library_media_information.dart';
import 'movie.dart';
import 'type.dart';

enum PopularityLevel {
  hot,
  popular,
  trendy,
}

PopularityLevel? computePopularityLevel(num popularity) {
  if (popularity > 2000) {
    return PopularityLevel.hot;
  } else if (popularity > 1000) {
    return PopularityLevel.popular;
  } else if (popularity > 500) {
    return PopularityLevel.trendy;
  }
  return null;
}

class TMDBMediaEmpty extends TMDBMedia {
  TMDBMediaEmpty()
      : date = null,
        name = "",
        overview = null,
        super("");

  @override
  final TMDBType<TMDBMedia> type = TMDBPrimaryMediaType.any;

  @override
  final String? date;

  @override
  final String name;

  @override
  final String? overview;

  @override
  TMDBImg? img;
}

abstract class TMDBPrimaryMedia extends TMDBMedia with TMDBPopularityProvider {
  TMDBPrimaryMedia(super.id);

  String? get placeOfOrigin;

  String get originalName;

  @override
  TMDBType<TMDBPrimaryMedia> get type;

  static TMDBMedia fromMap(Map<String, dynamic> map) {
    final type = map['tmdb_type'] as TMDBType;

    try {
      if (type.isMultimedia()) {
        return TMDBMultiMedia.fromMap(map);
      } else {
        return TMDBPerson.fromJson(map);
      }
    } catch (e) {
      throw FormatException("Invalid TMDBPrimaryMedia type",
          "'$type' is not a valid TMDBPrimaryMedia (movie, tv, people)");
    }
  }
}

abstract class TMDBMedia extends TMDBElement
    with TMDBNameProvider, TMDBElementWithImage {
  @override
  TMDBType<TMDBMedia> get type;

  String? get overview;

  String? get date;

  int? get year => int.tryParse(date?.split('-').first ?? "");

  TMDBMedia(super.id);

  static TMDBMedia fromMap(Map<String, dynamic> map) {
    final type = map['tmdb_type'] as TMDBType;
    if (type.isPrimaryMedia()) {
      return TMDBPrimaryMedia.fromMap(map);
    } else {
      if (type.isTvEpisode()) {
        return TMDBTVEpisode.fromMap(map);
      } else if (type.isTvSeason()) {
        return TMDBTVSeason.fromMap(map);
      }
    }

    throw FormatException("Invalid TMDBMedia type",
        "'$type' is not a valid TMDBMediaType (movie, tv, people, tv_episode, tv_season)");
  }
}

mixin TMDBLibraryMedia on TMDBMedia {
  LibraryMediaInformation get libraryMediaInfo;
  set libraryMediaInfo(LibraryMediaInformation libraryMediaInfo);
  String get absolutePath;

  Map<String, dynamic> libraryIdMap() {
    return {'media_type': type.path, 'id': id};
  }
}

mixin TMDBPlayableMedia on TMDBLibraryMedia {
  Duration? get duration;
}

abstract class TMDBMultiMedia extends TMDBPrimaryMedia
    with TMDBLibraryMedia, Comparable<TMDBMultiMedia> {
  TMDBMultiMedia(super.id);

  TMDBImg? get backdropImg;

  static TMDBMultiMedia fromMap(Map<String, dynamic> map) {
    final type = map['tmdb_type'] as TMDBType;
    if (type.isMovie()) {
      return TMDBMovie.fromMap(map);
    } else if (type.isTV()) {
      return TMDBTv.fromMap(map);
    }

    throw FormatException("Invalid TMDBMedia type",
        "'$type' is not a valid TMDBMediaType (movie, tv, people)");
  }

  @override
  int compareTo(TMDBMultiMedia other) {
    return (other.popularity ?? 0).compareTo(popularity ?? 0);
  }

  List<TMDBMultiMediaGenre> get genres;
  Locale? get originalLanguage;
  List<String>? get productionCountries;

  MediaNewness? newness() {
    final d = DateTime.tryParse(date ?? "");
    final now = DateTime.now();
    if (d?.isAfter(now) ?? false) {
      return MediaNewness.coming;
    }
    if (d?.isAfter(now.subtract(const Duration(days: 30))) ?? false) {
      return MediaNewness.recent;
    }
    return null;
  }

  get(String key) => toMap()[key];

  Map<String, dynamic> toMap() {
    return {
      'original_title': originalName,
      'release_date': date,
      'popularity': popularity,
      'vote_average': voteAverage,
      'vote_count': voteCount
    };
  }

  @override
  String get absolutePath => "${type.path}/$id";

  Duration? get duration;
  num? get voteAverage;
  int? get voteCount;

  @override
  TMDBType<TMDBMultiMedia> get type;

  @override
  String? get placeOfOrigin => originalLanguage?.countryCode;
}

enum MediaNewness { recent, coming }

Color colorByMediaNewness(MediaNewness date) {
  switch (date) {
    case MediaNewness.coming:
      return Colors.yellow;
    case MediaNewness.recent:
      return Colors.pink;
  }
}

import 'package:netflox/data/models/tmdb/element.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/movie.dart';
import 'package:netflox/data/models/tmdb/people.dart';
import 'package:netflox/data/models/tmdb/season.dart';
import 'package:netflox/data/models/tmdb/tv.dart';
import 'package:netflox/data/models/tmdb/video.dart';
import 'package:netflox/utils/type_is_list_extension.dart';

mixin TMDBMultiMediaType {
  static const all = [movie, tv];
  static const movie = TMDBType.movie;
  static const tv = TMDBType.tv;
  static const any = TMDBType.multimedia;
  static const values = [...all, any];
}

mixin TMDBPrimaryMediaType {
  static const all = [movie, tv, person];
  static const movie = TMDBType.movie;
  static const tv = TMDBType.tv;
  static const person = TMDBType.person;
  static const any = TMDBType.primaryMedia;
  static const values = [...all, any];
}

mixin TMDBLibraryMediaType {
  static const all = [movie, tv, episode];
  static const movie = TMDBType.movie;
  static const tv = TMDBType.tv;
  static const episode = TMDBType.tvEpisode;
}

class TMDBType<T extends TMDBElement> {
  const TMDBType();

  static TMDBType fromType(Type element) {
    return values
        .singleWhere((e) => e.genericTypeName == element.genericTypeName);
  }

  bool isPeople() => T == TMDBPerson;
  bool isMovie() => T == TMDBMovie;
  bool isVideo() => T == TMDBVideo;
  bool isTV() => T == TMDBTv;
  bool isTvSeason() => T == TMDBTVSeason;
  bool isTvEpisode() => T == TMDBTVEpisode;
  bool isMedia() => isPrimaryMedia() || isTvSeason() || isTvEpisode();
  bool isMultimedia() => isMovie() || isTV();
  bool isPrimaryMedia() => isPeople() || isMovie() || isTV();

  static const video = TMDBType<TMDBVideo>();
  static const movie = TMDBType<TMDBMovie>();
  static const tv = TMDBType<TMDBTv>();
  static const person = TMDBType<TMDBPerson>();
  static const media = TMDBType<TMDBMedia>();
  static const primaryMedia = TMDBType<TMDBPrimaryMedia>();
  static const multimedia = TMDBType<TMDBMultiMedia>();
  static const tvSeason = TMDBType<TMDBTVSeason>();
  static const tvEpisode = TMDBType<TMDBTVEpisode>();
  static const any = TMDBType<TMDBElement>();

  static const values = <TMDBType>[
    video,
    tvSeason,
    tvEpisode,
    media,
    multimedia,
    ...TMDBPrimaryMediaType.values
  ];

  String get name {
    return T.genericTypeName.toLowerCase().replaceAll("tmdb", "");
  }

  @override
  String toString() {
    return path;
  }

  String get path {
    switch (T) {
      case TMDBPrimaryMedia:
      case TMDBMultiMedia:
        return 'multi';
      case TMDBVideo:
        return 'videos';
      case TMDBTVEpisode:
        return 'episode';
      case TMDBTVSeason:
        return 'season';
      default:
        return name;
    }
  }

  static TMDBType _defaultElse() => TMDBType.any;

  static TMDBType fromString(String? typeName,
      {TMDBType Function() orElse = _defaultElse}) {
    return values.singleWhere(
      (e) => e.name == typeName,
      orElse: orElse,
    );
  }
}

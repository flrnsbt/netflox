// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:netflox/data/models/tmdb/element.dart';
import 'package:netflox/data/models/tmdb/img.dart';
import 'package:netflox/data/models/tmdb/library_media_information.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/people.dart';
import 'package:netflox/data/models/tmdb/type.dart';

class TMDBTVSeason extends TMDBMedia with TMDBLibraryMedia {
  @override
  final String? overview;
  final int seasonNumber;
  final int? _episodeCount;
  final String showId;
  @override
  final String? date;
  final List<TMDBTVEpisode> episodes;

  @override
  final TMDBImg? img;

  @override
  get type => TMDBType.tvSeason;

  TMDBTVSeason(super.id,
      {this.img,
      this.overview,
      this.name,
      required this.showId,
      LibraryMediaInformation? libraryMediaInfo,
      List<TMDBTVEpisode>? episodes,
      this.seasonNumber = 1,
      int? episodeCount,
      this.date})
      : episodes = episodes ?? const [],
        libraryMediaInfo = libraryMediaInfo ??
            LibraryMediaInformation(id: id, type: TMDBType.tvSeason),
        _episodeCount = episodeCount;

  int get episodeCount => _episodeCount ?? episodes.length;

  factory TMDBTVSeason.fromMap(Map<String, dynamic> map) {
    TMDBImg? img;
    String? posterPath = map['poster_path'];
    if (posterPath != null) {
      img = TMDBImg(posterPath, TMDBImageType.poster);
    }
    final showId = map['show_id'].toString();
    return TMDBTVSeason(map['id'].toString(),
        img: img,
        name: map['name'],
        showId: showId,
        overview: map['overview'],
        episodes: map['episodes']
            ?.map<TMDBTVEpisode>(((e) =>
                TMDBTVEpisode.fromMap(e..putIfAbsent("show_id", () => showId))))
            .toList(),
        seasonNumber: map['season_number'],
        episodeCount: map['episode_count'],
        date: map['air_date']);
  }

  @override
  String toString() {
    return 'TMDBTVSeason(overview: $overview, seasonNumber: $seasonNumber, episodeCount: $episodeCount, date: $date, episodes: $episodes, img: $img)';
  }

  @override
  final String? name;

  @override
  LibraryMediaInformation libraryMediaInfo;

  @override
  String get libraryPath {
    return "$showId/seasons/$seasonNumber";
  }
}

class TMDBTVEpisode extends TMDBMedia
    with TMDBLibraryMedia, TMDBPlayableMedia, TMDBImageProvider {
  @override
  final String? overview;
  @override
  final String? name;
  final int seasonNumber;
  final int episodeNumber;
  @override
  final String? date;
  final num? voteAverage;
  final int? voteCount;
  final String showId;
  final List<TMDBPerson>? guests;

  @override
  get type => TMDBType.tvEpisode;

  TMDBTVEpisode(super.id,
      {this.overview,
      this.name,
      required this.seasonNumber,
      required this.episodeNumber,
      this.guests,
      this.date,
      this.duration,
      required this.showId,
      this.voteAverage,
      this.voteCount,
      this.img,
      LibraryMediaInformation? libraryMediaInfo})
      : libraryMediaInfo = libraryMediaInfo ??
            LibraryMediaInformation(id: id, type: TMDBType.tvEpisode);

  @override
  final TMDBImg? img;

  factory TMDBTVEpisode.fromMap(Map<String, dynamic> map) {
    TMDBImg? img;
    String? stillPath = map['still_path'];
    if (stillPath != null) {
      img = TMDBImg(stillPath, TMDBImageType.still);
    }
    return TMDBTVEpisode(
      map['id'].toString(),
      overview: map['overview'],
      showId: map['show_id'].toString(),
      name: map['name'],
      duration:
          map['duration'] != null ? Duration(minutes: map['duration']) : null,
      guests: map['guest_stars']
          ?.map<TMDBPerson>((e) => TMDBPerson.fromJson(e))
          .toList(),
      seasonNumber: map['season_number'],
      episodeNumber: map['episode_number'],
      date: map['air_date'],
      voteAverage: map['vote_average'],
      voteCount: map['vote_count'],
      img: img,
    );
  }

  @override
  String get libraryPath {
    return "$showId/seasons/$seasonNumber/episodes/$episodeNumber";
  }

  @override
  LibraryMediaInformation libraryMediaInfo;

  @override
  String? get remoteFilePath {
    return "tv/$libraryPath";
  }

  @override
  final Duration? duration;
}

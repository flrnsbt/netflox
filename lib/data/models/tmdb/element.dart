import 'package:equatable/equatable.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/img.dart';
import 'package:netflox/data/models/tmdb/season.dart';
import 'package:netflox/data/models/tmdb/type.dart';
import 'package:netflox/data/models/tmdb/video.dart';

abstract class TMDBElement with EquatableMixin {
  final String id;

  const TMDBElement(
    this.id,
  );

  TMDBType get type => TMDBType.fromType(runtimeType);

  @override
  List<Object> get props {
    return [id];
  }

  static TMDBElement fromMap(Map<String, dynamic> map) {
    try {
      final TMDBType type = map["tmdb_type"];
      switch (type) {
        case TMDBType.video:
          return TMDBVideo.fromJson(map);
        case TMDBType.tvEpisode:
          return TMDBTVEpisode.fromMap(map);
        case TMDBType.tvSeason:
          return TMDBTVSeason.fromMap(map);
        default:
          return TMDBMedia.fromMap(map);
      }
    } catch (e) {
      throw UnsupportedError('unsupported type ${map['type']}');
    }
  }

  @override
  String toString() => 'TMDBElement(id: $id)';
}

mixin TMDBVideoProvider on TMDBElement {
  List<TMDBVideo>? get videos;
}

mixin TMDBNameProvider on TMDBElement {
  String? get name;
}

mixin TMDBImageProvider on TMDBElement {
  TMDBImg? get img;
}

mixin TMDBPopularityProvider on TMDBElement {
  num? get popularity;

  PopularityLevel? get popularityLevel {
    if (popularity == null) {
      return null;
    }
    return computePopularityLevel(popularity!);
  }
}

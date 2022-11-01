import 'package:equatable/equatable.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/img.dart';
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
    final type = map["tmdb_type"] as TMDBType;
    try {
      if (type.isVideo()) {
        return TMDBVideo.fromJson(map);
      } else {
        return TMDBMedia.fromMap(map);
      }
    } catch (e) {
      throw UnsupportedError('unsupported type $type');
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

mixin TMDBElementWithImage on TMDBElement {
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

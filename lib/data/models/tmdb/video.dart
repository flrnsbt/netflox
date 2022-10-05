import 'package:netflox/data/models/tmdb/element.dart';

enum VideoSite {
  youtube("https://www.youtube.com/watch?v="),
  undefined("");

  final String url;

  const VideoSite(this.url);
}

class TMDBVideo extends TMDBElement with Comparable<TMDBVideo> {
  final String? name;
  final String key;
  final int size;
  final VideoSite site;
  final String? videoType;
  final bool official;
  final String language;

  String get url => site.url + key;

  TMDBVideo(super.id,
      {this.name,
      required this.key,
      required this.site,
      required this.size,
      this.language = "en",
      this.videoType,
      this.official = false});

  factory TMDBVideo.fromJson(Map<String, dynamic> json) {
    return TMDBVideo(json['id'],
        key: json['key'],
        site: VideoSite.values.firstWhere(
          (e) => e.name == json['site'].toLowerCase(),
          orElse: () => VideoSite.undefined,
        ),
        language: json['iso_639_1'],
        size: json['size'] ?? 1080,
        videoType: json['type'],
        name: json['name'],
        official: json['official']);
  }

  bool get isTrailer => videoType == "Trailer";

  @override
  int compareTo(other) {
    final otherIsOfficial = other.official;
    final otherIsTrailer = other.isTrailer;
    if (!isTrailer) {
      if (!otherIsTrailer) {
        if (official) {
          return -1;
        } else if (otherIsOfficial) {
          return 1;
        }
        return 0;
      }
      return 1;
    }
    return -1;
  }

  @override
  String toString() {
    return 'TMDBVideo(name: $name, key: $key, size: $size, site: $site, official: $official, language: $language)';
  }
}

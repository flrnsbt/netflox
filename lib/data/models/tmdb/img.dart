class TMDBImg {
  final String _url;
  final TMDBImageType type;
  const TMDBImg(this._url, this.type);

  String getImgUrl([double? size]) {
    final s = TMDBImageSize.fromScreenSize(type, size);
    return "${s.name}/$_url";
  }
}

enum TMDBImageType { backdrop, poster, still, profile }

class TMDBImageSize {
  int? get size => int.tryParse(name.substring(1));
  final String name;
  final List<TMDBImageType> type;

  static const TMDBImageSize w45 =
      TMDBImageSize._("w45", [TMDBImageType.profile]);
  static const TMDBImageSize w92 = TMDBImageSize._("w92");
  static const TMDBImageSize w154 =
      TMDBImageSize._("w154", [TMDBImageType.poster]);
  static const TMDBImageSize w185 = TMDBImageSize._("w185");
  static const TMDBImageSize w300 =
      TMDBImageSize._("w300", [TMDBImageType.still, TMDBImageType.backdrop]);
  static const TMDBImageSize w342 =
      TMDBImageSize._("w342", [TMDBImageType.poster]);
  static const TMDBImageSize w500 =
      TMDBImageSize._("w500", [TMDBImageType.poster]);
  static const TMDBImageSize h632 =
      TMDBImageSize._("h632", [TMDBImageType.profile]);
  static const TMDBImageSize w780 =
      TMDBImageSize._("w780", [TMDBImageType.poster, TMDBImageType.backdrop]);
  static const TMDBImageSize w1280 =
      TMDBImageSize._("w1280", [TMDBImageType.backdrop]);
  static const TMDBImageSize original = TMDBImageSize._("original");
  static const List<TMDBImageSize> values = [
    w45,
    w92,
    w154,
    w185,
    w300,
    w342,
    w500,
    h632,
    w780,
    w1280,
    original,
  ];

  factory TMDBImageSize.fromName(String name) {
    return values.firstWhere((e) => e.name == name);
  }

  const TMDBImageSize._(this.name, [this.type = TMDBImageType.values]);

  static TMDBImageSize fromScreenSize(TMDBImageType type, double? size) {
    final values =
        TMDBImageSize.values.where((e) => e.type.contains(type)).toList();
    return _fromScreenSize(values, size);
  }
}

TMDBImageSize _fromScreenSize(List<TMDBImageSize> values, double? size) {
  if (size != null) {
    do {
      final i = values.length ~/ 2;
      final v = values[i - 1].size ?? double.infinity;
      if (size > v) {
        values = values.sublist(i);
      } else {
        values = values.sublist(0, i);
      }
    } while (values.length > 1);
    return values.single;
  }
  return TMDBImageSize.original;
}

mixin TMDBFilter on Enum {
  String get beautifulName => name
      .split(RegExp(r'(?=[A-Z])'))
      .map((e) => "${e[0].toUpperCase()}${e.substring(1)}")
      .join(" ");
}

enum TMDBGenre with TMDBFilter {
  action,
  adventure,
  animation,
  comedy,
  crime,
  documentary,
  drama,
  family,
  fantasy,
  history,
  horror,
  music,
  mystery,
  romance,
  scienceFiction,
  tvMovie,
  thriller,
  war,
  western;
}

enum TMDBMediaType with TMDBFilter {
  movie,
  tv;
}

enum TMDBLanguage with TMDBFilter {
  en,
  fr,
  th;
}

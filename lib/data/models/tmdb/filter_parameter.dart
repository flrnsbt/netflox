import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/models/tmdb/genre.dart';
import 'package:netflox/data/models/tmdb/tv.dart';
import 'library_media_information.dart';
import 'media.dart';
import 'movie.dart';
import 'type.dart';

abstract class FilterParameter<T extends TMDBPrimaryMedia> extends Equatable {
  const FilterParameter();

  @override
  List<Object?> get props => [];

  static P fromMap<P extends FilterParameter>(Map<String, dynamic> data) {
    if (P == SearchFilterParameter) {
      return SearchFilterParameter.fromMap(data) as P;
    } else if (P == DiscoverFilterParameter) {
      return DiscoverFilterParameter.fromMap(data) as P;
    } else if (P == LibraryFilterParameter) {
      return LibraryFilterParameter.fromMap(data) as P;
    } else if (P == SimpleMultimediaFilterParameter) {
      return SimpleMultimediaFilterParameter.fromMap(data) as P;
    }
    throw UnimplementedError();
  }
}

abstract class SingleTypeFilterParameter<T extends TMDBPrimaryMedia>
    extends FilterParameter<T> {
  final TMDBType<T> type;
  const SingleTypeFilterParameter(
    this.type,
  );

  @override
  List<Object?> get props => [type];

  Map<String, dynamic> toMap() => {
        'media_type': type,
      };
}

class SearchFilterParameter<T extends TMDBPrimaryMedia>
    extends SingleTypeFilterParameter<T> {
  final String? searchTerms;
  final int? year;
  const SearchFilterParameter({TMDBType<T>? type, this.year, this.searchTerms})
      : super(
          type ?? TMDBPrimaryMediaType.any as TMDBType<T>,
        );
  @override
  List<Object?> get props => super.props..addAll([searchTerms, year]);

  factory SearchFilterParameter.fromMap(Map<String, dynamic> map) {
    return SearchFilterParameter(
        type: map['media_type'],
        year: map['year'],
        searchTerms: map['search_terms']);
  }

  SearchFilterParameter<TMDBPrimaryMedia> copyWith(
      {TMDBType<TMDBPrimaryMedia>? type,
      String? searchTerms,
      int? year,
      num? page}) {
    return SearchFilterParameter(
      type: type ?? this.type,
      year: year ?? this.year,
      searchTerms: searchTerms ?? this.searchTerms,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'search_terms': searchTerms, 'year': year, ...super.toMap()};
  }
}

class DiscoverFilterParameter<T extends TMDBMultiMedia>
    extends SingleTypeFilterParameter<T> {
  final int? year;
  final List<TMDBMultiMediaGenre<T>> genres;
  final TMDBSortCriterion sortCriterion;
  final SortOrder sortOrder;
  final Language? originalLanguage;

  SortParameter get sortParameter =>
      SortParameter(criterion: sortCriterion, order: sortOrder);

  const DiscoverFilterParameter(
      {TMDBType<T>? type,
      this.genres = const [],
      this.year,
      this.originalLanguage,
      TMDBSortCriterion? sortCriterion,
      this.sortOrder = SortOrder.desc})
      : assert(type != TMDBMultiMediaType.any),
        sortCriterion = sortCriterion ?? TMDBSortCriterion.popularity,
        super(
          type ?? TMDBPrimaryMediaType.movie as TMDBType<T>,
        );

  factory DiscoverFilterParameter.fromMap(Map<String, dynamic> map) {
    return DiscoverFilterParameter(
      type: map['media_type'],
      year: map['year'],
      originalLanguage: map['language'],
      sortCriterion: map['sort_by'],
      sortOrder: map['order_by'],
      genres: map['genres'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'sort_by': sortCriterion,
      'order_by': sortOrder,
      'language': originalLanguage,
      'genres': genres,
      'year': year,
      ...super.toMap()
    };
  }

  DiscoverFilterParameter copyWith(
      {TMDBType<TMDBMultiMedia>? type,
      int? year,
      Language? originalLanguage,
      List<TMDBMultiMediaGenre>? genres,
      TMDBSortCriterion? sortCriterion,
      SortOrder? sortOrder}) {
    return DiscoverFilterParameter(
      type: type ?? this.type,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      year: year ?? this.year,
      sortCriterion: sortCriterion,
      sortOrder: sortOrder ?? this.sortOrder,
      genres: genres ?? this.genres,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        genres,
        year,
        sortCriterion,
        sortOrder,
        originalLanguage
      ];
}

class LibraryFilterParameter extends FilterParameter<TMDBMultiMedia> {
  final List<TMDBType<TMDBMultiMedia>> types;
  final LibrarySortCriterion sortCriterion;
  final SortOrder sortOrder;
  final Language? language;
  final Language? subtitle;
  final MediaStatus status;

  SortParameter get sortParameter =>
      SortParameter(criterion: sortCriterion, order: sortOrder);

  const LibraryFilterParameter(
      {this.sortCriterion = LibrarySortCriterion.addedOn,
      List<TMDBType<TMDBMultiMedia>>? types,
      this.sortOrder = SortOrder.desc,
      this.language,
      this.subtitle,
      this.status = MediaStatus.available})
      : types = types ?? TMDBMultiMediaType.all;

  factory LibraryFilterParameter.fromMap(Map<String, dynamic> map) {
    return LibraryFilterParameter(
        sortCriterion: map['sort_by'],
        types: map['media_type'],
        sortOrder: map['order_by'],
        language: map['language'],
        subtitle: map['subtitle'],
        status: map['media_status']);
  }

  Map<String, dynamic> toMap() {
    return {
      'media_type': types,
      'sort_by': sortCriterion,
      'language': language,
      'subtitle': subtitle,
      'media_status': status,
      'order_by': sortOrder,
    };
  }

  LibraryFilterParameter copyWith(
      {List<TMDBType<TMDBMultiMedia>>? types,
      int? year,
      LibrarySortCriterion? sortCriterion,
      Language? language,
      Language? subtitle,
      MediaStatus? status,
      SortOrder? sortOrder}) {
    return LibraryFilterParameter(
      types: types ?? this.types,
      sortCriterion: sortCriterion ?? this.sortCriterion,
      sortOrder: sortOrder ?? this.sortOrder,
      language: language ?? this.language,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [types, status, subtitle, language, sortCriterion, sortOrder];
}

class SimpleMultimediaFilterParameter extends FilterParameter<TMDBMultiMedia> {
  final List<TMDBType<TMDBMultiMedia>> types;

  final TMDBSortCriterion sortCriterion;
  final SortOrder order;
  const SimpleMultimediaFilterParameter({
    this.types = TMDBMultiMediaType.all,
    this.sortCriterion = TMDBSortCriterion.popularity,
    this.order = SortOrder.desc,
  });

  factory SimpleMultimediaFilterParameter.fromMap(Map<String, dynamic> map) {
    return SimpleMultimediaFilterParameter(
        sortCriterion: map['sort_by'],
        types: map['media_type'],
        order: map['order_by']);
  }
}

abstract class SortCriterion<T extends TMDBMultiMedia> {
  final String key;

  const SortCriterion(this.key);

  Comparable of(T object) {
    return object.get(key);
  }

  @override
  String toString() {
    return key;
  }
}

class LibrarySortCriterion extends SortCriterion<TMDBMultiMedia> {
  const LibrarySortCriterion._(super.key);
  static const addedOn = LibrarySortCriterion._('added_on');
}

class TMDBSortCriterion<T extends TMDBMultiMedia> extends SortCriterion<T> {
  static const popularity = TMDBSortCriterion._('popularity');
  static const releaseDate = TMDBSortCriterion._('release_date');
  static const voteAverage = TMDBSortCriterion._('vote_average');
  static const all = [popularity, releaseDate, voteAverage];

  const TMDBSortCriterion._(super.key);
}

class TMDBMovieSortCriterion extends TMDBSortCriterion<TMDBMovie> {
  const TMDBMovieSortCriterion._(String key) : super._(key);
  static const voteCount = TMDBMovieSortCriterion._('vote_count');
  static const title = TMDBMovieSortCriterion._('original_title');
  static const popularity = TMDBSortCriterion.popularity;
  static const releaseDate = TMDBSortCriterion.releaseDate;
  static const voteAverage = TMDBSortCriterion.voteAverage;
  static const all = [voteCount, title, ...TMDBSortCriterion.all];
}

mixin TMDBTVSortCriterion implements TMDBSortCriterion<TMDBTv> {
  static const popularity = TMDBSortCriterion.popularity;
  static const releaseDate = TMDBSortCriterion.releaseDate;
  static const voteAverage = TMDBSortCriterion.voteAverage;
  static const all = TMDBSortCriterion.all;
}

enum TimeWindow {
  week,
  day;
}

enum SortOrder {
  asc(1),
  desc(-1);

  final int factor;

  const SortOrder(this.factor);

  bool get isDescending => this == desc;

  @override
  String toString() {
    return name;
  }
}

class SortParameter<T extends TMDBMultiMedia> {
  final SortCriterion criterion;
  final SortOrder order;

  SortParameter({required this.criterion, this.order = SortOrder.desc});

  @override
  String toString() {
    return "${criterion.key}.${order.name}";
  }

  int comparator(T a, T b) {
    return criterion.of(a).compareTo(criterion.of(b)) * order.factor;
  }
}

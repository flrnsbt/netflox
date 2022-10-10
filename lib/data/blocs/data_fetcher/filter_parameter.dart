import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:netflox/data/models/tmdb/genre.dart';
import 'package:netflox/data/models/tmdb/parameters.dart';
import '../../models/tmdb/library_media_information.dart';
import '../../models/tmdb/media.dart';
import '../../models/tmdb/type.dart';

class FilterParameter<T extends TMDBPrimaryMedia> extends Equatable {
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

  SortParameter get sortParameter =>
      SortParameter(criterion: sortCriterion, order: sortOrder);

  const DiscoverFilterParameter(
      {TMDBType<T>? type,
      this.genres = const [],
      this.year,
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
      'genres': genres,
      'year': year,
      ...super.toMap()
    };
  }

  DiscoverFilterParameter copyWith(
      {TMDBType<TMDBMultiMedia>? type,
      int? year,
      List<TMDBMultiMediaGenre>? genres,
      TMDBSortCriterion? sortCriterion,
      SortOrder? sortOrder}) {
    return DiscoverFilterParameter(
      type: type ?? this.type,
      year: year ?? this.year,
      sortCriterion: sortCriterion,
      sortOrder: sortOrder ?? this.sortOrder,
      genres: genres ?? this.genres,
    );
  }

  @override
  List<Object?> get props =>
      [...super.props, genres, year, sortCriterion, sortOrder];
}

class LibraryFilterParameter extends FilterParameter<TMDBMultiMedia> {
  final List<TMDBType<TMDBMultiMedia>> types;
  final LibrarySortCriterion sortCriterion;
  final SortOrder sortOrder;
  final List<Locale>? languages;
  final List<Locale>? subtitles;
  final MediaStatus status;

  SortParameter get sortParameter =>
      SortParameter(criterion: sortCriterion, order: sortOrder);

  const LibraryFilterParameter(
      {this.sortCriterion = LibrarySortCriterion.addedOn,
      List<TMDBType<TMDBMultiMedia>>? types,
      this.sortOrder = SortOrder.desc,
      this.languages,
      this.subtitles,
      this.status = MediaStatus.available})
      : types = types ?? TMDBMultiMediaType.all;

  factory LibraryFilterParameter.fromMap(Map<String, dynamic> map) {
    return LibraryFilterParameter(
        sortCriterion: map['sort_by'],
        types: map['media_type'],
        sortOrder: map['order_by'],
        languages: map['languages'],
        subtitles: map['subtitles'],
        status: map['media_status']);
  }

  Map<String, dynamic> toMap() {
    return {
      'media_type': types,
      'sort_by': sortCriterion,
      'languages': languages,
      'subtitles': subtitles,
      'media_status': status,
      'order_by': sortOrder,
    };
  }

  LibraryFilterParameter copyWith(
      {List<TMDBType<TMDBMultiMedia>>? types,
      int? year,
      LibrarySortCriterion? sortCriterion,
      List<Locale>? languages,
      List<Locale>? subtitles,
      MediaStatus? status,
      SortOrder? sortOrder}) {
    return LibraryFilterParameter(
      types: types ?? this.types,
      sortCriterion: sortCriterion ?? this.sortCriterion,
      sortOrder: sortOrder ?? this.sortOrder,
      languages: languages ?? this.languages,
      subtitles: subtitles ?? this.subtitles,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [types, status, subtitles, languages, sortCriterion, sortOrder];
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:netflox/data/constants/constants.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/element.dart';
import 'package:netflox/data/models/tmdb/filter.dart';
import 'package:netflox/data/models/tmdb/movie.dart';
import 'package:netflox/data/models/tmdb/tv.dart';

Locale _defaultLanguage = const Locale("en", "US");
bool _defaultIncludeAdult = false;

class TMDBRepository {
  TMDBRepository(
      {required Locale defaultLanguage, bool defaultIncludeAdult = false}) {
    _defaultLanguage = defaultLanguage;
    _defaultIncludeAdult = defaultIncludeAdult;
  }

  TMDBSearchQuery search() {
    return TMDBSearchQuery();
  }

  TMDBQuery<TMDBMovie> movie() {
    return TMDBQuery(TMDBMediaType.movie);
  }

  TMDBQuery<TMDBTv> tv() {
    return TMDBQuery(TMDBMediaType.tv);
  }
}

abstract class _TMDBQuery {
  _TMDBQuery([String? query, this._locale, this._includeAdult])
      : _query = query ?? "multi";

  Locale? _locale;
  bool? _includeAdult;
  String _query;

  _TMDBQuery language(Locale locale) {
    _locale = locale;
    return this;
  }

  _TMDBQuery includeAdult(bool allow) {
    _includeAdult = allow;
    return this;
  }
}

class TMDBSearchQuery<T extends TMDBElement> extends _TMDBQuery {
  int? _year;
  TMDBSearchQuery year(int year) {
    _year = year;
    return this;
  }

  TMDBCollection<T> query(String searchQuery) {
    _query =
        "/search$_query?query=$searchQuery${_year != null ? "&year=$_year" : ""}";
    return TMDBCollection.fromQuery(this);
  }
}

class TMDBQuery<T extends TMDBElement> extends _TMDBQuery {
  TMDBQuery(TMDBMediaType? mediaType) : super(mediaType?.name);

  TMDBDocument<T> getElement(String id) {
    _query += "/$id?";
    return TMDBDocument.fromQuery(this);
  }

  TMDBCollection<T> search(String searchQuery, {int? year}) {
    final s = this as TMDBSearchQuery<T>;
    if (year != null) {
      s.year(year);
    }
    return s.query(searchQuery);
  }

  TMDBCollection<T> getPopulars() {
    _query += "/popular?";
    return TMDBCollection.fromQuery(this);
  }

  TMDBCollection<T> getTopRated() {
    _query += "/top_rated?";
    return TMDBCollection.fromQuery(this);
  }
}

abstract class _TMDBElement extends _TMDBQuery {
  _TMDBElement([super.query, super.locale, super.includeAdult]);
  String _getURL() {
    final includeAdult = _includeAdult ?? _defaultIncludeAdult;
    final language = _locale ?? _defaultLanguage;
    return "$kTMDBBaseURL${_query}api_key=$kTMDBApiKey&include_adult=$includeAdult&language=${language.toString()}";
  }
}

class TMDBDocument<T extends TMDBElement> extends _TMDBElement {
  TMDBDocument._([super.query, super.locale, super.includeAdult]);
  factory TMDBDocument.fromQuery(_TMDBQuery tmdbQuery) {
    return TMDBDocument._(
        tmdbQuery._query, tmdbQuery._locale, tmdbQuery._includeAdult);
  }

  Future<TMDBQueryResult<T>> fetch() async {
    final url = _getURL();
    final result = await http.get(Uri.parse(url));
    if (result.statusCode == 200) {
      final T data = jsonDecode(result.body) as T;
      return TMDBQueryResult(data, result.statusCode, this);
    } else {
      throw NetfloxHTTPException(result.statusCode);
    }
  }

  TMDBCollection<T> getSimilars() {
    _query += "/similar?";
    return this as TMDBCollection<T>;
  }
}

class TMDBCollection<T extends TMDBElement> extends _TMDBElement {
  TMDBCollection._([super.query, super.locale, super.includeAdult]);
  factory TMDBCollection.fromQuery(_TMDBQuery tmdbQuery) {
    return TMDBCollection._(
        tmdbQuery._query, tmdbQuery._locale, tmdbQuery._includeAdult);
  }

  int currentPage = 1;
  int totalPages = double.maxFinite.toInt();

  bool get loadable => currentPage < totalPages;

  Future<TMDBQueryResult<List<T>>>? fetch() {
    if (loadable) {
      return () async {
        final url = "${_getURL()}&page=$currentPage";
        final result = await http.get(Uri.parse(url));
        if (result.statusCode == 200) {
          final Map<String, dynamic> json = jsonDecode(result.body);
          totalPages = json['total_pages'];
          final List<T> data = json['results'].cast<T>();
          return TMDBQueryResult(data, result.statusCode, this);
        } else {
          throw NetfloxHTTPException(result.statusCode);
        }
      }();
    }
    return null;
  }
}

class TMDBQueryResult<T> {
  final T data;
  final int statusCode;
  final DateTime timeStamp;
  final _TMDBElement query;
  TMDBQueryResult(this.data, this.statusCode, this.query)
      : timeStamp = DateTime.now();
}

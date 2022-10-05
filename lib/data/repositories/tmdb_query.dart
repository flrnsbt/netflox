part of 'tmdb_repository.dart';

// ignore: must_be_immutable
class _TMDBQueryBuilder extends Equatable {
  final List _path;
  final Map<String, dynamic> _parameters;

  _TMDBQueryBuilder([Object? path])
      : _path = [],
        _parameters = {} {
    if (path != null) {
      addPathNode(path);
    }
  }

  _TMDBQueryBuilder addPathNode(Object pathNode) {
    if (pathNode is TMDBType) {
      type = pathNode;
    }
    _path.add(pathNode);
    return this;
  }

  _TMDBQueryBuilder setParameter(String key, Object value) {
    if (_parameters.containsKey(key)) {
      _parameters.update(key, (_) => value);
    } else {
      _parameters.putIfAbsent(key, () => value);
    }
    return this;
  }

  late TMDBType type;

  String get path => _path.join("/");

  String get parameters {
    final json =
        _parameters.entries.map((e) => "${e.key}=${e.value}").join("&").trim();
    return json;
  }

  @override
  List<Object?> get props => [_path, _parameters];

  @override
  String toString() => 'TMDBQuery(_path: $_path, _parameters: $_parameters)';
}

mixin TMDBQueryHTTPClient {
  HttpClient get _client;

  void close([bool force = false]) {
    _client.close(force: force);
  }
}

abstract class TMDBQuery<T extends TMDBElement> {
  final TMDBApiConfig _tmdbApiConfig;

  final _TMDBQueryBuilder _queryBuilder;

  TMDBQuery(this._tmdbApiConfig, [Object? path])
      : _queryBuilder = _TMDBQueryBuilder(path ?? TMDBType<T>());

  @override
  String toString() {
    return "query: $_queryBuilder, type: $T";
  }
}

class BasicTMDBQuery<T extends TMDBElement> extends TMDBQuery<T> {
  BasicTMDBQuery._(super.tmdbApiConfig, [super.path]);
}

class TrendingTMDBQuery<T extends TMDBPrimaryMedia> extends TMDBQuery<T> {
  TrendingTMDBQuery._(TMDBApiConfig config, TMDBType<T> type)
      : super(config, "trending") {
    String typePath = type.path;
    if (typePath == "multi") {
      typePath = "all";
    }
    _queryBuilder.addPathNode(typePath);
  }

  TrendingTMDBQuery<T> timeWindow(TimeWindow timeWindow) {
    _queryBuilder.addPathNode(timeWindow.name);
    return this;
  }

  TMDBCollection<T> get() {
    return TMDBCollection<T>._(this);
  }
}

class TMDBDiscoverQuery<T extends TMDBMultiMedia> extends TMDBQuery<T> {
  TMDBDiscoverQuery._(TMDBApiConfig config, [TMDBType<T>? type])
      : super(
          config,
          "discover",
        ) {
    _queryBuilder.addPathNode(type ?? TMDBType<T>());
  }

  TMDBDiscoverQuery<T> year(int year) {
    var yearQuery = "primary_release_year";
    if (T == TMDBTv) {
      yearQuery = "first_air_date_year";
    }
    _queryBuilder.setParameter(yearQuery, year);
    return this;
  }

  TMDBDiscoverQuery<T> withGenres(String genres) {
    _queryBuilder.setParameter("with_genres", genres);
    return this;
  }

  TMDBDiscoverQuery<T> language(String language) {
    _queryBuilder.setParameter("with_original_language", language);
    return this;
  }

  TMDBDiscoverQuery<T> sort(String sortParameter) {
    _queryBuilder.setParameter("sort_by", sortParameter);
    return this;
  }

  TMDBCollection<T> submit() {
    return TMDBCollection<T>._(this);
  }
}

class TMDBSearchQuery<T extends TMDBPrimaryMedia> extends TMDBQuery<T> {
  TMDBSearchQuery._(TMDBApiConfig config, [TMDBType<T>? type])
      : super(config, 'search') {
    _queryBuilder.addPathNode(type ?? TMDBType<T>());
  }

  TMDBCollection<T> searchTerms(String query) {
    _queryBuilder.setParameter("query", Uri.encodeFull(query.trim()));
    return TMDBCollection<T>._(this);
  }

  TMDBSearchQuery<T> year(int year) {
    assert(!_queryBuilder.type.isPeople());
    var yearQuery = "primary_release_year";
    if (T == TMDBTv) {
      yearQuery = "first_air_date_year";
    }
    _queryBuilder.setParameter(yearQuery, year);
    return this;
  }
}

extension TMDBMediaQueryBuilder<T extends TMDBPrimaryMedia>
    on BasicTMDBQuery<T> {
  TMDBDocument<T> document(String id) {
    _queryBuilder.addPathNode(id);
    return TMDBDocument<T>._(this);
  }

  TMDBCollection<T> getPopulars() {
    _queryBuilder.addPathNode('popular');
    return TMDBCollection<T>._(this);
  }

  TrendingTMDBQuery<T> trending() {
    return TrendingTMDBQuery<T>._(
        _tmdbApiConfig, _queryBuilder.type as TMDBType<T>);
  }

  TMDBSearchQuery<T> search() {
    return TMDBSearchQuery._(_tmdbApiConfig, _queryBuilder.type as TMDBType<T>);
  }
}

extension TMDBMultiMediaQueryBuilder<T extends TMDBMultiMedia>
    on BasicTMDBQuery<T> {
  TMDBCollection<T> getTopRated() {
    _queryBuilder.addPathNode("top_rated");
    return TMDBCollection<T>._(this);
  }

  TMDBCollection<T> upcoming() {
    _queryBuilder.addPathNode("upcoming");
    return TMDBCollection<T>._(this);
  }

  TMDBDiscoverQuery<T> advancedSearch() {
    assert(_queryBuilder._path.first != TMDBMultiMediaType.any);
    return TMDBDiscoverQuery<T>._(_tmdbApiConfig, _queryBuilder._path.first);
  }
}

extension TMDBTvQueryBuilder on TMDBDocument<TMDBTv> {
  TMDBDocument<TMDBTVSeason> getSeason(int id) {
    _query._queryBuilder.addPathNode(TMDBType.tvSeason);
    _query._queryBuilder.addPathNode(id);
    return TMDBDocument<TMDBTVSeason>._(_query);
  }
}

extension TMDBTvSeasonQueryBuilder on TMDBDocument<TMDBTVSeason> {
  TMDBDocument<TMDBTVEpisode> getEpisode(int id) {
    _query._queryBuilder.addPathNode(TMDBType.tvEpisode);
    _query._queryBuilder.addPathNode(id);
    return TMDBDocument<TMDBTVEpisode>._(_query);
  }
}

extension TMDBDocumentQuery<T extends TMDBMultiMedia> on TMDBDocument<T> {
  TMDBCollection<T> getSimilars() {
    _query._queryBuilder.addPathNode("similar");
    return TMDBCollection<T>._(_query);
  }

  TMDBMultipleDocument<TMDBPerson> credits() {
    _query._queryBuilder.addPathNode("credits");
    _query._queryBuilder.type = TMDBType.person;
    return TMDBMultipleDocument<TMDBPerson>._(_query, 'cast');
  }

  TMDBCollection<T> getRecommendations() {
    _query._queryBuilder.addPathNode("recommendations");
    return TMDBCollection<T>._(_query);
  }
}

extension TMDBLibraryDocumentQuery<T extends TMDBLibraryMedia>
    on TMDBDocument<T> {
  TMDBMultipleDocument<TMDBVideo> getVideos() {
    _query._queryBuilder.addPathNode(TMDBType.video);
    return TMDBMultipleDocument<TMDBVideo>._(_query, 'results');
  }
}

extension TMDBPeopleDocumentQuery on TMDBDocument<TMDBPerson> {
  TMDBMultipleDocument<TMDBMultiMedia> credits() {
    _query._queryBuilder.addPathNode("combined_credits");
    return TMDBMultipleDocument<TMDBMultiMedia>._(_query, 'cast');
  }

  TMDBMultipleDocument<TMDBMovie> movieCredits() {
    _query._queryBuilder.addPathNode("movie_credits");
    return TMDBMultipleDocument<TMDBMovie>._(_query, 'cast');
  }

  TMDBMultipleDocument<TMDBTv> tvCredits() {
    _query._queryBuilder.addPathNode("tv_credits");
    return TMDBMultipleDocument<TMDBTv>._(_query, 'cast');
  }
}

///////////////////
///
///
///

abstract class TMDBReference<T> with TMDBQueryHTTPClient {
  final TMDBQuery _query;
  final HttpClient _client;
  TMDBReference(this._query, [String? resultKey]) : _client = HttpClient() {
    setIncludeAdult(false);
  }

  Future<TMDBQueryResult?> fetch();

  TMDBReference<T> setLanguage(String? language) {
    if (language != null) {
      _query._queryBuilder.setParameter('language', language);
    }
    return this;
  }

  Future<Map<String, dynamic>> _getJson() async {
    final uri = _getUri();
    print(uri);
    final clientRequest = await _client.getUrl(uri);
    final HttpClientResponse response = await clientRequest.close();
    final data = await response
        .transform(const Utf8Decoder())
        .transform(const JsonDecoder())
        .first;
    return data as Map<String, dynamic>;
  }

  List<TMDBError>? _convertError(dynamic errors) {
    if (errors == null) {
      return null;
    }
    final tmdbErrors = <TMDBError>[];
    if (errors is List) {
      for (var error in errors) {
        final e = TMDBError(error);
        tmdbErrors.add(e);
      }
    } else {
      final error = TMDBError(errors);
      tmdbErrors.add(error);
    }
    return tmdbErrors;
  }

  TMDBReference<T> setIncludeAdult([bool allow = false]) {
    _query._queryBuilder.setParameter('include_adult', allow);

    return this;
  }

  Uri _getUri() => Uri.parse(
      "${_query._tmdbApiConfig.url}${_query._queryBuilder.path}?${_query._queryBuilder.parameters}&api_key=${_query._tmdbApiConfig.apiKey}");
}

mixin _TMDBMultipleDocumentInterface<T extends TMDBElement>
    on TMDBReference<List<T>> {
  String? get _resultKey;

  Future<List<T>> _convertData(
    Map<String, dynamic> result,
  ) async {
    final data = <T>[];
    final dataList = result[_resultKey];
    if (dataList != null) {
      for (final e in dataList) {
        final TMDBType type = TMDBType.fromString(e['media_type'],
            orElse: () => _query._queryBuilder.type);
        e.putIfAbsent("tmdb_type", () => type);
        final d = TMDBElement.fromMap(e);
        data.add(d as T);
      }
    }
    return data;
  }
}

class TMDBMultipleDocument<T extends TMDBElement> extends TMDBReference<List<T>>
    with _TMDBMultipleDocumentInterface<T> {
  @override
  final String _resultKey;
  TMDBMultipleDocument._(super.query, [this._resultKey = 'results']);

  @override
  Future<TMDBDocumentResult<List<T>>> fetch() async {
    try {
      final result = await _getJson();
      final data = await _convertData(result);
      final errors = _convertError(result['errors']);

      return TMDBDocumentResult(data: data, error: errors);
    } catch (e) {
      rethrow;
    }
  }

  @override
  TMDBMultipleDocument<T> setLanguage(String? language) {
    return super.setLanguage(language) as TMDBMultipleDocument<T>;
  }

  @override
  TMDBMultipleDocument<T> setIncludeAdult([bool allow = false]) {
    return super.setIncludeAdult(allow) as TMDBMultipleDocument<T>;
  }
}

class TMDBDocument<T extends TMDBElement> extends TMDBReference<T> {
  TMDBDocument._(super.query);

  @override
  Future<TMDBDocumentResult<T>> fetch() async {
    try {
      final result = await _getJson();
      final TMDBType type = TMDBType.fromString(result['media_type'],
          orElse: () => _query._queryBuilder.type);
      result.putIfAbsent("tmdb_type", () => type);
      final data = TMDBElement.fromMap(result);
      final errors = _convertError(result['errors']);
      return TMDBDocumentResult(data: data as T, error: errors);
    } catch (e) {
      rethrow;
    }
  }

  @override
  TMDBDocument<T> setLanguage(String? language) {
    return super.setLanguage(language) as TMDBDocument<T>;
  }

  @override
  TMDBDocument<T> setIncludeAdult([bool allow = false]) {
    return super.setIncludeAdult(allow) as TMDBDocument<T>;
  }
}

class TMDBCollection<T extends TMDBElement> extends TMDBReference<List<T>>
    with _TMDBMultipleDocumentInterface<T> {
  @override
  final String _resultKey;
  TMDBCollection._(super.query, [this._resultKey = 'results']);

  @override
  Future<TMDBCollectionResult<T>> fetch({num? page}) async {
    if (page != null) {
      _query._queryBuilder.setParameter("page", page);
    }
    try {
      final result = await _getJson();
      final data = await _convertData(result);
      final totalPages = result['total_pages'] ?? double.infinity;
      final page = result['page'] ?? 1;
      final errors = _convertError(result['errors']);
      return TMDBCollectionResult<T>(
          data: data, maxPage: totalPages, currentPage: page, error: errors);
    } catch (e) {
      rethrow;
    }
  }

  @override
  TMDBCollection<T> setLanguage(String? language) {
    return super.setLanguage(language) as TMDBCollection<T>;
  }

  @override
  TMDBCollection<T> setIncludeAdult([bool allow = false]) {
    return super.setIncludeAdult(allow) as TMDBCollection<T>;
  }
}

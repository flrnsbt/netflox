import 'package:netflox/data/models/tmdb/error.dart';

abstract class TMDBQueryResult<T> {
  final T? data;
  final DateTime timeStamp;
  final List<TMDBError>? error;
  TMDBQueryResult({this.data, DateTime? timeStamp, this.error})
      : timeStamp = timeStamp ?? DateTime.now();

  @override
  String toString() {
    return 'TMDBQueryResult(result: ${data.runtimeType},timeStamp: $timeStamp, error: $error)';
  }

  bool hasData() => data != null;

  bool hasError() => error != null;
}

class TMDBDocumentResult<T> extends TMDBQueryResult<T> {
  TMDBDocumentResult({super.data, super.timeStamp, super.error});

  factory TMDBDocumentResult.empty() {
    return TMDBDocumentResult();
  }

  TMDBDocumentResult<N> copyWith<N>(
      {N? data, int? statusCode, DateTime? timeStamp}) {
    return TMDBDocumentResult(
        data: data ?? data as N, timeStamp: timeStamp ?? this.timeStamp);
  }
}

class TMDBCollectionResult<T> extends TMDBQueryResult<List<T>> {
  final num currentPage;
  final num maxPage;

  bool get loadable => currentPage < maxPage;

  @override
  bool hasData() {
    if (super.hasData()) {
      return data!.isNotEmpty;
    }
    return false;
  }

  @override
  String toString() {
    return "${super.toString()}, currentPage: $currentPage, maxPage: $maxPage";
  }

  TMDBCollectionResult(
      {super.data,
      super.timeStamp,
      this.currentPage = 1,
      this.maxPage = double.maxFinite,
      super.error});

  static TMDBCollectionResult<T> empty<T>() {
    return TMDBCollectionResult(maxPage: 1, currentPage: double.maxFinite);
  }
}

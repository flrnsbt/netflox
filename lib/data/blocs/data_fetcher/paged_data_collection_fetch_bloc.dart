import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/repositories/tmdb_result.dart';
import 'package:netflox/services/firestore_service.dart';
import '../../../services/tmdb_service.dart';
import '../../models/tmdb/error.dart';
import '../../models/tmdb/type.dart';
import 'basic_server_fetch_state.dart';
import '../../models/tmdb/filter_parameter.dart';

abstract class PagedDataCollectionFetchBloc<P extends FilterParameter<T>,
        T extends TMDBMedia>
    extends Bloc<PagedDataCollectionFetchEvent,
        BasicServerFetchState<List<T>>> {
  final Duration _minimumFetchDelay;
  P? _parameter;
  int _currentPage = 1;
  PagedDataCollectionFetchBloc(
      [this._minimumFetchDelay = const Duration(seconds: 1)])
      : super(BasicServerFetchState.init()) {
    Future<TMDBCollectionResult<T>?> fetch(
        Emitter<BasicServerFetchState<List<T>>> emit, P parameter,
        [int page = 1]) async {
      emit(BasicServerFetchState.loading());
      await Future.delayed(_minimumFetchDelay);
      TMDBCollectionResult<T>? result;
      try {
        result = await get(parameter, page);
        _currentPage = result.currentPage;
        emit(BasicServerFetchState.success(
            result: result.data, error: result.error));
      } catch (e) {
        final exception = NetfloxException.from(e);
        emit(BasicServerFetchState.failed(exception));
      }
      return result;
    }

    on<PagedDataCollectionRefreshEvent>((event, emit) async {
      if (_parameter != null) {
        resetPage();
        await fetch(emit, _parameter!);
      }
    });

    on<_PagedDataCollectionFetch>((event, emit) async {
      if (event is PagedDataCollectionUpdateParameter<P>) {
        reset();
        _parameter = event.parameter;

        await fetch(emit, _parameter!, _currentPage);
      } else {
        emit(BasicServerFetchState.success(error: 'event-canceled'));
      }
    }, transformer: restartable());

    on<PagedDataCollectionFetchNextPage>(
      (event, emit) async {
        if (_parameter != null) {
          await fetch(emit, _parameter!, _currentPage + 1);
        }
      },
    );
  }

  void resetParameter() {
    _parameter = null;
  }

  void resetPage() {
    _currentPage = 1;
  }

  void reset() {
    resetPage();
    resetParameter();
  }

  @protected
  Future<TMDBCollectionResult<T>> get(P parameters, int page);
}

abstract class PagedDataCollectionFetchEvent {
  const PagedDataCollectionFetchEvent();
  static const nextPage = PagedDataCollectionFetchNextPage();
  static const refresh = PagedDataCollectionRefreshEvent();
  static const cancel = PagedDataCollectionCancelEvent();
  static PagedDataCollectionUpdateParameter<P>
      setParameter<P extends FilterParameter>(P parameter) =>
          PagedDataCollectionUpdateParameter(parameter);
}

abstract class _PagedDataCollectionFetch extends PagedDataCollectionFetchEvent {
  const _PagedDataCollectionFetch();
}

class PagedDataCollectionUpdateParameter<P extends FilterParameter>
    extends _PagedDataCollectionFetch {
  final P parameter;

  const PagedDataCollectionUpdateParameter(this.parameter);
}

class PagedDataCollectionCancelEvent extends _PagedDataCollectionFetch {
  const PagedDataCollectionCancelEvent();
}

class PagedDataCollectionFetchNextPage extends PagedDataCollectionFetchEvent {
  const PagedDataCollectionFetchNextPage();
}

class PagedDataCollectionRefreshEvent extends PagedDataCollectionFetchEvent {
  const PagedDataCollectionRefreshEvent();
}

mixin FirestoreDataCollection<P extends FilterParameter<T>,
    T extends TMDBLibraryMedia> on PagedDataCollectionFetchBloc<P, T> {
  DocumentSnapshot? _lastDoc;
  TMDBService get tmdbService;

  @override
  void resetPage() {
    _lastDoc = null;
  }

  set lastDoc(DocumentSnapshot doc) {
    _lastDoc = doc;
  }

  @protected
  void appendToElement(Map<String, dynamic> rawData, T element) {}

  @protected
  @override
  Future<TMDBCollectionResult<T>> get(parameters, int page) async {
    final firestoreResult = await _fetchFromFirestore(parameters);
    final allData = <T>[];
    final errors = <TMDBError>[];
    for (final doc in firestoreResult) {
      try {
        final data = doc.data();
        final type = TMDBType.fromString(data['media_type']);
        final id = data['id'].toString();
        TMDBDocumentResult? result;
        if (type.isMultimedia()) {
          result = await tmdbService.getMultimedia(
              id: id, type: type as TMDBType<TMDBMultiMedia>);
        } else if (type.isTVElement()) {
          final seasonNumber = data['season_number'] as int;

          if (type.isTvEpisode()) {
            final episodeNumber = data['episode_number'] as int;

            result = await tmdbService.getEpisode(
                tvShowId: id,
                seasonNumber: seasonNumber,
                episodeNumber: episodeNumber);
          } else if (type.isTvSeason()) {
            result = await tmdbService.getSeason(
                tvShowId: id, seasonNumber: seasonNumber);
          }
        }
        if (result?.hasData() ?? false) {
          final media = result!.data!;
          appendToElement(data, media);
          allData.add(media);
        }
      } on TMDBError catch (e) {
        errors.add(e);
      }
    }
    return TMDBCollectionResult(data: allData, error: errors);
  }

  Query<Map<String, dynamic>> queryBuilder(P parameters);
  List<QueryDocumentSnapshot<Map<String, dynamic>>> postQueryFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, P parameters) {
    return docs;
  }

  @protected
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchFromFirestore(
      P parameters) async {
    final result = await queryBuilder(parameters).fetchAfterDoc(_lastDoc);
    var docs = result.docs;
    docs = postQueryFilter(docs, parameters);
    if (docs.isNotEmpty) {
      lastDoc = docs.last;
    }
    return docs;
  }
}

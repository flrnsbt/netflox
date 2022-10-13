import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/repositories/tmdb_result.dart';
import '../../../services/firestore_service.dart';
import '../../../services/tmdb_service.dart';
import '../../models/tmdb/library_media_information.dart';
import 'basic_server_fetch_state.dart';
import 'filter_parameter.dart';
part 'library/library_multi_media_explore_bloc.dart';
part 'tmdb/discover_bloc.dart';
part 'tmdb/search_bloc.dart';

abstract class PagedDataCollectionFetchBloc<P extends FilterParameter>
    extends Bloc<PagedDataCollectionFetchEvent,
        BasicServerFetchState<List<TMDBPrimaryMedia>>> {
  final Duration _minimumFetchDelay;
  P? _parameter;
  int _currentPage = 1;
  PagedDataCollectionFetchBloc(
      [this._minimumFetchDelay = const Duration(seconds: 1)])
      : super(BasicServerFetchState.init()) {
    Future<TMDBCollectionResult<TMDBPrimaryMedia>?> fetch(
        Emitter<BasicServerFetchState<List<TMDBPrimaryMedia>>> emit,
        P parameter,
        [int page = 1]) async {
      emit(BasicServerFetchState.loading());
      await Future.delayed(_minimumFetchDelay);
      TMDBCollectionResult<TMDBPrimaryMedia>? result;
      try {
        result = await __fetch(parameter, page);
        _parameter = parameter;
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
        final newParameter = event.parameter;
        reset();
        await fetch(emit, newParameter, _currentPage);
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

  Future<TMDBCollectionResult<TMDBPrimaryMedia>> __fetch(
      P parameters, int page);
}

abstract class PagedDataCollectionFetchEvent {
  const PagedDataCollectionFetchEvent();
  static const nextPage = PagedDataCollectionFetchNextPage();
  static const refresh = PagedDataCollectionRefreshEvent();
  static const cancel = PagedDataCollectionCancelEvent();
  static PagedDataCollectionUpdateParameter<P>
      updateParameter<P extends FilterParameter>(P parameter) =>
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

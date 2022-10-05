import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/data_fetcher/paged_data_fetch_manager.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/repositories/tmdb_result.dart';
import '../../../services/firestore_service.dart';
import '../../../services/tmdb_service.dart';
import '../../models/tmdb/library_media_information.dart';
import 'basic_server_fetch_state.dart';
import 'filter_parameter.dart';
part 'tmdb/search_bloc.dart';
part 'tmdb/discover_bloc.dart';
part 'library/library_multi_media_explore_bloc.dart';

abstract class DataCollectionFetchBloc<P extends FilterParameter> extends Bloc<
    PagedRequestParameter<P>, BasicServerFetchState<List<TMDBPrimaryMedia>>> {
  DataCollectionFetchBloc() : super(BasicServerFetchState.finished()) {
    on<PagedRequestParameter<P>>(_fetch, transformer: restartable());
  }

  Future<void> _fetch(event, emit) async {
    emit(BasicServerFetchState.loading());
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      TMDBCollectionResult<TMDBPrimaryMedia> result;
      result = await __fetch(event);
      emit(BasicServerFetchState.finished(
          result: result.data, error: result.error));
    } catch (e) {
      final exception = NetfloxException.from(e);
      emit(BasicServerFetchState<List<TMDBPrimaryMedia>>.failed(exception));
    }
  }

  Future<TMDBCollectionResult<TMDBPrimaryMedia>> __fetch(
      PagedRequestParameter<P> parameters);
}

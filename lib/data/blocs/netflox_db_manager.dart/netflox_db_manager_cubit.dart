import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:netflox/data/models/tmdb/element.dart';
import 'package:netflox/services/tmdb_service.dart';

import '../../models/exception.dart';
import '../../repositories/tmdb_repository.dart';

part 'netflox_db_state.dart';

class NetfloxDBManager extends Cubit<NetfloxDBState> {
  final TMDBService tmdbService;

  NetfloxDBManager(this.tmdbService) : super(NetfloxDBStateLoading());

  // Future<TMDBQueryResult<TMDBMovie>>
  Future<void> getPopularMovies() async {
    try {
      final result = await tmdbService.getPopularMovies();
      if (result != null) {
        emit(NetfloxDBStateSuccess(result));
      } else {
        emit(NetfloxDBStateFail(const NetfloxException(code: "empty_result")));
      }
    } catch (e) {
      emit(NetfloxDBStateFail(NetfloxException.dyn(e)));
    }
  }
}

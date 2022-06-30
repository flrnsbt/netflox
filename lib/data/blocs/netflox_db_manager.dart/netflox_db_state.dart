part of 'netflox_db_manager_cubit.dart';

@immutable
abstract class NetfloxDBState {}

class NetfloxDBStateLoading extends NetfloxDBState {}

class NetfloxDBStateSuccess<T extends Object> extends NetfloxDBState {
  final TMDBQueryResult<T> result;

  NetfloxDBStateSuccess(this.result);
}

class NetfloxDBStateFail extends NetfloxDBState {
  final NetfloxException exception;

  NetfloxDBStateFail(this.exception);
}

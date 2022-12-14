// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:netflox/utils/type_is_list_extension.dart';

import '../../constants/basic_fetch_status.dart';

@immutable
class BasicServerFetchState<T> extends Equatable
    with BasicServerFetchStatusInterface {
  @override
  final BasicServerFetchStatus status;
  final T? result;
  @override
  final Object? error;

  bool hasData() {
    if (result != null) {
      if (T.isIterable()) {
        return (result as Iterable).isNotEmpty;
      }
      return true;
    }
    return false;
  }

  const BasicServerFetchState({this.result, required this.status, this.error});

  factory BasicServerFetchState.init() =>
      const BasicServerFetchState(status: BasicServerFetchStatus.init);

  factory BasicServerFetchState.loading() =>
      const BasicServerFetchState(status: BasicServerFetchStatus.loading);

  factory BasicServerFetchState.success({T? result, Object? error}) =>
      BasicServerFetchState(
          status: BasicServerFetchStatus.success, result: result, error: error);

  factory BasicServerFetchState.failed(Object error) => BasicServerFetchState(
      status: BasicServerFetchStatus.failed, error: error);

  @override
  List<Object?> get props => [result, error, status];
}

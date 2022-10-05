part of 'http_server_cubit.dart';

enum HttpServerStatus { off, on, loading }

class HttpVideoBinderState extends Equatable {
  final HttpServerStatus status;
  final Object? exception;
  const HttpVideoBinderState._(this.status, {this.exception});

  static const off = HttpVideoBinderState._(HttpServerStatus.off);
  static const on = HttpVideoBinderState._(HttpServerStatus.on);
  static const loading = HttpVideoBinderState._(HttpServerStatus.loading);
  static fail(Object exception) =>
      HttpVideoBinderState._(HttpServerStatus.off, exception: exception);

  bool failed() => exception != null;

  bool isRunning() => status != HttpServerStatus.off;
  bool isLoading() => status != HttpServerStatus.loading;

  String? get url {
    if (isRunning()) {
      return "http://$kLocalServerAddress:$kLocalServerPort/video.mp4";
    }
    return null;
  }

  @override
  List<Object?> get props => [status, exception];

  @override
  String toString() =>
      'HttpServerState(status: $status, exception: $exception)';
}

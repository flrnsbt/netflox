enum BasicServerFetchStatus { loading, finished, failed }

mixin BasicServerFetchStatusInterface {
  BasicServerFetchStatus get status;
  bool isLoading() => status == BasicServerFetchStatus.loading;
  bool finished() => status == BasicServerFetchStatus.finished;
  bool failed() => status == BasicServerFetchStatus.failed;

  bool hasError() => error != null;

  Object? get error;
}

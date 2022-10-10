enum BasicServerFetchStatus { loading, success, failed, init }

mixin BasicServerFetchStatusInterface {
  BasicServerFetchStatus get status;
  bool isLoading() => status == BasicServerFetchStatus.loading;
  bool success() => status == BasicServerFetchStatus.success;
  bool failed() => status == BasicServerFetchStatus.failed;
  bool finished() =>
      status == BasicServerFetchStatus.failed ||
      status == BasicServerFetchStatus.success;

  bool isIdle() => finished() || status == BasicServerFetchStatus.init;

  bool hasError() => error != null;

  Object? get error;
}

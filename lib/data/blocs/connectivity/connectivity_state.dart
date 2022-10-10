part of 'connectivity_manager.dart';

class ConnectivityState extends Equatable {
  final ConnectivityResult medium;

  const ConnectivityState._(this.medium);

  static const ConnectivityState init =
      ConnectivityState._(ConnectivityResult.none);

  static ConnectivityState update(ConnectivityResult medium) {
    return ConnectivityState._(medium);
  }

  bool hasNetworkAccess() =>
      medium != ConnectivityResult.none &&
      medium != ConnectivityResult.bluetooth;

  @override
  List<Object?> get props => [
        medium,
      ];
}

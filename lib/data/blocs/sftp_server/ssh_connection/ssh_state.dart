import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';

enum SSHConnectionStatus { connected, connecting, disconnected }

class SSHConnectionState extends Equatable {
  final SSHConnectionStatus status;
  const SSHConnectionState._(this.status, [this.exception]);
  final Object? exception;

  bool isConnected() => status == SSHConnectionStatus.connected;
  bool isConnecting() => status == SSHConnectionStatus.connecting;
  bool failed() => exception != null;
  bool isDisconnected() => status == SSHConnectionStatus.disconnected;

  static SSHConnectedState connected(SftpClient sftpClient) =>
      SSHConnectedState._(sftpClient);

  static const connecting =
      SSHConnectionState._(SSHConnectionStatus.connecting);
  static SSHConnectionState disconnected([Object? exception]) =>
      SSHConnectionState._(SSHConnectionStatus.disconnected, exception);

  @override
  List<Object> get props => [status];
}

class SSHConnectedState extends SSHConnectionState {
  final SftpClient sftpClient;

  const SSHConnectedState._(this.sftpClient)
      : super._(SSHConnectionStatus.connected);

  @override
  List<Object> get props => super.props + [sftpClient];
}

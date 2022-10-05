import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';

enum SSHConnectionStatus { connected, connecting, disconnected }

class SSHConnectionState extends Equatable {
  final SSHConnectionStatus status;
  const SSHConnectionState._(this.status, [this.exception]);
  final Object? exception;

  bool isConnected() => status == SSHConnectionStatus.connected;
  bool failed() => exception != null;
  bool isDisconnected() => status == SSHConnectionStatus.disconnected;

  static SSHConnectedState connected(
          SftpClient sftpClient, String remoteDirectoryPath) =>
      SSHConnectedState._(sftpClient, remoteDirectoryPath);

  static const connecting =
      SSHConnectionState._(SSHConnectionStatus.connecting);
  static SSHConnectionState disconnected([Object? exception]) =>
      SSHConnectionState._(SSHConnectionStatus.disconnected, exception);

  @override
  List<Object> get props => [status];
}

class SSHConnectedState extends SSHConnectionState {
  final SftpClient sftpClient;
  final String remoteDirectoryPath;

  const SSHConnectedState._(this.sftpClient, this.remoteDirectoryPath)
      : super._(SSHConnectionStatus.connected);

  @override
  List<Object> get props => super.props + [sftpClient];
}

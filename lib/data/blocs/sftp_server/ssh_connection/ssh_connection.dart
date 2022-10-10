import 'dart:async';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_state.dart';
import '../../../models/server_configs/ssh_config.dart';
import '../../../models/user/user.dart';

class SSHConnectionCubit extends Cubit<SSHConnectionState> {
  final NetfloxSSHConfig _sshConfig;
  final List<SSHKeyPair>? _identities;
  SSHConnectionCubit(this._identities, this._sshConfig)
      : super(SSHConnectionState.disconnected());

  factory SSHConnectionCubit.fromUser(
      NetfloxUser user, NetfloxSSHConfig sshConfig) {
    final sshKeyPair = user.sshKeyPair;
    return SSHConnectionCubit(sshKeyPair, sshConfig);
  }

  FutureOr<void> connect() async {
    if (state.isDisconnected()) {
      emit(SSHConnectionState.connecting);
      try {
        final socket = await SSHSocket.connect(
          _sshConfig.hostName,
          _sshConfig.port,
          timeout: const Duration(seconds: 30),
        );
        socket.done.whenComplete(() => emit(SSHConnectionState.disconnected()));
        final sshClient = SSHClient(socket,
            username: _sshConfig.username, identities: _identities);
        await sshClient.authenticated;
        final sftpClient = await sshClient.sftp();
        emit(SSHConnectionState.connected(sftpClient));
      } catch (e) {
        emit(SSHConnectionState.disconnected(e));
      }
    }
  }

  @override
  Future<void> close() {
    disconnect();
    return super.close();
  }

  void disconnect() {
    if (state is SSHConnectedState) {
      (state as SSHConnectedState).sftpClient.close();
      emit(SSHConnectionState.disconnected());
    }
  }
}

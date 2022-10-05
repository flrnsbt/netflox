import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_state.dart';

part 'media_file_set_state.dart';

class LibraryMediaAccessCubit extends Cubit<SFTPMediaAccessState> {
  final SftpClient _sftpClient;
  final String _baseRemoteDirectoryPath;

  factory LibraryMediaAccessCubit.fromSSHConnectedState(
      SSHConnectedState state) {
    return LibraryMediaAccessCubit(state.sftpClient, state.remoteDirectoryPath);
  }

  LibraryMediaAccessCubit(this._sftpClient, this._baseRemoteDirectoryPath)
      : super(SFTPMediaAccessState.waiting);

  Future<void> open(String remoteFilePath) async {
    if (!state.opened()) {
      emit(SFTPMediaAccessState.waiting);
      try {
        final path = "$_baseRemoteDirectoryPath/$remoteFilePath";
        print(path);
        final subFiles = (await _sftpClient.readdir(path).first)
            .where((e) => e.filename.split(".").last == "srt");
        final subtitles = <String, String>{};
        for (var sub in subFiles) {
          final filePath = "$path/${sub.filename}";
          final remoteFile = await _sftpClient.open(filePath);
          final bytes = await remoteFile.readBytes();
          final content = utf8.decode(bytes);
          final key = sub.filename.split(".").first;
          subtitles.putIfAbsent(key, () => content);
        }
        final videoRemoteFile = await _sftpClient.open("$path/video.mp4");
        emit(SFTPMediaAccessState.open(videoRemoteFile, subtitles: subtitles));
      } catch (e) {
        emit(SFTPMediaAccessState.fail(
          e,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _sftpClient.close();
    return super.close();
  }
}

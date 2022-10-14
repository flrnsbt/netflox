import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_state.dart';

part 'sftp_media_file_state.dart';

class SFTPMediaAccessCubit extends Cubit<SFTPMediaFileAccessState> {
  final SftpClient _sftpClient;

  factory SFTPMediaAccessCubit.fromSSHConnectedState(SSHConnectedState state) {
    return SFTPMediaAccessCubit(state.sftpClient);
  }

  SFTPMediaAccessCubit(this._sftpClient)
      : super(SFTPMediaFileAccessState.waiting);

  Future<void> open(String remoteFilePath) async {
    remoteFilePath = 'netfloxDisk/$remoteFilePath';
    if (!state.opened()) {
      emit(SFTPMediaFileAccessState.waiting);
      SftpFile? videoRemoteFile;
      Map<String, String>? subtitles;
      Object? exception;
      try {
        final subFiles = (await _sftpClient.readdir(remoteFilePath).first)
            .where((e) => e.filename.split(".").last == "srt");
        subtitles = <String, String>{};
        videoRemoteFile = await _sftpClient.open("$remoteFilePath/video.mp4");
        for (var sub in subFiles) {
          final filePath = "$remoteFilePath/${sub.filename}";
          final content = await _getSubtitle(filePath);
          if (content != null) {
            final key = sub.filename.split(".").first;
            subtitles.putIfAbsent(key, () => content);
          }
        }
      } catch (e) {
        exception = e;
      } finally {
        if (videoRemoteFile != null) {
          emit(SFTPMediaFileAccessState.open(videoRemoteFile,
              subtitles: subtitles, exception: exception));
        } else {
          emit(SFTPMediaFileAccessState.fail(
              exception ?? Exception('unknown-error')));
        }
      }
    }
  }

  Future<String?> _getSubtitle(String filePath) async {
    try {
      final remoteFile = await _sftpClient.open(filePath);
      final bytes = await remoteFile.readBytes();
      final content = utf8.decode(bytes, allowMalformed: true);
      return content;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> close() {
    try {
      _sftpClient.close();
    } catch (e) {}
    return super.close();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_state.dart';

import '../../../../utils/subtitle_helper.dart';

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
      Map<Language, Subtitles>? subtitles;
      Object? exception;
      try {
        final subFiles = (await _sftpClient.readdir(remoteFilePath).first)
            .where((e) => e.filename.split(".").last == SubtitleType.srt.name);
        subtitles = <Language, Subtitles>{};
        videoRemoteFile = await _sftpClient.open("$remoteFilePath/video.mp4");
        for (var sub in subFiles) {
          final filePath = "$remoteFilePath/${sub.filename}";
          final content = await _getSubtitles(filePath);
          if (content != null) {
            final key = sub.filename.split(".").first;
            final language = Language.fromIsoCode(key);
            subtitles.putIfAbsent(language, () => content);
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

  FutureOr<Subtitles?> _getSubtitles(String filePath) async {
    try {
      final remoteFile = await _sftpClient.open(filePath);
      final bytes = await remoteFile.readBytes();
      for (final codec in codecs) {
        try {
          final content = codec.decode(bytes);
          return getSubtitlesData(content, SubtitleType.srt);
        } catch (e) {
          //
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<void> close() {
    try {
      _sftpClient.close();
    } catch (e) {}
    return super.close();
  }
}

const codecs = <Encoding>[utf8, latin1, ascii];

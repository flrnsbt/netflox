import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_state.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/media_upload_document.dart';

import '../../../../utils/subtitle_helper.dart';

part 'sftp_media_file_state.dart';

class SFTPMediaAccessCubit extends Cubit<SFTPMediaFileAccessState> {
  final SftpClient _sftpClient;

  factory SFTPMediaAccessCubit.fromSSHConnectedState(SSHConnectedState state) {
    return SFTPMediaAccessCubit(state.sftpClient);
  }

  SFTPMediaAccessCubit(this._sftpClient)
      : super(SFTPMediaFileAccessState.waiting);

  Future<void> open(TMDBLibraryMedia media) async {
    final remoteFilePath = 'netfloxDisk/${media.libraryPath}';
    if (!state.opened()) {
      emit(SFTPMediaFileAccessState.waiting);
      SftpFile? videoRemoteFile;
      Map<Language, SftpFile>? subtitles;
      Object? exception;
      try {
        final subFiles = (await _sftpClient.readdir(remoteFilePath).first)
            .where((e) => e.filename.split(".").last == SubtitleType.srt.name);
        subtitles = <Language, SftpFile>{};
        videoRemoteFile = await _sftpClient.open("$remoteFilePath/video.mp4");
        for (var sub in subFiles) {
          final filePath = "$remoteFilePath/${sub.filename}";
          final key = sub.filename.split(".").first;
          final language = Language.fromIsoCode(key);
          final remoteFile = await _sftpClient.open(filePath);
          subtitles.putIfAbsent(language, () => remoteFile);
        }
      } catch (e) {
        exception = e;
      } finally {
        if (videoRemoteFile != null) {
          final docs = TMDBMediaLibraryRemoteDocument(
              videoFile: videoRemoteFile, subtitleFiles: subtitles);
          emit(SFTPMediaFileAccessState.open(docs, exception: exception));
        } else {
          emit(SFTPMediaFileAccessState.fail(
              exception ?? Exception('unknown-error')));
        }
      }
    }
  }

  @override
  Future<void> close() {
    try {
      _sftpClient.close();
    } catch (e) {
      //
    }
    return super.close();
  }
}

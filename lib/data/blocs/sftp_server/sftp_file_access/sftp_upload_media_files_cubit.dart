import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/sftp_server/sftp_file_access/sftp_media_file_access_cubit.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/media_upload_document.dart';

import '../ssh_connection/ssh_state.dart';

class SFTPMediaFilesUploadCubit extends Cubit<SFTPMediaFileUploadState> {
  final SftpClient _sftpClient;

  factory SFTPMediaFilesUploadCubit.fromSSHConnectedState(
      SSHConnectedState state) {
    return SFTPMediaFilesUploadCubit(state.sftpClient);
  }

  SFTPMediaFilesUploadCubit(this._sftpClient)
      : super(SFTPMediaFileUploadState.waiting);

  Future<void> upload(TMDBLibraryMedia media,
      TMDBMediaLibraryUploadDocument mediaUploadDocuments) async {
    final dirPath = "netfloxDisk/${media.libraryPath}";
    try {
      await _sftpClient.open(dirPath, mode: SftpFileOpenMode.append);
    } catch (e) {
      await _sftpClient.mkdir(
        dirPath,
      );
    }
    emit(SFTPMediaFileUploadState.waiting);
    try {
      await _uploadFile(dirPath, mediaUploadDocuments.videoFile, "video.mp4");
      if (mediaUploadDocuments.subtitleFiles != null) {
        for (final sub in mediaUploadDocuments.subtitleFiles!.entries) {
          if (sub.value != null) {
            await _uploadFile(dirPath, sub.value!, "${sub.key.isoCode}.srt");
          } else {}
        }
      }
      emit(SFTPMediaFileUploadState.finished);
    } catch (e) {
      emit(SFTPMediaFileUploadState.fail(e));
    }
  }

  Future<void> abort() async {
    if (_currentRemoteFile != null) {
      await _currentRemoteFile!.close();
      emit(SFTPMediaFileUploadState.waiting);
    }
  }

  SftpFile? _currentRemoteFile;

  Future<void> _uploadFile(String dirPath, File file, String fileName,
      [bool forceTruncate = false]) async {
    emit(SFTPMediaFileUploadState.waiting);
    _currentRemoteFile = await _sftpClient.open("$dirPath/$fileName",
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.append |
            SftpFileOpenMode.write);
    final fileSize = (await file.stat()).size;
    var offset = 0;
    if (!forceTruncate) {
      offset = (await _currentRemoteFile!.stat()).size ?? 0;
    }
    final streamController = StreamController<int>.broadcast();
    emit(SFTPMediaFileUploadState.upload(
        streamController.stream, file.path, fileSize));
    await Future.delayed(const Duration(seconds: 1));
    final filestream = file.openRead(offset).cast<Uint8List>();
    await _currentRemoteFile!.write(
      filestream,
      offset: offset,
      onProgress: (total) {
        streamController.add(total + offset);
      },
    );
    print("FILE FINISHED");
    _currentRemoteFile!.close();
    streamController.close();
  }

  @override
  Future<void> close() {
    try {
      _currentRemoteFile?.close();
      _sftpClient.close();
    } catch (e) {
      //
    }
    return super.close();
  }
}

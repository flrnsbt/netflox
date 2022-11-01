import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/sftp_server/sftp_file_transfer/sftp_media_file_access_cubit.dart';
import 'package:netflox/data/constants/default_app_timeout.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/library_files.dart';
import '../ssh_connection/ssh_state.dart';

class SFTPMediaFilesUploadCubit extends Cubit<SFTPMediaFileUploadState> {
  final SftpClient _sftpClient;

  factory SFTPMediaFilesUploadCubit.fromSSHConnectedState(
      SSHConnectedState state) {
    return SFTPMediaFilesUploadCubit(state.sftpClient);
  }

  SFTPMediaFilesUploadCubit(this._sftpClient)
      : super(SFTPMediaFileUploadState.waiting);

  Future<void> _checkAndCreateDirectory(String dirPath) async {
    try {
      await _sftpClient.stat(dirPath);
    } catch (e) {
      await _sftpClient.mkdir(
        dirPath,
      );
    }
  }

  Future<void> upload(
      TMDBLibraryMedia media, TMDBMediaLibraryFiles mediaUploadFiles,
      {bool force = false}) async {
    if (state.isIdle() || force) {
      await abort();
      emit(SFTPMediaFileUploadState.loading(media));
      await Future.delayed(const Duration(seconds: 1));
      final dirPath =
          _currentDirectoryPath = "$kRootRemoteDirPath/${media.absolutePath}";
      await _checkAndCreateDirectory(dirPath).timeout(kDefaultTimeout);
      try {
        final videoFile = mediaUploadFiles.videoFilePath;
        if (videoFile?.isLocalFile() ?? false) {
          await _uploadFile(media, videoFile!,
              remoteFileName: "$kVideoDefaultFileName.$MP4");
        }
        for (final subFile in mediaUploadFiles.subtitleFilesPath.entries) {
          if (subFile.value.isLocalFile()) {
            await _uploadFile(media, subFile.value,
                remoteFileName: "${subFile.key.isoCode}.srt");
          }
        }
        emit(SFTPMediaFileUploadState.finished(media, mediaUploadFiles));
      } catch (e) {
        emit(SFTPMediaFileUploadState.fail(media: media, exception: e));
      }
    }
  }

  Future<void> abort() async {
    if (!state.isIdle()) {
      _currentDirectoryPath = null;
      if (_currentRemoteFile != null) {
        await _currentRemoteFile!.close();
        _currentRemoteFile = null;
      }
      final currentMedia = state.media;
      emit(SFTPMediaFileUploadState.fail(
          exception: 'aborted', media: currentMedia));
    }
  }

  String? _currentDirectoryPath;
  SftpFile? _currentRemoteFile;

  Future<void> _uploadFile(
      TMDBLibraryMedia media, NetfloxFilePath localFilePath,
      {bool forceTruncate = false, required String remoteFileName}) async {
    emit(SFTPMediaFileUploadState.loading(media));
    final fileName = "$_currentDirectoryPath/${localFilePath.fileUri.fileName}";
    final remoteFile = _currentRemoteFile = await _sftpClient.open(fileName,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.append |
            SftpFileOpenMode.write |
            SftpFileOpenMode.read);
    final localFile = File.fromUri(localFilePath.fileUri);
    final localFileSize = (await localFile.stat()).size;
    var offset = 0;
    if (!forceTruncate) {
      offset = (await _currentRemoteFile!.stat()).size ?? 0;
    }
    final streamController = StreamController<int>.broadcast();
    emit(SFTPMediaFileUploadState.uploading(media, streamController.stream,
        localFilePath.fileUri.fileName, localFileSize));
    final filestream = localFile.openRead(offset).cast<Uint8List>();
    remoteFile.write(
      filestream,
      offset: offset,
      onProgress: (total) {
        final totalBytes = total + offset;
        streamController.add(totalBytes);
        if (totalBytes >= localFileSize) {
          streamController.close();
        }
      },
    );
    await Future.delayed(const Duration(seconds: 1));
    await streamController.done;
    await _sftpClient.rename(
        fileName, "$_currentDirectoryPath/$remoteFileName");
    await remoteFile.close();
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

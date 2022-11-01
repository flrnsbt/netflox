import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_state.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/library_files.dart';
import '../../../constants/default_app_timeout.dart';

part 'sftp_media_file_state.dart';

class SFTPMediaReadDirectoryCubit extends Cubit<SFTPMediaFileAccessState> {
  final SftpClient _sftpClient;
  final bool autoClose;

  factory SFTPMediaReadDirectoryCubit.fromSSHConnectedState(
      SSHConnectedState state,
      [bool autoClose = false]) {
    return SFTPMediaReadDirectoryCubit(state.sftpClient, autoClose);
  }

  SFTPMediaReadDirectoryCubit(this._sftpClient, [this.autoClose = false])
      : super(SFTPMediaFileAccessState.waiting);

  Future<void> read(TMDBLibraryMedia media) async {
    final remoteFilePath = '$kRootRemoteDirPath/${media.absolutePath}';
    await Future.delayed(const Duration(seconds: 1));
    emit(SFTPMediaFileAccessState.loading);
    final remoteFiles = <NetfloxFilePath>[];
    Object? exception;
    try {
      final fileNames =
          await _sftpClient.listdir(remoteFilePath).timeout(kDefaultTimeout);
      fileNames.removeWhere((element) => !element.attr.isFile);
      for (final name in fileNames) {
        final uri = Uri.file("$remoteFilePath/${name.filename}");
        final file = NetfloxFilePath(uri);
        remoteFiles.add(file);
      }
    } catch (e) {
      exception = e;
    } finally {
      final libraryFiles = TMDBMediaLibraryFiles.fromFiles(remoteFiles);
      emit(SFTPMediaFileAccessState.open(
        libraryFiles,
        exception: exception,
      ));
    }
  }

  @override
  Future<void> close() {
    if (autoClose) {
      _sftpClient.close();
    }
    return super.close();
  }
}

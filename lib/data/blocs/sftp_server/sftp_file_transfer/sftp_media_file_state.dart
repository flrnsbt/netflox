part of 'sftp_media_file_access_cubit.dart';

class SFTPMediaFileAccessState extends Equatable {
  final SFTPMediaFileUploadStatus status;
  bool idle() => status == SFTPMediaFileUploadStatus.waiting;
  bool isLoading() => status == SFTPMediaFileUploadStatus.loading;
  bool failed() => this is SFTPMediaAccessFailedState;
  bool opened() => this is SFTPMediaOpenedState;

  const SFTPMediaFileAccessState._(
      [this.status = SFTPMediaFileUploadStatus.waiting]);

  static SFTPMediaAccessFailedState fail(Object exception) =>
      SFTPMediaAccessFailedState._(exception);

  static const SFTPMediaFileAccessState waiting = SFTPMediaFileAccessState._();
  static const SFTPMediaFileAccessState loading =
      SFTPMediaFileAccessState._(SFTPMediaFileUploadStatus.loading);

  static SFTPMediaOpenedState open(TMDBMediaLibraryFiles remoteFiles,
          {Object? exception}) =>
      SFTPMediaOpenedState._(remoteFiles, exception: exception);

  @override
  List<Object?> get props => [status];
}

class SFTPMediaAccessFailedState extends SFTPMediaFileAccessState {
  final Object exception;
  const SFTPMediaAccessFailedState._(this.exception)
      : super._(SFTPMediaFileUploadStatus.waiting);

  @override
  List<Object?> get props => super.props + [exception];
}

class SFTPMediaOpenedState extends SFTPMediaFileAccessState {
  final TMDBMediaLibraryFiles remoteFiles;

  final Object? exception;

  const SFTPMediaOpenedState._(this.remoteFiles, {this.exception})
      : super._(SFTPMediaFileUploadStatus.transfering);

  @override
  List<Object?> get props => super.props + [exception, remoteFiles];

  @override
  String toString() =>
      'SFTPMediaOpenedState(docs: $remoteFiles, exception: $exception)';
}

enum SFTPMediaFileUploadStatus { loading, waiting, finished, transfering }

class SFTPMediaFileUploadState extends Equatable {
  final Object? exception;
  final TMDBLibraryMedia? media;
  final SFTPMediaFileUploadStatus status;
  const SFTPMediaFileUploadState._(this.status, {this.media, this.exception});

  static const SFTPMediaFileUploadState waiting = SFTPMediaFileUploadState._(
    SFTPMediaFileUploadStatus.waiting,
  );
  static SFTPMediaFileUploadState loading(TMDBLibraryMedia media) =>
      SFTPMediaFileUploadState._(SFTPMediaFileUploadStatus.loading,
          media: media);
  static SFTPMediaFileUploadingState uploading(TMDBLibraryMedia media,
          Stream<int> progress, String fileName, int fileSize) =>
      SFTPMediaFileUploadingState._(media, progress, fileName, fileSize);

  bool isLoading() => status == SFTPMediaFileUploadStatus.loading;
  bool isUploading() => status == SFTPMediaFileUploadStatus.transfering;
  bool isFinished() => status == SFTPMediaFileUploadStatus.finished;
  bool isWaiting() => status == SFTPMediaFileUploadStatus.waiting;
  bool isIdle() => isFinished() || isWaiting();
  bool failed() => exception != null;

  static SFTPMediaFileUploadFinishedState finished(
          TMDBLibraryMedia media, TMDBMediaLibraryFiles mediaLibraryFiles) =>
      SFTPMediaFileUploadFinishedState._(media, mediaLibraryFiles);
  static SFTPMediaFileUploadState fail(
          {TMDBLibraryMedia? media, required Object exception}) =>
      SFTPMediaFileUploadState._(SFTPMediaFileUploadStatus.waiting,
          media: media, exception: exception);

  @override
  List<Object?> get props => [exception, status, media];
}

class SFTPMediaFileUploadingState extends SFTPMediaFileUploadState {
  final Stream<int> bytesTransmitted;

  final int fileSize;
  final String fileName;
  const SFTPMediaFileUploadingState._(TMDBLibraryMedia media,
      this.bytesTransmitted, this.fileName, this.fileSize, [Object? exception])
      : super._(SFTPMediaFileUploadStatus.transfering,
            media: media, exception: exception);

  Future<bool> done() async {
    return (await bytesTransmitted.last) >= fileSize;
  }

  @override
  List<Object?> get props => super.props + [bytesTransmitted, fileName];
}

class SFTPMediaFileUploadFinishedState extends SFTPMediaFileUploadState {
  final TMDBMediaLibraryFiles mediaLibraryFiles;
  const SFTPMediaFileUploadFinishedState._(
      TMDBLibraryMedia media, this.mediaLibraryFiles)
      : super._(SFTPMediaFileUploadStatus.finished, media: media);

  @override
  List<Object?> get props => super.props + [mediaLibraryFiles];
}

extension SftpClientRemoveAll on SftpClient {
  Future<void> removeAll(Iterable<String> fileNames) async {
    try {
      for (final fileName in fileNames) {
        await remove(fileName);
      }
    } catch (e) {
      rethrow;
    }
  }
}

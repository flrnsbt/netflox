part of 'sftp_media_file_access_cubit.dart';

abstract class SFTPMediaFileAccessState extends Equatable {
  bool isWaiting() => this is SFTPMediaAccessWaitingState;
  bool failed() => this is SFTPMediaAccessFailedState;
  bool opened() => this is SFTPMediaOpenedState;

  const SFTPMediaFileAccessState();

  static SFTPMediaAccessFailedState fail(Object exception) =>
      SFTPMediaAccessFailedState._(exception);

  static const SFTPMediaAccessWaitingState waiting =
      SFTPMediaAccessWaitingState._();

  static SFTPMediaOpenedState open(TMDBMediaLibraryRemoteDocument docs,
          {Object? exception}) =>
      SFTPMediaOpenedState._(docs, exception: exception);

  @override
  List<Object?> get props => [];
}

class SFTPMediaAccessFailedState extends SFTPMediaFileAccessState {
  final Object exception;
  const SFTPMediaAccessFailedState._(this.exception);

  @override
  List<Object?> get props => [exception];
}

class SFTPMediaAccessWaitingState extends SFTPMediaFileAccessState {
  const SFTPMediaAccessWaitingState._();
}

class SFTPMediaOpenedState extends SFTPMediaFileAccessState {
  final TMDBMediaLibraryRemoteDocument docs;

  final Object? exception;

  const SFTPMediaOpenedState._(this.docs, {this.exception});

  @override
  List<Object?> get props => [exception, docs];

  @override
  String toString() =>
      'SFTPMediaOpenedState(docs: $docs, exception: $exception)';
}

class SFTPMediaFileUploadState extends Equatable {
  final Object? exception;
  const SFTPMediaFileUploadState._([this.exception]);

  static const waiting = SFTPMediaFileUploadState._();
  static SFTPMediaFileUploadingState upload(
          Stream<int> progress, String fileName, int fileSize) =>
      SFTPMediaFileUploadingState._(progress, fileName, fileSize);

  bool isUploading() => this is SFTPMediaFileUploadingState;
  bool isFinished() => this is SFTPMediaFileFinishedState;
  bool isIdle() => !isUploading();
  bool failed() => exception != null;

  static const finished = SFTPMediaFileFinishedState();
  static fail(Object exception) => SFTPMediaFileUploadState._(exception);

  @override
  List<Object?> get props => [exception];
}

class SFTPMediaFileUploadingState extends SFTPMediaFileUploadState {
  final Stream<int> bytesTransmitted;

  int? _timestamp;

  Stream<double> get bandwidth => bytesTransmitted.map((event) {
        {
          final currentTimestamp = Timestamp.now().millisecondsSinceEpoch;
          final deltaTime = currentTimestamp - (_timestamp ?? 0);
          _timestamp = currentTimestamp;
          return event / deltaTime / 1000;
        }
      });
  final int fileSize;
  final String fileName;
  SFTPMediaFileUploadingState._(
      this.bytesTransmitted, this.fileName, this.fileSize)
      : super._();

  Future<bool> done() async {
    return (await bytesTransmitted.last) >= 100;
  }

  @override
  List<Object?> get props => [bytesTransmitted, fileName];
}

class SFTPMediaFileFinishedState extends SFTPMediaFileUploadState {
  const SFTPMediaFileFinishedState() : super._();
}

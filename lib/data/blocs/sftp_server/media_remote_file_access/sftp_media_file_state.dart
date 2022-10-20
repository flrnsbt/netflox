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

  static SFTPMediaOpenedState open(SftpFile video,
          {Map<Language, Subtitles>? subtitles, Object? exception}) =>
      SFTPMediaOpenedState._(video, exception: exception, subtitles: subtitles);

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
  final SftpFile video;
  final Map<Language, Subtitles> subtitles;
  final Object? exception;

  SFTPMediaOpenedState._(this.video,
      {this.exception, Map<Language, Subtitles>? subtitles})
      : subtitles = subtitles ?? {};

  @override
  List<Object?> get props => [exception, video, subtitles];

  @override
  String toString() =>
      'SFTPMediaOpenedState(video: $video, subtitles: ${subtitles.keys}, exception: $exception)';
}

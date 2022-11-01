import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/utils/subtitle_helper.dart';

const String kRootRemoteDirPath = "netfloxDisk";
const String kVideoDefaultFileName = 'video';
// ignore: constant_identifier_names
const String MP4 = 'mp4';

extension UriPathUtil on Uri {
  String get fileName => pathSegments.last;
  String get fileExtension => fileName.split(".").last;
}

class NetfloxFilePath {
  factory NetfloxFilePath.fromPath(String path) {
    return NetfloxFilePath(Uri.parse(path));
  }
  const NetfloxFilePath(this.fileUri);

  final Uri fileUri;

  String get filePath => fileUri.path;

  bool isExtension(String extension) {
    return fileUri.fileExtension == extension;
  }

  bool isLocalFile() => !isRemoteFile();

  bool isRemoteFile() => fileUri.pathSegments.first == kRootRemoteDirPath;

  @override
  String toString() {
    return filePath;
  }
}

class TMDBMediaRemoteLibraryFiles extends TMDBMediaLibraryFilesInterfaces {
  @override
  final Map<Language, SftpFile> subtitleFilesPath;

  @override
  final SftpFile videoFilePath;

  const TMDBMediaRemoteLibraryFiles(this.subtitleFilesPath, this.videoFilePath);
}

class TMDBMediaLibraryFiles extends TMDBMediaLibraryFilesInterfaces
    implements TMDBMediaLibraryLanguageConfiguration {
  @override
  final Map<Language, NetfloxFilePath> subtitleFilesPath;

  @override
  final NetfloxFilePath? videoFilePath;

  final Iterable<NetfloxFilePath> otherFiles;

  const TMDBMediaLibraryFiles(
      {this.subtitleFilesPath = const {},
      this.videoFilePath,
      this.videoLanguage,
      this.otherFiles = const []});

  factory TMDBMediaLibraryFiles.fromFiles(Iterable<NetfloxFilePath> files) {
    final mapSubtitleFiles = <Language, NetfloxFilePath>{};
    final subtitleFiles =
        files.where((e) => e.isExtension(SubtitleType.srt.name));
    for (final file in subtitleFiles) {
      final language =
          Language.fromIsoCode(file.fileUri.fileName.split(".").first);
      mapSubtitleFiles.putIfAbsent(language, () => file);
    }
    NetfloxFilePath? videoFile;
    try {
      videoFile = files.singleWhere(
          (e) => e.fileUri.fileName == "$kVideoDefaultFileName.$MP4");
    } catch (e) {
      //
    }
    final otherFiles =
        files.where((e) => e != videoFile && !subtitleFiles.contains(e));
    return TMDBMediaLibraryFiles(
        videoFilePath: videoFile,
        subtitleFilesPath: mapSubtitleFiles,
        otherFiles: otherFiles);
  }

  @override
  final Language? videoLanguage;
  @override
  Iterable<Language> get subtitleLanguages => subtitleFilesPath.keys;

  bool isUploadable() {
    return videoFilePath != null || subtitleFilesPath.isNotEmpty;
  }

  bool playable() {
    return videoFilePath != null;
  }
}

abstract class TMDBMediaLibraryFilesInterfaces extends Equatable {
  get videoFilePath;
  Map<Language, dynamic> get subtitleFilesPath;

  const TMDBMediaLibraryFilesInterfaces();

  @override
  List<Object?> get props => [videoFilePath, subtitleFilesPath];
}

abstract class TMDBMediaLibraryLanguageConfiguration extends Equatable {
  Language? get videoLanguage;
  Iterable<Language> get subtitleLanguages;

  @override
  List<Object?> get props => [videoLanguage, subtitleLanguages];
}

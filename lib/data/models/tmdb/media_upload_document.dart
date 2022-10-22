import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:language_picker/languages.dart';

abstract class TMDBMediaLibraryDocuments extends Equatable {
  get videoFile;
  Language? get videoLanguage;
  Map<Language, dynamic>? get subtitleFiles;

  const TMDBMediaLibraryDocuments();

  @override
  List<Object?> get props => [videoFile, videoLanguage, subtitleFiles];
}

class TMDBMediaLibraryUploadDocument extends TMDBMediaLibraryDocuments {
  @override
  final Map<Language, File?>? subtitleFiles;

  @override
  final File videoFile;

  @override
  final Language? videoLanguage;

  const TMDBMediaLibraryUploadDocument(
      {this.subtitleFiles, required this.videoFile, this.videoLanguage})
      : super();
}

class TMDBMediaLibraryRemoteDocument extends TMDBMediaLibraryDocuments {
  @override
  final Map<Language, SftpFile>? subtitleFiles;

  @override
  final SftpFile videoFile;

  @override
  final Language? videoLanguage;

  const TMDBMediaLibraryRemoteDocument(
      {this.subtitleFiles, required this.videoFile, this.videoLanguage})
      : super();
}

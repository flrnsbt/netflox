import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:language_picker/languages.dart';

Color? mediaStatusColor(MediaStatus mediaStatus) {
  switch (mediaStatus) {
    case MediaStatus.available:
      return Colors.green;
    case MediaStatus.pending:
      return Colors.amber;

    case MediaStatus.rejected:
      return Colors.red;
    case MediaStatus.unavailable:
      return null;
  }
}

enum MediaStatus {
  available,
  pending,
  unavailable,
  rejected;

  @override
  String toString() {
    return name;
  }

  factory MediaStatus.fromString(String? name) {
    return MediaStatus.values.firstWhere((e) => e.name == name,
        orElse: () => MediaStatus.unavailable);
  }
}

class LibraryMediaInformation with LanguageProvider {
  final MediaStatus mediaStatus;
  final Timestamp? addedOn;

  bool isAvailable() => mediaStatus == MediaStatus.available;

  const LibraryMediaInformation(
      {this.mediaStatus = MediaStatus.unavailable,
      this.subtitles,
      this.languages,
      this.addedOn});

  static LibraryMediaInformation fromMap(Map<String, dynamic> map) {
    return LibraryMediaInformation(
        addedOn: map['added_on'],
        mediaStatus: MediaStatus.fromString(map['media_status']),
        subtitles: map['subtitles']
            ?.map<Language>((e) => Language.fromIsoCode(e))
            ?.toList(),
        languages: map['languages']
            ?.map<Language>((e) => Language.fromIsoCode(e))
            ?.toList());
  }

  @override
  final List<Language>? languages;

  @override
  final List<Language>? subtitles;

  Map<String, dynamic> toMap() {
    return {
      if (languages != null) 'languages': languages!.map((e) => e.isoCode),
      if (subtitles != null) 'subtitles': subtitles,
      'media_status': mediaStatus.name,
      'added_on': addedOn ?? Timestamp.now(),
    };
  }

  @override
  String toString() {
    return 'LibraryMediaInformation(mediaStatus: $mediaStatus, addedOn: $addedOn)';
  }
}

mixin LanguageProvider {
  List<Language>? get languages;
  List<Language>? get subtitles;
}

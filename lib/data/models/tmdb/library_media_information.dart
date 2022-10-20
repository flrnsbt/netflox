import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/type.dart';

Color mediaStatusColor(MediaStatus mediaStatus) {
  switch (mediaStatus) {
    case MediaStatus.available:
      return Colors.green;
    case MediaStatus.pending:
      return Colors.amber;
    case MediaStatus.unavailable:
      return Colors.white30;
    case MediaStatus.rejected:
      return Colors.red;
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
  final TMDBType<TMDBLibraryMedia> type;
  final String id;

  bool isAvailable() => mediaStatus == MediaStatus.available;

  LibraryMediaInformation(
      {this.mediaStatus = MediaStatus.unavailable,
      required this.id,
      required this.type,
      this.subtitles,
      this.languages,
      this.addedOn});

  static LibraryMediaInformation fromMap(Map<String, dynamic> map) {
    final type =
        TMDBType.fromString(map['media_type']) as TMDBType<TMDBLibraryMedia>;
    return LibraryMediaInformation(
        addedOn: map['added_on'],
        type: type,
        id: map['id'],
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
      'media_type': type.name,
      'id': id,
    };
  }

  @override
  String toString() {
    return 'LibraryMediaInformation(mediaStatus: $mediaStatus, addedOn: $addedOn, type: $type, id: $id)';
  }
}

mixin LanguageProvider {
  List<Language>? get languages;
  List<Language>? get subtitles;
}

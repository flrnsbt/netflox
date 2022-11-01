import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/tmdb_service.dart';
import '../../../models/tmdb/filter_parameter.dart';
import '../../../models/tmdb/library_media_information.dart';
import '../../../models/tmdb/media.dart';
import '../paged_data_collection_fetch_bloc.dart';

class LibraryMediaExploreBloc<T extends TMDBLibraryMedia>
    extends PagedDataCollectionFetchBloc<LibraryFilterParameter<T>, T>
    with FirestoreDataCollection {
  @override
  final TMDBService tmdbService;

  LibraryMediaExploreBloc(BuildContext context)
      : tmdbService = context.read<TMDBService>();

  @override
  Query<Map<String, dynamic>> queryBuilder(
      LibraryFilterParameter<T> parameters) {
    final mediaStatus = parameters.status.name;
    final typeNames = parameters.selectedtypes.map((e) => e.path).toList();
    final language = parameters.language?.isoCode;
    var query = FirestoreService.media
        .where("media_status", isEqualTo: mediaStatus)
        .where("media_type", whereIn: typeNames)
        .orderBy(parameters.sortCriterion.toString(),
            descending: parameters.sortOrder.isDescending);

    if (language != null) {
      query = query.where('languages', arrayContains: language);
    }
    return query;
  }

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> postQueryFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      LibraryFilterParameter<T> parameters) {
    final subtitle = parameters.subtitle?.isoCode;
    if (subtitle != null) {
      return docs
          .where((e) => e.data()['subtitles']?.contains(subtitle) ?? false)
          .toList();
    }
    return docs;
  }

  @override
  void appendToElement(Map<String, dynamic> rawData, T element) {
    final libraryMediaInformation = LibraryMediaInformation.fromMap(rawData);
    element.libraryMediaInfo = libraryMediaInformation;
  }
}

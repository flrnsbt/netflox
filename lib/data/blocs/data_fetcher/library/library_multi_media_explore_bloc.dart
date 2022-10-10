part of '../paged_data_collection_fetch_bloc.dart';

class LibraryMediaExploreBloc
    extends PagedDataCollectionFetchBloc<LibraryFilterParameter> {
  final TMDBService _tmdbService;

  LibraryMediaExploreBloc(BuildContext context)
      : _tmdbService = context.read<TMDBService>();

  @override
  void reset() {
    _lastDoc = null;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchFromFirestore(
      LibraryFilterParameter parameters) async {
    final mediaStatus = parameters.status.name;
    final typeNames = parameters.types.map((e) => e.name).toList();
    final languages = parameters.languages?.map((e) => e.languageCode).toList();
    final subtitles = parameters.subtitles;
    var query = FirestoreService.media
        .where("media_status", isEqualTo: mediaStatus)
        .where("media_type", whereIn: typeNames)
        .orderBy(parameters.sortCriterion.toString(),
            descending: parameters.sortOrder.isDescending);

    if (languages != null) {
      query = query.where('languages', whereIn: languages);
    }
    if (subtitles != null) {
      query = query.where('subtitles', whereIn: subtitles);
    }
    final result = await query.fetchAfterDoc(_lastDoc);
    return result.docs;
  }

  DocumentSnapshot? _lastDoc;

  @override
  Future<TMDBCollectionResult<TMDBPrimaryMedia>> __fetch(
      LibraryFilterParameter parameters, int page) async {
    try {
      final docs = await _fetchFromFirestore(parameters);
      if (docs.isNotEmpty) {
        _lastDoc = docs.last;
      }
      final allData = <TMDBMultiMedia>[];
      for (final doc in docs) {
        final data = doc.data();
        dynamic libraryMediaInformation = LibraryMediaInformation.fromMap(data);
        final result = await _tmdbService.getMultimedia(
            id: libraryMediaInformation.id, type: libraryMediaInformation.type);

        if (result.hasData()) {
          final media = result.data!;
          media.libraryMediaInfo = libraryMediaInformation;
          allData.add(media);
        }
      }
      return TMDBCollectionResult(
        data: allData,
      );
    } catch (e) {
      rethrow;
    }
  }
}

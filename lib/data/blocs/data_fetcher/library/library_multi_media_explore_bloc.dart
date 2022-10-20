part of '../paged_data_collection_fetch_bloc.dart';

class LibraryMediaExploreBloc
    extends PagedDataCollectionFetchBloc<LibraryFilterParameter> {
  final TMDBService _tmdbService;

  LibraryMediaExploreBloc(BuildContext context)
      : _tmdbService = context.read<TMDBService>();

  @override
  void resetPage() {
    _lastDoc = null;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchFromFirestore(
      LibraryFilterParameter parameters) async {
    final mediaStatus = parameters.status.name;
    final typeNames = parameters.types.map((e) => e.name).toList();
    final language = parameters.language?.isoCode;
    final subtitle = parameters.subtitle?.isoCode;
    var query = FirestoreService.media
        .where("media_status", isEqualTo: mediaStatus)
        .where("media_type", whereIn: typeNames)
        .orderBy(parameters.sortCriterion.toString(),
            descending: parameters.sortOrder.isDescending);

    if (language != null) {
      query = query.where('languages', arrayContains: language);
    }

    final result = await query.fetchAfterDoc(_lastDoc);
    final docs = result.docs;
    if (subtitle != null) {
      return docs
          .where((e) => e.data()['subtitles']?.contains(subtitle) ?? false)
          .toList();
    }
    return docs;
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

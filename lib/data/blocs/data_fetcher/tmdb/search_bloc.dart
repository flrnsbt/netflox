part of '../paged_data_collection_fetch_bloc.dart';

class TMDBPrimaryMediaSearchBloc
    extends PagedDataCollectionFetchBloc<SearchFilterParameter> {
  final TMDBService _tmdbService;

  TMDBPrimaryMediaSearchBloc(BuildContext context)
      : _tmdbService = context.read<TMDBService>();

  TMDBPrimaryMediaSearchBloc.fromTMDBService({required TMDBService tmdbService})
      : _tmdbService = tmdbService;

  @override
  Future<TMDBCollectionResult<TMDBPrimaryMedia>> __fetch(
      SearchFilterParameter<TMDBPrimaryMedia> parameters, int page) {
    final searchTerms = parameters.searchTerms;
    final year = parameters.year;
    final type = parameters.type;
    if ((searchTerms?.isEmpty ?? true) && !type.isPeople()) {
      return _tmdbService.trending(mediaType: type, page: page);
    } else {
      return _tmdbService.search(searchTerms ?? "",
          mediaType: type, page: page, year: year);
    }
  }
}

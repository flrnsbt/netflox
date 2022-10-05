part of '../data_collection_fetch_bloc.dart';

class TMDBPrimaryMediaSearchBloc
    extends DataCollectionFetchBloc<SearchFilterParameter> {
  final TMDBService _tmdbService;

  TMDBPrimaryMediaSearchBloc(BuildContext context)
      : _tmdbService = context.read<TMDBService>();

  TMDBPrimaryMediaSearchBloc.fromTMDBService({required TMDBService tmdbService})
      : _tmdbService = tmdbService;

  @override
  Future<TMDBCollectionResult<TMDBPrimaryMedia>> __fetch(
      PagedRequestParameter<SearchFilterParameter<TMDBPrimaryMedia>>
          parameters) {
    final searchTerms = parameters.currentFilter.searchTerms;
    final page = parameters.currentPage;
    final year = parameters.currentFilter.year;
    final type = parameters.currentFilter.type;
    if ((searchTerms?.isEmpty ?? true) && year == null) {
      return _tmdbService.trending(mediaType: type, page: page);
    } else {
      return _tmdbService.search(searchTerms ?? "",
          mediaType: type, page: page, year: year);
    }
  }
}

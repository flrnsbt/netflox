part of '../data_collection_fetch_bloc.dart';

class TMDBMultimediaDiscoverBloc
    extends DataCollectionFetchBloc<DiscoverFilterParameter> {
  final TMDBService _tmdbService;
  TMDBMultimediaDiscoverBloc({required BuildContext context})
      : _tmdbService = context.read<TMDBService>();

  @override
  Future<TMDBCollectionResult<TMDBPrimaryMedia>> __fetch(
      PagedRequestParameter<DiscoverFilterParameter<TMDBMultiMedia>>
          parameters) {
    return _tmdbService.discover(parameters.currentFilter.type,
        sortParameter: parameters.currentFilter.sortParameter,
        genres: parameters.currentFilter.genres,
        // language: _currentParameters!.language,
        year: parameters.currentFilter.year,
        page: parameters.currentPage);
  }
}

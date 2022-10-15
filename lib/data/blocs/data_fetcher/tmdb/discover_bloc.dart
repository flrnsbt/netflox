part of '../paged_data_collection_fetch_bloc.dart';

class TMDBMultimediaDiscoverBloc
    extends PagedDataCollectionFetchBloc<DiscoverFilterParameter> {
  final TMDBService _tmdbService;
  TMDBMultimediaDiscoverBloc({required BuildContext context})
      : _tmdbService = context.read<TMDBService>();

  @override
  Future<TMDBCollectionResult<TMDBPrimaryMedia>> __fetch(
      DiscoverFilterParameter<TMDBMultiMedia> parameters, int page) {
    return _tmdbService.discover(parameters.type,
        sortParameter: parameters.sortParameter,
        genres: parameters.genres,
        mediaLanguage: parameters.originalLanguage?.isoCode,
        year: parameters.year,
        page: page);
  }
}

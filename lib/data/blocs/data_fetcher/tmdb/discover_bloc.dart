import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/tmdb_service.dart';
import '../../../models/tmdb/filter_parameter.dart';
import '../../../models/tmdb/media.dart';
import '../../../repositories/tmdb_result.dart';
import '../paged_data_collection_fetch_bloc.dart';

class TMDBMultimediaDiscoverBloc extends PagedDataCollectionFetchBloc<
    DiscoverFilterParameter, TMDBMultiMedia> {
  final TMDBService _tmdbService;
  TMDBMultimediaDiscoverBloc({required BuildContext context})
      : _tmdbService = context.read<TMDBService>();

  @override
  Future<TMDBCollectionResult<TMDBMultiMedia>> get(
      DiscoverFilterParameter<TMDBMultiMedia> parameters, int page) {
    return _tmdbService.discover(parameters.type,
        sortParameter: parameters.sortParameter,
        genres: parameters.genres,
        mediaLanguage: parameters.originalLanguage?.isoCode,
        year: parameters.year,
        page: page);
  }
}

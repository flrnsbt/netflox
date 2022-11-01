import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/tmdb_service.dart';
import '../../../models/tmdb/filter_parameter.dart';
import '../../../models/tmdb/media.dart';
import '../../../repositories/tmdb_result.dart';
import '../paged_data_collection_fetch_bloc.dart';

class TMDBPrimaryMediaSearchBloc extends PagedDataCollectionFetchBloc<
    SearchFilterParameter, TMDBPrimaryMedia> {
  final TMDBService _tmdbService;

  TMDBPrimaryMediaSearchBloc(BuildContext context)
      : _tmdbService = context.read<TMDBService>();

  TMDBPrimaryMediaSearchBloc.fromTMDBService({required TMDBService tmdbService})
      : _tmdbService = tmdbService;

  @override
  Future<TMDBCollectionResult<TMDBPrimaryMedia>> get(
      SearchFilterParameter<TMDBPrimaryMedia> parameters, int page) {
    final searchTerms = parameters.searchTerms;
    final year = parameters.year;
    final type = parameters.type;
    if ((searchTerms?.isEmpty ?? true) && !type.isPeople() && year == null) {
      return _tmdbService.trending(mediaType: type, page: page);
    } else {
      return _tmdbService.search(searchTerms ?? "",
          mediaType: type, page: page, year: year);
    }
  }
}

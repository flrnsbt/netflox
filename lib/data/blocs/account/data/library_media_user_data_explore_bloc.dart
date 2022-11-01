import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/account/auth/auth_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/tmdb_service.dart';
import '../../../models/tmdb/filter_parameter.dart';
import '../../../models/tmdb/media.dart';
import '../../data_fetcher/paged_data_collection_fetch_bloc.dart';

class LibraryMediaUserDataExploreBloc extends PagedDataCollectionFetchBloc<
    LibraryUserDataFilterParameter,
    TMDBLibraryMedia> with FirestoreDataCollection {
  @override
  final TMDBService tmdbService;
  final CollectionReference<Map<String, dynamic>> _collectionRef;
  LibraryMediaUserDataExploreBloc(BuildContext context)
      : _collectionRef = FirestoreService.userMediaData(
            context.read<AuthCubit>().state.user!.id),
        tmdbService = context.read<TMDBService>();

  @override
  Query<Map<String, dynamic>> queryBuilder(
      LibraryUserDataFilterParameter<TMDBLibraryMedia> parameters) {
    final liked = parameters.liked;
    final watched = parameters.watched;
    var query = _collectionRef.where("liked", isEqualTo: liked);
    if (watched != null) {
      query = query
          .where("playback_time", isNull: !watched)
          .orderBy('playback_time');
    }
    query = query.orderBy(parameters.sortCriterion.toString(),
        descending: parameters.sortOrder.isDescending);

    return query;
  }
}

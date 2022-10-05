import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/season.dart';
import 'package:netflox/data/models/tmdb/type.dart';
import 'package:netflox/data/models/tmdb/people.dart';
import 'package:netflox/data/models/tmdb/video.dart';
import 'package:netflox/services/tmdb_service.dart';
import '../../../repositories/tmdb_result.dart';
import '../basic_server_fetch_state.dart';

abstract class TMDBElementCubit<K> extends Cubit<BasicServerFetchState<K>> {
  final TMDBService _tmdbService;
  final String _id;

  TMDBElementCubit(
      {required String id,
      required BuildContext context,
      bool autoFetch = true})
      : _tmdbService = context.read<TMDBService>(),
        _id = id,
        super(BasicServerFetchState.loading()) {
    if (autoFetch) {
      fetch();
    }
  }

  Future<void> fetch() async {
    if (!isClosed) {
      emit(BasicServerFetchState.loading());
      try {
        final result = await _fetch();
        emit(BasicServerFetchState.finished(result: result));
      } catch (e) {
        final exception = NetfloxException.from(e);
        emit(BasicServerFetchState.failed(exception));
      }
    }
  }

  @override
  Future<void> close() {
    _tmdbService.close(true);
    return super.close();
  }

  Future _fetch();
}

class TMDBSeasonCubit extends TMDBElementCubit<TMDBTVSeason> {
  final int seasonNumber;
  TMDBSeasonCubit(
      {required super.id, required this.seasonNumber, required super.context});

  @override
  Future<TMDBTVSeason?> _fetch() async {
    final result = await _tmdbService.getSeason(
      tvShowId: _id,
      seasonNumber: seasonNumber,
    );
    if (result.hasData()) {
      return result.data;
    }
    return null;
  }
}

class TMDBPrimaryMediaCubit<T extends TMDBPrimaryMedia>
    extends TMDBElementCubit<T> {
  final TMDBType<T> mediaType;
  TMDBPrimaryMediaCubit({
    required super.id,
    required this.mediaType,
    required super.context,
  });

  @override
  Future<T?> _fetch() async {
    final result =
        await _tmdbService.getPrimaryMedia<T>(id: _id, type: mediaType);
    if (result.hasData()) {
      return result.data!;
    }
    return null;
  }
}

class TMDBFetchVideosCubit extends TMDBElementCubit<List<TMDBVideo>> {
  final TMDBType<TMDBMultiMedia> mediaType;
  TMDBFetchVideosCubit({
    required super.id,
    required this.mediaType,
    required super.context,
  }) : assert(mediaType != TMDBMultiMediaType.any);

  factory TMDBFetchVideosCubit.fromMultiMedia(TMDBMultiMedia multiMedia,
      {required BuildContext context}) {
    return TMDBFetchVideosCubit(
      id: multiMedia.id,
      mediaType: multiMedia.type,
      context: context,
    );
  }
  @override
  Future<List<TMDBVideo>> _fetch() async {
    final data = <TMDBVideo>[];
    final result = await _tmdbService.getVideos(
      id: _id,
      mediaType: mediaType,
    );
    if (result.hasData()) {
      data.addAll(result.data!);
    }
    return data;
  }
}

class TMDBFetchMediaCredits extends TMDBElementCubit<List<TMDBPerson>> {
  final TMDBType<TMDBMultiMedia> type;
  TMDBFetchMediaCredits({
    required TMDBMultiMedia media,
    required super.context,
  })  : type = media.type,
        super(
          id: media.id,
        );

  @override
  Future<List<TMDBPerson>> _fetch() async {
    final data = <TMDBPerson>[];
    final result = await _tmdbService.getMediaCredits(id: _id, type: type);
    if (result.hasData()) {
      data.addAll(result.data!);
    }
    return data;
  }
}

class TMDBFetchMultimediaCollection<R extends MultimediaRequestType>
    extends TMDBElementCubit<List<TMDBMultiMedia>> {
  final TMDBType<TMDBMultiMedia> type;
  TMDBFetchMultimediaCollection({
    required TMDBMultiMedia media,
    required super.context,
  })  : type = media.type,
        super(
          id: media.id,
        );

  @override
  Future<List<TMDBMultiMedia>> _fetch() async {
    TMDBCollectionResult<TMDBMultiMedia> result;
    if (R == RecommendationRequestType) {
      result = await _tmdbService.getRecommendations(
          id: _id, mediaType: type, page: 1);
    } else {
      result =
          await _tmdbService.getSimilars(id: _id, mediaType: type, page: 1);
    }

    return result.data ?? <TMDBMultiMedia>[];
  }
}

mixin MultimediaRequestType {}

abstract class RecommendationRequestType with MultimediaRequestType {}

abstract class SimilarRequestType with MultimediaRequestType {}

class TMDBFetchPeopleCasting extends TMDBElementCubit<List<TMDBMultiMedia>> {
  TMDBFetchPeopleCasting({
    required TMDBPerson people,
    required super.context,
  }) : super(
          id: people.id,
        );

  @override
  Future<List<TMDBMultiMedia>> _fetch() async {
    final data = <TMDBMultiMedia>[];
    final result = await _tmdbService.getPersonCasting(id: _id);
    if (result.hasData()) {
      data.addAll(result.data!);
    }
    return data;
  }
}

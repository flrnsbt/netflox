import 'package:auto_route/auto_route.dart'
    show AutoRouteWrapper, PageRouteInfo, PathParam;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/library_media_information.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/movie.dart';
import 'package:netflox/data/models/tmdb/people.dart';
import 'package:netflox/data/models/tmdb/season.dart';
import 'package:netflox/data/models/tmdb/tv.dart';
import 'package:netflox/data/models/tmdb/type.dart';
import 'package:netflox/ui/router/idle_timed_auto_push_route.dart';
import 'package:netflox/ui/router/router.gr.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/widgets/tmdb/list_tmdb_media_card.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../data/blocs/account/data/library_media_user_data_cubit.dart';
import '../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../data/blocs/data_fetcher/library/library_media_cubit.dart';
import '../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';
import '../../widgets/framed_text.dart';
import '../../widgets/tmdb/media_screen_components/components.dart';
import '../../widgets/tmdb/media_screen_components/default_library_media_header.dart';
import '../../widgets/tmdb/media_screen_components/info_component.dart';
import '../../widgets/tmdb/tmdb_image.dart';
part 'movie_screen.dart';
part 'tv_show_screen.dart';
part 'people_screen.dart';

mixin TMDBPrimaryScreenWrapper<T extends TMDBPrimaryMedia>
    on TMDBMediaScreenWrapper<T> {
  @override
  BlocProvider<TMDBElementCubit<T>> wrappedRoute(BuildContext context) {
    return BlocProvider<TMDBElementCubit<T>>(
        create: (context) =>
            TMDBPrimaryMediaCubit(id: id, mediaType: type, context: context),
        child: this);
  }
}

abstract class TMDBMediaScreenWrapper<T extends TMDBMedia>
    extends StatelessWidget with AutoRouteWrapper {
  const TMDBMediaScreenWrapper({super.key});

  get id;
  get type => TMDBType<T>();

  @override
  BlocProvider<TMDBElementCubit<T>> wrappedRoute(BuildContext context);

  BlocProvider<LibraryMediaUserDataCubit> _provideLibraryMediaUserBloc(
      BuildContext context, TMDBLibraryMedia media) {
    final bloc = context.watch<LibraryMediaUserDataCubit?>();
    if (bloc != null) {
      return BlocProvider.value(value: bloc);
    } else {
      return BlocProvider(
        create: (context) => LibraryMediaUserDataCubit(context, media),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TMDBElementCubit<T>, BasicServerFetchState<T>>(
      builder: (context, state) {
        if (state.finished() && state.hasData()) {
          final media = state.result!;
          return MultiBlocProvider(providers: [
            if (media.type.isLibraryMedia()) ...[
              BlocProvider(
                create: (context) => TMDBFetchMediaCredits(
                    media: media as TMDBLibraryMedia, context: context),
              ),
              _provideLibraryMediaUserBloc(context, media as TMDBLibraryMedia)
            ],
            if (media.type.isPeople())
              BlocProvider(
                  create: (context) => TMDBFetchPeopleCasting(
                      people: media as TMDBPerson, context: context))
            else if (media.type.isMultimedia()) ...[
              BlocProvider(
                  create: (context) => TMDBFetchVideosCubit.fromMultiMedia(
                      media as TMDBMultiMedia,
                      context: context)),
              BlocProvider(
                  create: (context) =>
                      TMDBFetchMultimediaCollection<SimilarRequestType>(
                          media: media as TMDBMultiMedia, context: context)),
              BlocProvider(
                  create: (context) =>
                      TMDBFetchMultimediaCollection<RecommendationRequestType>(
                          media: media as TMDBMultiMedia, context: context)),
            ]
          ], child: buildLayout(context, media));
        } else if (state.failed()) {
          return ErrorScreen(
            errorCode: state.error,
          );
        }
        return const LoadingScreen();
      },
    );
  }

  Widget buildLayout(BuildContext context, T media);
}

class TMDBMediaRouteHelper {
  static pushRoute(BuildContext context, TMDBMedia media) {
    return context.router.push(_buildRoute(media));
  }

  static PageRouteInfo<dynamic> _buildTvElementRoutes(TMDBTVElement media) {
    final showId = media.showId;
    if (media.type.isTvEpisode()) {
      return TVShowEpisodeRoute(
          id: (media as TMDBTVEpisode).episodeNumber,
          seasonNumber: media.seasonNumber,
          showId: showId);
    } else {
      return TMDBTVShowSeasonRoute(id: media.seasonNumber, showId: showId);
    }
  }

  static PageRouteInfo<dynamic> _buildRoute(TMDBMedia media) {
    if (media.type.isMovie()) {
      return TMDBMovieRoute(id: media.id);
    } else if (media.type.isPeople()) {
      return TMDBPeopleRoute(id: media.id);
    } else if (media.type.isTV()) {
      return TMDBTvRoute(id: media.id);
    } else if (media.type.isTVElement()) {
      return _buildTvElementRoutes(media as TMDBTVElement);
    } else {
      return ErrorRoute();
    }
  }
}

class WrappedBuilderScreen extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  const WrappedBuilderScreen({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

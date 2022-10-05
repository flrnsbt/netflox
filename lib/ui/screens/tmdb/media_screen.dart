library mediascreen;

import 'package:auto_route/auto_route.dart';
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
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/widgets/custom_banner.dart';
import 'package:netflox/ui/widgets/easy_reponsive_layout_builder.dart';
import 'package:netflox/ui/widgets/rating_widget.dart';
import 'package:netflox/ui/widgets/tmdb/tmdb_media_card.dart';
import 'package:netflox/utils/reponsive_size_helper.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../data/blocs/data_fetcher/library/library_media_cubit.dart';
import '../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';
import '../../router/router.gr.dart';
import '../../widgets/tmdb/tmdb_image.dart';
import '../../widgets/framed_text.dart';
import '../error_screen.dart';
import 'media_screen_components/components.dart';
part 'movie_screen.dart';
part 'tv_show_screen.dart';
part 'people_screen.dart';

class MediaScreen extends StatelessWidget with AutoRouteWrapper {
  final String id;
  final dynamic mediaType;
  const MediaScreen(
      {super.key,
      @PathParam('id') required this.id,
      @PathParam('mediaType') required this.mediaType});

  factory MediaScreen.fromMedia(TMDBPrimaryMedia media) {
    return MediaScreen(id: media.id, mediaType: media.type);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TMDBPrimaryMediaCubit, BasicServerFetchState>(
      builder: (context, state) {
        if (state.finished() && state.hasData()) {
          final media = state.result!;
          return MultiBlocProvider(providers: [
            if (media.type.isPeople())
              BlocProvider(
                  create: (context) =>
                      TMDBFetchPeopleCasting(people: media, context: context))
            else if (media.type.isMultimedia()) ...[
              BlocProvider(
                create: (context) =>
                    TMDBFetchMediaCredits(media: media, context: context),
              ),
              BlocProvider(
                  create: (context) => TMDBFetchVideosCubit.fromMultiMedia(
                      media,
                      context: context)),
              BlocProvider(
                  create: (context) =>
                      TMDBFetchMultimediaCollection<SimilarRequestType>(
                          media: media, context: context)),
              BlocProvider(
                  create: (context) =>
                      TMDBFetchMultimediaCollection<RecommendationRequestType>(
                          media: media, context: context)),
            ]
          ], child: _buildLayout(media));
        }
        if (state.isLoading()) {
          return const LoadingScreen();
        }
        return ErrorScreen(
          error: state.error,
        );
      },
    );
  }

  Widget _buildLayout(TMDBMedia media) {
    switch (media.runtimeType) {
      case TMDBTv:
        return TMDBTvScreen(tv: media as TMDBTv);

      case TMDBMovie:
        return TMDBMovieScreen(movie: media as TMDBMovie);

      case TMDBPerson:
        return TMDBPeopleScreen(
          people: media as TMDBPerson,
        );
      default:
        return const ErrorScreen();
    }
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
        create: (context) => TMDBPrimaryMediaCubit(
            id: id, mediaType: mediaType, context: context),
        child: this);
  }
}

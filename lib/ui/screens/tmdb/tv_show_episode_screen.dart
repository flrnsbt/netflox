import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/data_fetcher/tmdb/element_cubit.dart';
import 'package:netflox/data/models/tmdb/season.dart';

import '../../widgets/tmdb/media_screen_components/components.dart';
import 'media_screen.dart';

class TVShowEpisodeScreen extends TMDBMediaScreenWrapper<TMDBTVEpisode> {
  final String showId;
  final int seasonNumber;
  const TVShowEpisodeScreen(
      {super.key,
      @PathParam('episodeNumber') required this.id,
      @PathParam('seasonNumber') required this.seasonNumber,
      @PathParam('id') required this.showId});

  factory TVShowEpisodeScreen.fromEpisode(TMDBTVEpisode episode) {
    return TVShowEpisodeScreen(
        id: episode.episodeNumber,
        seasonNumber: episode.seasonNumber,
        showId: episode.showId);
  }

  @override
  Widget buildLayout(BuildContext context, TMDBTVEpisode media) {
    return TMDBScreenBuilder(
      element: media,
      content: [
        if (media.overview?.isNotEmpty ?? false)
          MediaScreenComponent(
            name: 'overview'.tr(context),
            child: Text(
              media.overview!,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        const TMDBListMediaLayout<TMDBFetchMediaCredits>.carousel(
          title: 'credits',
          play: true,
          height: 180,
        ),
      ],
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (media.name != null)
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: AutoSizeText(
                  media.name!,
                  wrapWords: false,
                  maxLines: 3,
                  textAlign: TextAlign.end,
                  minFontSize: 25,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "${'season'.tr(context)} ${media.seasonNumber} : ${'episode'.tr(context)} ${media.episodeNumber}",
            style: const TextStyle(fontSize: 17),
          ),
          if (media.date != null) ...[
            const SizedBox(
              height: 10,
            ),
            Text(
              media.date!,
              style: const TextStyle(
                  fontSize: 13,
                  fontFamily: "Verdana",
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(
              height: 10,
            ),
            Flexible(
              flex: 2,
              child: LibraryMediaStatusWidget(
                media: media,
              ),
            ),
          ]
        ],
      ),
    );
  }

  @override
  final int id;

  @override
  BlocProvider<TMDBElementCubit<TMDBTVEpisode>> wrappedRoute(
      BuildContext context) {
    return BlocProvider(
      child: this,
      create: (context) => TMDBEpisodeCubit(
          id: showId,
          episodeNumber: id,
          seasonNumber: seasonNumber,
          context: context),
    );
  }
}

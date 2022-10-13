import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/season.dart';
import 'package:netflox/ui/router/router.gr.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/widgets/custom_banner.dart';
import 'package:netflox/ui/widgets/tmdb/tmdb_media_card.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../data/blocs/data_fetcher/library/library_media_cubit.dart';
import '../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';
import '../../../data/models/tmdb/library_media_information.dart';
import '../../widgets/tmdb/media_screen_components/components.dart';
import '../error_screen.dart';

class TVShowSeasonScreen extends StatelessWidget {
  final int seasonNumber;
  final String tvShowId;
  const TVShowSeasonScreen(
      {super.key,
      @PathParam('seasonNumber') required this.seasonNumber,
      @PathParam('tvShowId') required this.tvShowId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TMDBSeasonCubit(
          context: context, id: tvShowId, seasonNumber: seasonNumber)
        ..fetch(),
      child: BlocBuilder<TMDBSeasonCubit, BasicServerFetchState<TMDBTVSeason>>(
        builder: (context, state) {
          if (state.success() && state.hasData()) {
            final season = state.result!;
            return _buildLayout(context, season);
          }
          if (state.isLoading()) {
            return const LoadingScreen();
          }
          return ErrorScreen(errorCode: state.error);
        },
      ),
    );
  }

  Widget _buildEpisodeCard(BuildContext context, TMDBTVEpisode episode) {
    final episodeNumber = "${'episode'.tr(context)} ${episode.episodeNumber}";
    return BlocProvider(
      create: (context) => LibraryMediaInfoFetchCubit(episode),
      child: BlocBuilder<LibraryMediaInfoFetchCubit,
              BasicServerFetchState<LibraryMediaInformation>>(
          builder: (context, state) {
        final mediaStatus =
            state.result?.mediaStatus ?? MediaStatus.unavailable;
        return TMDBMediaCard(
          media: episode,
          onTap: (media) =>
              context.pushRoute(TVShowEpisodeRoute(episode: episode)),
          bannerOptions:
              CustomBannerOptions.mediaStatusBanner(context, mediaStatus),
          insetPadding: const EdgeInsets.all(10),
          showImageError: false,
          contentBuilder: (context, media) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AutoSizeText(
                    episode.name ?? episodeNumber,
                    maxLines: 2,
                    minFontSize: 10,
                    wrapWords: false,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  AutoSizeText(
                    "S$seasonNumber:E${episode.episodeNumber}",
                    maxLines: 1,
                    minFontSize: 7,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ]);
          },
          showHover: false,
        );
      }),
    );
  }

  Widget _buildLayout(BuildContext context, TMDBTVSeason season) {
    return TMDBScreenBuilder(
      element: season,
      content: [
        if (season.overview?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: MediaScreenComponent(
              name: 'overview'.tr(context),
              child: Text(
                season.overview!,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        if (season.episodes.isNotEmpty)
          MediaScreenComponent(
              backgroundColor: Colors.transparent,
              name: 'episodes'.tr(context),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const ResponsiveGridDelegate(
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    minCrossAxisExtent: 100,
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: season.episodes.length,
                itemBuilder: (context, index) {
                  return _buildEpisodeCard(context, season.episodes[index]);
                },
              ))
      ],
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (season.name != null)
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: AutoSizeText(
                  season.name!,
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
            "${season.episodeCount} ${'episodes'.tr(context)}",
            style: const TextStyle(fontSize: 17),
          ),
          if (season.date != null) ...[
            const SizedBox(
              height: 10,
            ),
            Text(
              season.date!,
              style: const TextStyle(
                  fontSize: 13,
                  fontFamily: "Verdana",
                  fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(
            height: 10,
          ),
          Flexible(
            flex: 2,
            child: LibraryMediaControlLayout(
              media: season,
            ),
          ),
        ],
      ),
    );
  }
}

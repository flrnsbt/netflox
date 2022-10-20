import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/season.dart';
import 'package:netflox/ui/router/router.gr.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/screens/tmdb/tv_show_episode_screen.dart';
import 'package:netflox/ui/widgets/framed_text.dart';
import 'package:netflox/ui/widgets/tmdb/list_tmdb_media_card.dart';
import 'package:nil/nil.dart';
import '../../../data/blocs/account/auth/user_account_data_cubit.dart';
import '../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../data/blocs/data_fetcher/library/library_media_cubit.dart';
import '../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';
import '../../../data/models/tmdb/library_media_information.dart';
import '../../widgets/tmdb/media_screen_components/components.dart';
import '../../widgets/tmdb/tmdb_image.dart';
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
    final playbackStateBloc =
        LibraryMediaUserPlaybackStateCubit(context, episode);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LibraryMediaInfoFetchCubit(episode)),
        BlocProvider(create: (context) => playbackStateBloc)
      ],
      child: BlocBuilder<LibraryMediaInfoFetchCubit,
              BasicServerFetchState<LibraryMediaInformation>>(
          builder: (context, state) {
        final mediaStatus =
            state.result?.mediaStatus ?? MediaStatus.unavailable;
        return TMDBListCard(
            image: TMDBImageWidget(
              aspectRatio: 4 / 5,
              img: episode.img,
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.only(right: 10),
              showError: false,
            ),
            title: episodeTitleBuilder(episode),
            subtitle: Row(children: [
              FramedText(
                text: mediaStatus.tr(context),
                color: mediaStatusColor(mediaStatus),
              ),
              BlocBuilder<LibraryMediaUserPlaybackStateCubit,
                  LibraryMediaUserPlaybackState>(
                builder: (context, state) {
                  if (state.watched) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: FramedText(
                        color: Theme.of(context).hintColor,
                        text: "watched".tr(context),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              )
            ]),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                        value: playbackStateBloc,
                        child: TVShowEpisodeScreen(episode: episode)))),
            content: Text(
              episode.overview!,
              softWrap: false,
              style:
                  TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ));
      }),
    );
  }

  Widget _buildLayout(BuildContext context, TMDBTVSeason season) {
    return TMDBScreenBuilder(
      element: season,
      content: [
        if (season.overview?.isNotEmpty ?? false)
          MediaScreenComponent(
            name: 'overview'.tr(context),
            child: Text(
              season.overview!,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        if (season.episodes.isNotEmpty)
          MediaScreenComponent(
              backgroundColor: Colors.transparent,
              name: 'episodes'.tr(context),
              padding: EdgeInsets.zero,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return _buildEpisodeCard(context, season.episodes[index]);
                },
                itemCount: season.episodes.length,
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

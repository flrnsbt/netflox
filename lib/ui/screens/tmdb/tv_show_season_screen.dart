import 'package:auto_route/auto_route.dart' show PathParam;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/router/idle_timed_auto_push_route.dart';
import 'package:netflox/ui/router/router.gr.dart';
import 'package:netflox/ui/widgets/framed_text.dart';
import 'package:netflox/ui/widgets/tmdb/list_tmdb_media_card.dart';
import '../../../data/blocs/account/data/library_media_user_data_cubit.dart';
import '../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../data/blocs/data_fetcher/library/library_media_cubit.dart';
import '../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';
import '../../../data/models/tmdb/library_media_information.dart';
import '../../../data/models/tmdb/season.dart';
import '../../widgets/tmdb/media_screen_components/components.dart';
import '../../widgets/tmdb/tmdb_image.dart';
import 'media_screen.dart';

class TMDBTVShowSeasonScreen extends TMDBMediaScreenWrapper<TMDBTVSeason> {
  final String showId;
  const TMDBTVShowSeasonScreen(
      {super.key,
      @PathParam('seasonNumber') required this.id,
      @PathParam('id') required this.showId});

  @override
  final int id;

  @override
  BlocProvider<TMDBElementCubit<TMDBTVSeason>> wrappedRoute(
      BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TMDBSeasonCubit(id: showId, seasonNumber: id, context: context),
      child: this,
    );
  }

  @override
  Widget buildLayout(BuildContext context, TMDBTVSeason media) {
    return TMDBScreenBuilder(
      element: media,
      content: [
        if (media.overview?.isNotEmpty ?? false)
          MediaScreenComponent(
            name: 'overview'.tr(context),
            child: Text(
              media.overview!,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        const TMDBListMediaLayout<TMDBFetchMediaCredits>.carousel(
          title: 'credits',
          play: true,
          height: 180,
        ),
        if (media.episodes.isNotEmpty)
          MediaScreenComponent(
              backgroundColor: Colors.transparent,
              name: 'episodes'.tr(context),
              padding: EdgeInsets.zero,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return _buildEpisodeCard(context, media.episodes[index]);
                },
                itemCount: media.episodes.length,
              ))
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
            "${media.episodeCount} ${'episodes'.tr(context)}",
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
          ],
          const SizedBox(
            height: 10,
          ),
          Flexible(
            flex: 2,
            child: LibraryMediaStatusWidget(
              media: media,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeCard(BuildContext context, TMDBTVEpisode episode) {
    final playbackStateBloc = LibraryMediaUserDataCubit(context, episode);
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
              BlocBuilder<LibraryMediaUserDataCubit, LibraryMediaUserDataState>(
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
            onTap: () {
              context.pushRoute(TVShowEpisodeRoute(
                  id: episode.episodeNumber, seasonNumber: id, showId: showId));
            },
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
}

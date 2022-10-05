import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/season.dart';
import 'package:netflox/ui/router/router.gr.dart';
import 'package:netflox/ui/widgets/default_sliver_grid.dart';
import 'package:netflox/ui/widgets/tmdb/tmdb_media_card.dart';

import 'media_screen_components/components.dart';

class TVShowEpisodeScreen extends StatelessWidget {
  final TMDBTVEpisode episode;
  const TVShowEpisodeScreen({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    return TMDBScreenBuilder(
      element: episode,
      content: [
        if (episode.overview?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 35),
            child: MediaScreenComponent(
              title: 'overview'.tr(context),
              child: Text(
                episode.overview!,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        if (episode.guests?.isNotEmpty ?? false)
          MediaScreenComponent(
            title: 'guest_stars'.tr(context),
            child: GridView.custom(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: DefaultSliverGrid.defaultGridDelegate,
              childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) => AspectRatio(
                      aspectRatio: 2 / 3,
                      child: TMDBMediaCard(
                        onTap: (media) =>
                            context.pushRoute(MediaRoute.fromMedia(media)),
                        media: episode.guests![index],
                        showBottomTitle: true,
                      )),
                  childCount: episode.guests!.length),
            ),
          ),
      ],
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (episode.name != null)
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: AutoSizeText(
                  episode.name!,
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
            "${'season'.tr(context)} ${episode.seasonNumber} : ${'episode'.tr(context)} ${episode.episodeNumber}",
            style: const TextStyle(fontSize: 17),
          ),
          if (episode.date != null) ...[
            const SizedBox(
              height: 10,
            ),
            Text(
              episode.date!,
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
              child: LibraryMediaControlLayout(
                media: episode,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

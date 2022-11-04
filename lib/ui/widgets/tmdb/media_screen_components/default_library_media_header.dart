import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/media.dart';

import '../../framed_text.dart';
import '../../rating_widget.dart';
import 'favorite_button.dart';
import 'library_media_status_widget.dart';

class MultimediaDefaultHeader extends StatelessWidget {
  final TMDBMultiMedia media;

  const MultimediaDefaultHeader({super.key, required this.media});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (media.name != null)
          Flexible(
            flex: 7,
            child: AutoSizeText(
              media.name!,
              wrapWords: false,
              maxLines: 3,
              textAlign: TextAlign.end,
              minFontSize: 18,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(
          height: 15,
        ),
        Flexible(
          flex: 2,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
                children: [
              if (media.popularityLevel != null)
                FramedText(
                  text: media.popularityLevel!.tr(context).toUpperCase(),
                ),
              if (media.genres.isNotEmpty)
                FramedText(
                  text: media.genres.first.tr(context),
                ),
              FramedText(
                text: media.type.name.tr(context),
              ),
              if (media.duration != null && media.duration!.inMinutes != 0)
                FramedText(
                  text: "${media.duration!.inMinutes} mins",
                ),
            ]
                    .map((e) => Padding(
                        padding: const EdgeInsets.only(left: 7), child: e))
                    .toList()),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Flexible(
          flex: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const FavoriteButton(),
              if (media.voteAverage != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: RatingWidget(
                    score: media.voteAverage!,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Flexible(
          flex: 5,
          child: LibraryMediaStatusWidget(
            media: media,
          ),
        ),
      ],
    );
  }
}

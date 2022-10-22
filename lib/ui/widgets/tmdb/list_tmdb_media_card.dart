import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/widgets/framed_text.dart';
import 'package:netflox/ui/widgets/tmdb/tmdb_image.dart';
import 'package:netflox/utils/reponsive_size_helper.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../data/models/tmdb/season.dart';

class TMDBListCard extends StatelessWidget {
  final void Function()? onTap;
  final double? height;
  const TMDBListCard(
      {super.key,
      this.onTap,
      this.height,
      this.image,
      this.action,
      required this.title,
      required this.subtitle,
      this.bottom,
      this.content});
  final Widget? image;
  final Widget title;
  final Widget subtitle;
  final Widget? bottom;
  final Widget? content;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Theme.of(context).canvasColor,
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: InkWell(
            onTap: () {
              if (onTap != null) {
                onTap!();
              }
            },
            child: Container(
                height: height ?? 15.h(context).clamp(100, 250),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (image != null) image!,
                      Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: title,
                              ),
                              const SizedBox(height: 5),
                              FittedBox(fit: BoxFit.scaleDown, child: subtitle),
                              const SizedBox(height: 5),
                              if (bottom != null) bottom!
                            ],
                          )),
                      const Spacer(),
                      if (ResponsiveWrapper.of(context).isLargerThan(MOBILE))
                        Flexible(
                            flex: 5,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: content,
                            )),
                      const SizedBox(
                        width: 20,
                      ),
                      action ??
                          Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).focusColor,
                          )
                    ]))));
  }
}

Widget episodeTitleBuilder(TMDBTVEpisode episode) => AutoSizeText.rich(
      TextSpan(children: [
        TextSpan(
          text: "S${episode.seasonNumber}:E${episode.episodeNumber}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: " - ${episode.name}"),
      ]),
      maxLines: 2,
      wrapWords: false,
      minFontSize: 10,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 17,
      ),
    );

class TMDBListMediaCard<T extends TMDBMedia> extends StatelessWidget {
  final T media;
  final double? height;
  final Widget? action;
  final void Function(T media)? onTap;
  final Widget? bottom;
  const TMDBListMediaCard(
      {super.key,
      required this.media,
      this.action,
      this.bottom,
      this.onTap,
      this.height});

  Widget _buildBottom(BuildContext context) {
    var widget;
    if (bottom != null) {
      widget = bottom!;
    } else if (media is TMDBPrimaryMedia &&
        (media as TMDBPrimaryMedia).popularityLevel != null) {
      widget = Text(
        (media as TMDBPrimaryMedia).popularityLevel!.tr(context),
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic),
      );
    }
    if (widget != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: widget,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return TMDBListCard(
      onTap: () {
        onTap?.call(media);
      },
      action: action,
      title: AutoSizeText(
        media.name ?? "",
        maxLines: 2,
        wrapWords: false,
        minFontSize: 12,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 17,
        ),
      ),
      subtitle: Row(
        children: [
          FramedText(
            text: media.type.name.tr(context),
            color: Theme.of(context).primaryColor,
            style: const TextStyle(
              fontSize: 9,
            ),
          ),
          if (media is TMDBMultiMedia &&
              (media as TMDBMultiMedia).genres.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: FramedText(
                text: (media as TMDBMultiMedia).genres.first.tr(context),
                style: const TextStyle(
                  fontSize: 9,
                ),
              ),
            ),
        ],
      ),
      bottom: Wrap(
        children: [
          _buildBottom(context),
          if (media.date != null)
            Text(
              media.date!,
              style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            )
        ],
      ),
      content: Text(
        media.overview!,
        softWrap: false,
        style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
      ),
      image: TMDBImageWidget(
        borderRadius: BorderRadius.circular(10),
        img: media.img,
        padding: const EdgeInsets.only(right: 10),
        showError: false,
      ),
      height: height,
    );
  }
}

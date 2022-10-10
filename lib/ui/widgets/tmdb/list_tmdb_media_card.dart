import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/widgets/framed_text.dart';
import 'package:netflox/ui/widgets/tmdb/tmdb_image.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ListTMDBMediaCard extends StatelessWidget {
  final TMDBPrimaryMedia media;
  final double height;
  final void Function(TMDBPrimaryMedia media)? onTap;
  const ListTMDBMediaCard(
      {super.key, required this.media, this.onTap, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: Border(
            bottom:
                BorderSide(width: 1, color: Theme.of(context).highlightColor)),
        child: InkWell(
            onTap: () {
              if (onTap != null) {
                onTap!(media);
              }
            },
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: TMDBImageWidget(
                        img: media.img,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: AutoSizeText(
                                media.name!,
                                maxLines: 2,
                                wrapWords: false,
                                minFontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                children: [
                                  FramedText(
                                    text: media.type.name.tr(context),
                                    color: Colors.white,
                                    style: const TextStyle(
                                      fontSize: 9,
                                    ),
                                  ),
                                  if (media is TMDBMultiMedia &&
                                      (media as TMDBMultiMedia)
                                          .genres
                                          .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: FramedText(
                                        text: (media as TMDBMultiMedia)
                                            .genres
                                            .first
                                            .tr(context),
                                        color: Colors.white,
                                        style: const TextStyle(
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 5,
                              children: [
                                if (media.popularityLevel != null)
                                  Text(
                                    media.popularityLevel!.tr(context),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic),
                                  ),
                                if (media.date != null)
                                  Text(
                                    media.date!,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic),
                                  )
                              ],
                            )
                          ],
                        )),
                    const Spacer(),
                    if (ResponsiveWrapper.of(context).isLargerThan(MOBILE) &&
                        media.overview != null)
                      Flexible(
                          flex: 4,
                          child: Center(
                            child: Text(
                              media.overview!,
                              softWrap: false,
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 12),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                            ),
                          )),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).focusColor,
                    )
                  ]),
            )));
  }
}

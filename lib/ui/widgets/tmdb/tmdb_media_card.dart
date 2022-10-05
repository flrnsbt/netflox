import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/widgets/tmdb/tmdb_image.dart';
import 'package:netflox/utils/reponsive_size_helper.dart';
import '../../../data/models/tmdb/type.dart';
import '../custom_banner.dart';

class TMDBMediaCard<T extends TMDBMedia> extends StatelessWidget {
  final T media;
  final bool showBottomTitle;
  final bool showMediaType;
  final bool showHover;
  final bool showImageError;
  final EdgeInsets insetPadding;
  final TMDBMediaCardContentBuilder? content;
  final CustomBannerOptions? bannerOptions;
  final TMDBMediaCardContentBuilder? hover;
  final void Function(T media)? onTap;

  static CustomBannerOptions?
      _isNewMultimediaBannerMessage<T extends TMDBMedia>(
          BuildContext context, T media) {
    if (media is TMDBMultiMedia && media.isRecent()) {
      return CustomBannerOptions.defaultNew;
    }
    return null;
  }

  TMDBMediaCard(
      {Key? key,
      required this.media,
      Widget Function(BuildContext context, T media)? hoverBuilder,
      this.bannerOptions,
      this.showImageError = true,
      this.showMediaType = false,
      this.showBottomTitle = false,
      this.showHover = true,
      this.insetPadding = const EdgeInsets.only(left: 15, right: 15, top: 15),
      Widget Function(BuildContext context, T media)? contentBuilder,
      BorderRadius? borderRadius,
      this.onTap})
      : borderRadius = borderRadius ?? BorderRadius.circular(25),
        content = contentBuilder != null
            ? TMDBMediaCardContentBuilder<T>(
                media: media,
                opacity: 0.5,
                contentBuilder: contentBuilder,
                insetPadding: insetPadding,
              )
            : null,
        hover = hoverBuilder != null
            ? TMDBMediaCardContentBuilder<T>(
                media: media,
                opacity: 0.7,
                contentBuilder: hoverBuilder,
                insetPadding: insetPadding,
              )
            : null,
        super(key: key);

  final BorderRadius borderRadius;
  final hovered = ValueNotifier(false);

  Widget _buildCard(BuildContext context) {
    return Material(
        borderRadius: borderRadius,
        color: Theme.of(context).cardColor,
        child: InkWell(
            borderRadius: borderRadius,
            onHover: (value) {
              hovered.value = value;
            },
            onTap: () {
              if (onTap != null) {
                onTap!(media);
              }
            },
            onTapDown: (_) {
              hovered.value = true;
            },
            onTapCancel: () {
              hovered.value = false;
            },
            onTapUp: (_) => hovered.value = false,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TMDBImageWidget(
                    img: media.img,
                    fadeAnimations: true,
                    showError: showImageError,
                  ),
                  if (content != null) content!,
                  if (showHover)
                    ValueListenableBuilder(
                        valueListenable: hovered,
                        builder: (BuildContext context, value, Widget? child) {
                          if (value) {
                            return hover ??
                                TMDBMediaCardContentBuilder.defaultHover(media);
                          }
                          return const SizedBox.shrink();
                        })
                ],
              ),
            )));
  }

  Widget _buildMediaTypeIcon() {
    IconData? icon;
    switch (media.type) {
      case TMDBType.movie:
        icon = Icons.movie_outlined;
        break;
      case TMDBType.tv:
        icon = CupertinoIcons.tv;
        break;
      case TMDBType.person:
        icon = Icons.person_outline;
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Icon(
        icon,
        size: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bannerOptions =
        this.bannerOptions ?? _isNewMultimediaBannerMessage(context, media);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
            child: bannerOptions != null
                ? CustomBanner.fromOptions(bannerOptions, _buildCard(context))
                : _buildCard(context)),
        if (showBottomTitle)
          Container(
            margin: const EdgeInsets.only(top: 5, left: 10, right: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (showMediaType) _buildMediaTypeIcon(),
              if (media.name != null)
                Flexible(
                    child: Text(
                  media.name!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold),
                ))
            ]),
          ),
      ],
    );
  }
}

class TMDBMediaCardContentBuilder<T extends TMDBMedia> extends StatelessWidget {
  final Widget Function(BuildContext context, T media) contentBuilder;
  final EdgeInsets insetPadding;
  final T media;
  final double opacity;
  const TMDBMediaCardContentBuilder(
      {super.key,
      required this.contentBuilder,
      required this.media,
      this.opacity = 0.7,
      this.insetPadding = const EdgeInsets.only(left: 15, right: 15, top: 15)})
      : assert(opacity >= 0 && opacity <= 1);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: insetPadding,
        color: Colors.black.withOpacity(opacity),
        child: contentBuilder(context, media));
  }

  static TMDBMediaCardContentBuilder<T> defaultHover<T extends TMDBMedia>(
          T media) =>
      TMDBMediaCardContentBuilder(
          contentBuilder: (context, media) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (media.name != null)
                  AutoSizeText(
                    media.name!,
                    maxLines: 2,
                    wrapWords: false,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 12,
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                const SizedBox(
                  height: 5,
                ),
                AutoSizeText(
                    [
                      media.type.name.tr(context),
                      if (media.year != null) media.year!.toString()
                    ].join(" - "),
                    maxLines: 1,
                    minFontSize: 10,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: "Verdana",
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    )),
                const SizedBox(
                  height: 5,
                ),
                if (media.overview != null)
                  Flexible(
                      flex: 5,
                      child: AutoSizeText(
                        media.overview ?? "",
                        minFontSize: 10,
                        maxFontSize: 16,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(color: Colors.white),
                      ))
              ],
            );
          },
          media: media);
}

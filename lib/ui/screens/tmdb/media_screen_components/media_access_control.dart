import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

import '../../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../../data/blocs/data_fetcher/library/library_media_cubit.dart';
import '../../../../data/models/tmdb/library_media_information.dart';
import '../../../../data/models/tmdb/media.dart';
import '../../../router/router.gr.dart';
import '../../../widgets/custom_awesome_dialog.dart';

class LibraryMediaControlLayout extends StatelessWidget {
  final TMDBLibraryMedia media;

  const LibraryMediaControlLayout({Key? key, required this.media})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: BlocProvider(
        create: (context) => LibraryMediaInfoFetchCubit(media),
        child: BlocBuilder<LibraryMediaInfoFetchCubit,
            BasicServerFetchState<LibraryMediaInformation>>(
          builder: (context, state) {
            if (state.finished()) {
              final mediaInfo = state.result;
              if (mediaInfo != null) {
                return _buildMediaLayout(mediaInfo, context);
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAvailableMediaLayout(
      BuildContext context, LibraryMediaInformation mediaInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (media is TMDBPlayableMedia)
              WatchButton(
                media: media as TMDBPlayableMedia,
              ),
            DownloadButton(media: media)
          ]
              .map((e) => Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: e,
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(
          height: 5,
        ),
        Flexible(child: _buildPlayableMediaLanguageInfo(context, mediaInfo))
      ],
    );
  }

  Widget _buildPlayableMediaLanguageInfo(
      BuildContext context, LibraryMediaInformation mediaInfo) {
    final languages = mediaInfo.languages?.map((e) => e.tr(context)).join(",");
    final subtitles = mediaInfo.subtitles?.map((e) => e.tr(context)).join(",");
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: [
        if (subtitles?.isNotEmpty ?? false)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(
              "${"subtitles".tr(context)}:",
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              subtitles!,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            )
          ]),
        if (languages?.isNotEmpty ?? false)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${"audio".tr(context)}:",
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                languages!,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              )
            ],
          )
      ],
    );
  }

  Widget _buildMediaLayout(
      LibraryMediaInformation mediaInfo, BuildContext context) {
    switch (mediaInfo.mediaStatus) {
      case MediaStatus.available:
        return _buildAvailableMediaLayout(context, mediaInfo);
      case MediaStatus.pending:
        if (media is TMDBPlayableMedia) {
          return ElevatedButton(
            onPressed: () {
              CustomAwesomeDialog(
                      title: "media-pending-state",
                      context: context,
                      btnOkOnPress: () {},
                      desc: "media-pending-state-desc")
                  .tr()
                  .show();
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(Theme.of(context).disabledColor)),
            child: Text(
              "${"pending".tr(context)}...",
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      case MediaStatus.rejected:
        return const Text("unavailable").tr();
      case MediaStatus.unavailable:
      default:
        return ElevatedButton(
            onPressed: () =>
                context.read<LibraryMediaInfoFetchCubit>().sendRequest(),
            child: const Text("request").tr());
    }
  }
}

class WatchButton extends StatelessWidget {
  final TMDBPlayableMedia media;
  const WatchButton({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: const MaterialStatePropertyAll(Colors.pink),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        )),
      ),
      onPressed: () =>
          context.pushRoute(StreamMediaRoute(playableMedia: media)),
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text(
            "watch",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
          ).tr()),
    );
  }
}

class DownloadButton extends StatelessWidget {
  final TMDBLibraryMedia media;

  const DownloadButton({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            fixedSize: const MaterialStatePropertyAll(Size(100, 30)),
            elevation: const MaterialStatePropertyAll(0),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface))),
            backgroundColor:
                const MaterialStatePropertyAll(Colors.transparent)),
        onPressed: () {},
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "download",
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ).tr(),
        ));
  }
}

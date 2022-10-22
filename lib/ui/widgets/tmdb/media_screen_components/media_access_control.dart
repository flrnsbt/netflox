import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/account/auth/user_account_data_cubit.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/language.dart';
import 'package:nil/nil.dart';

import '../../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../../data/blocs/data_fetcher/library/library_media_cubit.dart';
import '../../../../data/models/tmdb/library_media_information.dart';
import '../../../../data/models/tmdb/media.dart';
import '../../../router/router.gr.dart';
import '../../custom_awesome_dialog.dart';
import 'components.dart';

class LibraryMediaControlLayout extends StatelessWidget {
  final TMDBLibraryMedia media;

  const LibraryMediaControlLayout({Key? key, required this.media})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LibraryMediaInfoFetchCubit(media),
      child: BlocBuilder<LibraryMediaInfoFetchCubit,
          BasicServerFetchState<LibraryMediaInformation>>(
        builder: (context, state) {
          if (state.success()) {
            final mediaInfo = state.result;
            if (mediaInfo != null) {
              return _buildMediaLayout(mediaInfo, context);
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAvailableMediaLayout(
      BuildContext context, LibraryMediaInformation mediaInfo) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 2,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                if (media is TMDBPlayableMedia)
                  WatchButton(
                    media: media as TMDBPlayableMedia,
                  ),
                DownloadButton(media: media)
              ]
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: e,
                      ))
                  .toList(),
            ),
          ),
        ),
        Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: _buildPlayableMediaLanguageInfo(context, mediaInfo),
            ))
      ],
    );
  }

  Widget _buildPlayableMediaLanguageInfo(
      BuildContext context, LibraryMediaInformation mediaInfo) {
    final languages = mediaInfo.languages?.map((e) => e.tr(context)).join(", ");
    final subtitles = mediaInfo.subtitles?.map((e) => e.tr(context)).join(", ");
    return Wrap(
      spacing: 10,
      runSpacing: 3,
      alignment: WrapAlignment.end,
      children: [
        if (subtitles?.isNotEmpty ?? false)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(
              "${"subtitles".tr(context)}:",
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              subtitles!,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            )
          ]),
        if (languages?.isNotEmpty ?? false)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${"audio".tr(context)}:",
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                languages!,
                style: const TextStyle(fontSize: 10, color: Colors.white),
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
          return const Nil();
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
    return BlocBuilder<LibraryMediaUserPlaybackStateCubit,
        LibraryMediaUserPlaybackState>(
      builder: (context, state) {
        var text = 'watch';
        var mediaDuration = media.duration;
        if (mediaDuration == null || mediaDuration == const Duration()) {
          mediaDuration = const Duration(minutes: 60);
        }
        if (state.playbackTimestamp != null &&
            (state.playbackTimestamp! <
                (mediaDuration - const Duration(minutes: 6)))) {
          text = 'continue';
        }
        return TMDBHeaderButton(
            text: text,
            onPressed: () => context.pushRoute(StreamMediaRoute(
                  playableMedia: media,
                  startAt: state.playbackTimestamp,
                  onVideoClosed: (
                    playbackTimestamp,
                  ) {
                    if (playbackTimestamp != null) {
                      context
                          .read<LibraryMediaUserPlaybackStateCubit>()
                          .update(playbackTimestamp);
                    }
                  },
                )));
      },
    );
  }
}

class DownloadButton extends StatelessWidget {
  final TMDBLibraryMedia media;

  const DownloadButton({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return const TMDBHeaderButton(
      text: 'download',
      color: Colors.white,
      filled: false,
    );
  }
}

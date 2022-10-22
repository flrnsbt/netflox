import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/models/tmdb/media_upload_document.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/widgets/video_player/video_player.dart';
import '../../../data/blocs/http_video_server/http_server_cubit.dart';
import '../../../utils/subtitle_helper.dart';
import '../../screens/loading_screen.dart';

class SFTPVideoFilePlayer extends StatelessWidget {
  final void Function(Duration?)? onVideoClosed;
  final Duration? startingTime;
  final TMDBMediaLibraryRemoteDocument docs;
  final bool defaultFullScreen;
  final bool autoPlay;
  final bool quitOnFinish;

  const SFTPVideoFilePlayer(
      {super.key,
      this.onVideoClosed,
      this.startingTime,
      this.autoPlay = true,
      this.quitOnFinish = true,
      this.defaultFullScreen = true,
      required this.docs});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => HTTPServerVideoBinderCubit()..init(docs.videoFile),
        child: BlocBuilder<HTTPServerVideoBinderCubit, HttpVideoBinderState>(
          builder: (context, state) {
            if (state.isRunning()) {
              return FutureBuilder(
                  future: _getSubtitles(),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final subtitles = snapshot.data!;
                      return NetfloxVideoPlayer.network(
                        onVideoClosed: onVideoClosed,
                        startingTime: startingTime,
                        subtitles: subtitles,
                        quitOnFinish: quitOnFinish,
                        autoPlay: autoPlay,
                        defaultFullScreen: defaultFullScreen,
                        videoUrl: state.url!,
                      );
                    }
                    return const LoadingScreen();
                  }));
            } else if (state.failed()) {
              return ErrorScreen(
                errorCode: state.exception,
              );
            }
            return const LoadingScreen();
          },
        ));
  }

  Future<Map<Language, Subtitles>> _getSubtitles() async {
    final remoteSubtitles = docs.subtitleFiles;
    final subtitles = <Language, Subtitles>{};
    if (remoteSubtitles != null) {
      for (final sub in remoteSubtitles.entries) {
        final bytes = await sub.value.readBytes();
        for (final codec in codecs) {
          try {
            final content = codec.decode(bytes);
            final subtitle = getSubtitlesData(content, SubtitleType.srt);
            subtitles.putIfAbsent(sub.key, () => subtitle);
          } catch (e) {
            //
          }
        }
      }
    }
    return subtitles;
  }
}

const codecs = <Encoding>[utf8, latin1, ascii];

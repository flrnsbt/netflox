import 'package:better_player/better_player.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/app_localization_cubit.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/screens/loading_screen.dart';

import '../../data/blocs/http_video_server/http_server_cubit.dart';

class SftpVideoPlayer extends StatefulWidget {
  final SftpFile video;
  final String? title;
  final String? imgUrl;
  final Map<String, String>? subtitles;
  const SftpVideoPlayer(
      {Key? key, required this.video, this.subtitles, this.title, this.imgUrl})
      : super(key: key);

  @override
  State<SftpVideoPlayer> createState() => _SftpVideoPlayerState();
}

class _SftpVideoPlayerState extends State<SftpVideoPlayer> {
  late final Future<void> initialized;
  late BetterPlayerController _controller;
  List<BetterPlayerSubtitlesSource>? _subtitles;
  static const config = BetterPlayerConfiguration(
      allowedScreenSleep: false,
      controlsConfiguration: BetterPlayerControlsConfiguration(
          progressBarPlayedColor: Colors.pink,
          showControlsOnInitialize: false,
          playerTheme: BetterPlayerTheme.material,
          loadingColor: Colors.pink,
          enableQualities: false),
      showPlaceholderUntilPlay: true,
      autoPlay: true,
      autoDispose: true,
      looping: false,
      handleLifecycle: true,
      fit: BoxFit.contain,
      useRootNavigator: true,
      expandToFill: false,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ],
      subtitlesConfiguration: BetterPlayerSubtitlesConfiguration(
          outlineEnabled: true,
          rightPadding: 35,
          leftPadding: 35,
          bottomPadding: 45,
          fontColor: Color.fromARGB(255, 246, 255, 0),
          fontSize: 24),
      fullScreenByDefault: true);

  BetterPlayerDataSource _initDataSource(String url) {
    return BetterPlayerDataSource.network(url,
        useAsmsAudioTracks: false,
        useAsmsSubtitles: false,
        useAsmsTracks: false,
        subtitles: _subtitles,
        notificationConfiguration: BetterPlayerNotificationConfiguration(
          title: widget.title,
          imageUrl: widget.imgUrl,
          showNotification: true,
        ),
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
            minBufferMs: 24000,
            maxBufferMs: 3600000,
            bufferForPlaybackMs: 24000,
            bufferForPlaybackAfterRebufferMs: 24000),
        cacheConfiguration:
            const BetterPlayerCacheConfiguration(useCache: false));
  }

  @override
  void initState() {
    super.initState();
    _subtitles = _initSubtitles();
    _controller = BetterPlayerController(config);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.translations =
          NetfloxBetterPlayerTranslationConfiguration(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose(forceDispose: true);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.translations =
        NetfloxBetterPlayerTranslationConfiguration(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocProvider(
        create: (context) => HTTPServerVideoBinderCubit()..init(widget.video),
        child: BlocBuilder<HTTPServerVideoBinderCubit, HttpVideoBinderState>(
          builder: (context, state) {
            if (state.isRunning()) {
              final url = state.url!;
              final betterPlayerDataSource = _initDataSource(url);
              _controller.setupDataSource(betterPlayerDataSource);
              return SizedBox.expand(
                child: BetterPlayer(
                  controller: _controller,
                ),
              );
            }
            return const LoadingScreen();
          },
        ),
      ),
    );
  }

  List<BetterPlayerSubtitlesSource>? _initSubtitles() {
    final subtitles = widget.subtitles;
    if (subtitles != null) {
      final subs = <BetterPlayerSubtitlesSource>[];
      for (var sub in subtitles.entries) {
        final s = BetterPlayerSubtitlesSource(
            type: BetterPlayerSubtitlesSourceType.memory,
            content: sub.value,
            name: sub.key.tr(context));
        subs.add(s);
      }
      return subs;
    }
    return null;
  }
}

class NetfloxBetterPlayerTranslationConfiguration
    extends BetterPlayerTranslations {
  final BuildContext context;

  NetfloxBetterPlayerTranslationConfiguration(this.context)
      : super(
            languageCode: context
                .read<AppLocalization>()
                .state
                .currentLocale
                .languageCode,
            overflowMenuSubtitles: 'subtitles'.tr(context),
            generalDefaultError: 'video-error'.tr(context),
            generalNone: "none".tr(context),
            generalDefault: "default".tr(context),
            overflowMenuAudioTracks: 'audio'.tr(context),
            overflowMenuPlaybackSpeed: 'playback-speed'.tr(context),
            generalRetry: "retry".tr(context));
}

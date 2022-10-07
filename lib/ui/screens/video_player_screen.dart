import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/app_localization_cubit.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/utils/custom_modal_bottom_sheet.dart';
import 'package:netflox/utils/reponsive_size_helper.dart';

class NetfloxVideoPlayer extends StatefulWidget {
  final String url;
  final String? title;
  final String? imgUrl;
  final Map<String, String> subtitles;
  NetfloxVideoPlayer(
      {Key? key,
      required this.url,
      Map<String, String>? subtitles,
      this.title,
      this.imgUrl})
      : subtitles = subtitles ?? {},
        super(key: key);

  @override
  State<NetfloxVideoPlayer> createState() => _NetfloxVideoPlayerState();
}

class _NetfloxVideoPlayerState extends State<NetfloxVideoPlayer> {
  late final Future<void> initialized;
  BetterPlayerController? _controller;
  BetterPlayerDataSource? _dataSource;

  // _showfitMenuItem() {
  //   Navigator.maybePop(context);
  //   CustomModalBottomSheet(
  //       onSelected: (value) {
  //         _controller!.setOverriddenFit(value);
  //         Navigator.pop(context, true);
  //       },
  //       defaultValue: _controller!.getFit(),
  //       values: [BoxFit.contain, BoxFit.cover, BoxFit.fill]).show(context);
  // }

  BetterPlayerConfiguration _getConfig(BuildContext context) {
    return BetterPlayerConfiguration(
        translations: [NetfloxBetterPlayerTranslationConfiguration(context)],
        autoDetectFullscreenAspectRatio: true,
        allowedScreenSleep: false,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
            progressBarPlayedColor: Colors.pink,
            showControlsOnInitialize: false,
            // overflowMenuCustomItems: [
            //   BetterPlayerOverflowMenuItem(Icons.fit_screen, 'fit'.tr(context),
            //       () => _showfitMenuItem()),
            // ],
            // controlsHideTime: const Duration(milliseconds: 600),
            loadingColor: Colors.pink,
            enableQualities: false),
        showPlaceholderUntilPlay: true,
        autoPlay: true,
        autoDispose: true,
        looping: false,
        handleLifecycle: true,
        fit: BoxFit.contain,
        expandToFill: false,
        subtitlesConfiguration: BetterPlayerSubtitlesConfiguration(
            rightPadding: 20,
            leftPadding: 20,
            bottomPadding: 15,
            fontColor: Colors.yellow,
            fontSize: 6.h(context)),
        fullScreenByDefault: true);
  }

  Future<void> _initVideoContent() async {
    final subtitles = _initSubtitles();
    _dataSource = BetterPlayerDataSource.network(widget.url,
        useAsmsAudioTracks: false,
        useAsmsSubtitles: false,
        useAsmsTracks: false,
        subtitles: subtitles,
        notificationConfiguration: BetterPlayerNotificationConfiguration(
          title: widget.title,
          imageUrl: widget.imgUrl,
          showNotification: true,
        ),
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
            minBufferMs: 30000,
            bufferForPlaybackMs: 15000,
            bufferForPlaybackAfterRebufferMs: 30000),
        cacheConfiguration:
            const BetterPlayerCacheConfiguration(useCache: false));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final config = _getConfig(context);
      _controller =
          BetterPlayerController(config, betterPlayerDataSource: _dataSource);
    });
  }

  @override
  void initState() {
    super.initState();
    initialized = _initVideoContent();
  }

  @override
  void dispose() {
    _controller?.dispose(forceDispose: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const CloseButton(
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: Center(
          child: FutureBuilder(
            future: initialized,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return BetterPlayer(
                  controller: _controller!,
                );
              }
              return const LoadingScreen();
            },
          ),
        ));
  }

  List<BetterPlayerSubtitlesSource> _initSubtitles() {
    final subs = <BetterPlayerSubtitlesSource>[];
    for (var sub in widget.subtitles.entries) {
      final s = BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.memory,
          content: sub.value,
          name: sub.key.tr(context));
      subs.add(s);
    }
    return subs;
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

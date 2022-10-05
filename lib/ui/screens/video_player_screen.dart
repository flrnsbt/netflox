import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

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

  static const _config = BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      autoDetectFullscreenAspectRatio: false,
      fullScreenAspectRatio: 16 / 9,
      allowedScreenSleep: false,
      controlsConfiguration: BetterPlayerControlsConfiguration(
          progressBarPlayedColor: Colors.pink,
          showControlsOnInitialize: false,
          controlsHideTime: Duration(milliseconds: 600),
          loadingColor: Colors.pink,
          enableQualities: false),
      showPlaceholderUntilPlay: true,
      autoPlay: true,
      autoDispose: true,
      looping: false,
      handleLifecycle: true,
      fit: BoxFit.none,
      expandToFill: false, //
      subtitlesConfiguration: BetterPlayerSubtitlesConfiguration(
          fontColor: Colors.yellow, fontSize: 32),
      fullScreenByDefault: true);

  Future<void> _initVideoPlayer() async {
    final subtitles = _initSubtitles();
    _dataSource = BetterPlayerDataSource.network(widget.url,
        useAsmsAudioTracks: false,
        useAsmsSubtitles: false,
        useAsmsTracks: false,
        drmConfiguration: BetterPlayerDrmConfiguration(),
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
  }

  @override
  void initState() {
    super.initState();
    initialized = _initVideoPlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller =
        BetterPlayerController(_config, betterPlayerDataSource: _dataSource);
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
        child: BetterPlayer(
          controller: _controller!,
        ),
      ),
    );
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

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:netflox/utils/custom_modal_bottom_sheet.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NetfloxVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final Map<String, Subtitles> subtitles;
  const NetfloxVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.subtitles = const {},
  }) : super(key: key);

  @override
  State<NetfloxVideoPlayer> createState() => _NetfloxVideoPlayerState();
}

class _NetfloxVideoPlayerState extends State<NetfloxVideoPlayer>
    with WidgetsBindingObserver {
  ChewieController? _controller;
  VideoPlayerController? _videoPlayerController;
  late SubtitlePicker _subtitlePicker;
  OptionsTranslation? _translation;
  Key? _visibilityKey;
  bool _initialized = false;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoPlayerController = VideoPlayerController.network(
      widget.videoUrl,
    );
    _subtitlePicker = SubtitlePicker(
      subtitles: widget.subtitles,
      onSubtitleChanged: (currentSubtitle) {
        final subtitles = <Subtitle>[];
        if (currentSubtitle != null) {
          subtitles.addAll(currentSubtitle.subtitle.whereType<Subtitle>());
        }
        _controller?.setSubtitle(subtitles);
      },
    );
    _translation = OptionsTranslation(
        cancelButtonText: 'cancel'.tr(context),
        subtitlesButtonText: 'subtitles'.tr(context),
        playbackSpeedButtonText: 'playback-speed'.tr(context));
    _initChewieController();
  }

  Future<void> _initChewieController() async {
    _videoPlayerController!.addListener(_initializeListener);
    _controller = ChewieController(
        subtitleBuilder: (context, subtitle) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 35),
              child: Text(
                subtitle,
                style: const TextStyle(
                    color: Color.fromARGB(255, 255, 230, 0), fontSize: 42),
              ),
            ),
        videoPlayerController: _videoPlayerController!,
        allowedScreenSleep: false,
        zoomAndPan: false,
        allowFullScreen: true,
        customControls: const CupertinoControls(
          backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
          iconColor: Color.fromARGB(255, 200, 200, 200),
        ),
        autoInitialize: true,
        showControlsOnInitialize: false,
        allowPlaybackSpeedChanging: false,
        fullScreenByDefault: true,
        additionalOptions: (context) {
          return [
            OptionItem(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  _subtitlePicker.show(context);
                },
                iconData: Icons.subtitles,
                title: 'subtitles'.tr(context))
          ];
        },
        errorBuilder: (context, errorMessage) {
          return ErrorScreen(
            errorCode: errorMessage,
          );
        },
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ],
        optionsTranslation: _translation);
    _visibilityKey = Key(_controller.hashCode.toString());
  }

  void _initializeListener() async {
    if (_videoPlayerController!.value.isInitialized) {
      setState(() {
        _initialized = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      _controller!.play();
      _running = true;
      _videoPlayerController!.removeListener(_initializeListener);
    }
  }

  @override
  void dispose() {
    if (_controller?.isFullScreen ?? false) {
      Navigator.of(context, rootNavigator: true).maybePop();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: _controller?.systemOverlaysAfterFullScreen);

      SystemChrome.setPreferredOrientations(
          _controller?.deviceOrientationsAfterFullScreen ??
              [
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
                DeviceOrientation.landscapeRight,
                DeviceOrientation.landscapeLeft,
              ]);
    }

    _videoPlayerController?.dispose();
    _controller?.dispose();
    _videoPlayerController = null;
    _controller = null;
    WidgetsBinding.instance.removeObserver(this);
    if (_visibilityKey != null) {
      VisibilityDetectorController.instance.forget(_visibilityKey!);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _running) {
      _controller?.play();
    } else {
      _controller?.pause();
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_running) {
      if (_controller!.isFullScreen) {
        if (info.visibleFraction == 0) {
          _controller?.pause();
        } else {
          _controller?.play();
        }
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return VisibilityDetector(
        key: _visibilityKey!,
        onVisibilityChanged: _onVisibilityChanged,
        child: Center(
          child: ClipRect(
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: SizedBox.fromSize(
                    size: _videoPlayerController!.value.size,
                    child: Chewie(controller: _controller!)),
              ),
            ),
          ),
        ),
      );
    } else {
      return const LoadingScreen();
    }
  }
}

class SubtitlePicker {
  final Map<String, Subtitles> subtitles;
  String? _currentSubtitle;
  final void Function(Subtitles? currentSubtitle)? onSubtitleChanged;
  SubtitlePicker({
    this.subtitles = const {},
    this.onSubtitleChanged,
    String? initialSubtitle,
  })  : assert(initialSubtitle == null ||
            subtitles.keys.contains(initialSubtitle)),
        _currentSubtitle = initialSubtitle;

  show(BuildContext context) {
    CustomModalBottomSheet<String>(
      defaultValue: _currentSubtitle,
      values: subtitles.keys.map((e) => 'language-$e'),
      onSelected: (value) {
        Navigator.of(context, rootNavigator: true).pop();
        _currentSubtitle = value;
        final subtitle = subtitles[value];
        onSubtitleChanged?.call(subtitle);
      },
    ).show(context);
  }
}

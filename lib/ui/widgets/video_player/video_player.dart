import 'dart:async';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/ui/widgets/video_player/subtitle_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import '../custom_snackbar.dart';
import 'custom_video_player_control.dart';
import 'package:video_player_macos/video_player_macos.dart';

class NetfloxVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;
  final bool showControl;
  final Map<Language, Subtitles> subtitles;
  final Duration? startingTime;
  final bool defaultFullScreen;
  final bool autoPlay;
  final bool mute;
  final bool quitOnFinish;
  final void Function(Duration? playbackTimestamp)? onVideoClosed;
  const NetfloxVideoPlayer.network({
    Key? key,
    required String this.videoUrl,
    this.startingTime,
    this.autoPlay = true,
    this.quitOnFinish = true,
    this.showControl = true,
    this.mute = false,
    this.defaultFullScreen = true,
    this.onVideoClosed,
    this.subtitles = const {},
  })  : videoFile = null,
        super(key: key);

  const NetfloxVideoPlayer.file({
    Key? key,
    required File this.videoFile,
    this.startingTime,
    this.autoPlay = true,
    this.quitOnFinish = true,
    this.mute = false,
    this.showControl = true,
    this.defaultFullScreen = true,
    this.onVideoClosed,
    this.subtitles = const {},
  })  : videoUrl = null,
        super(key: key);

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.videoFile != null) {
      _videoPlayerController = VideoPlayerController.file(
        widget.videoFile!,
      );
    } else {
      _videoPlayerController = VideoPlayerController.network(
        widget.videoUrl!,
      );
    }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _videoPlayerController!.addListener(_initializeListener);
    });
    _initChewieController();
  }

  Future<void> _initChewieController() async {
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
        showControls: widget.showControl,
        autoPlay: widget.autoPlay,
        fullScreenByDefault: widget.defaultFullScreen,
        allowFullScreen: true,
        customControls: const CustomControls(),
        // routePageBuilder:
        //     (context, animation, secondaryAnimation, controllerProvider) {
        //   return ValueListenableBuilder(
        //       valueListenable: animation,
        //       builder: (context, value, child) {
        //         if (value == 1) {
        //           return child!;
        //         } else {
        //           return const SizedBox.shrink();
        //         }
        //       },
        //       child: Material(child: controllerProvider));
        // },
        autoInitialize: true,
        showControlsOnInitialize: true,
        allowPlaybackSpeedChanging: false,
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
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ],
        optionsTranslation: _translation);
    _visibilityKey = Key(_controller.hashCode.toString());
    if (widget.quitOnFinish) {
      _videoPlayerController!.addListener(_playbackListener);
    }
  }

  void _playbackListener() {
    if (_initialized && (_videoPlayerController?.value.isFinished() ?? false)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _popupContinuePlaybackPrompt() {
    showSnackBar(context,
        text:
            "${'continue-watching-prompt'.tr(context)} (${widget.startingTime!.inMinutes}mins)",
        leading: const Icon(Icons.info),
        action: SnackBarAction(
            textColor: Theme.of(context).colorScheme.onSurface,
            label: 'continue'.tr(context),
            onPressed: () {
              _controller!.seekTo(widget.startingTime!);
              ScaffoldMessenger.of(context).clearSnackBars();
            }));
  }

  void _initializeListener() async {
    if (!_initialized && _videoPlayerController!.value.isInitialized) {
      setState(() {
        _initialized = true;
      });
      if (widget.mute) {
        _videoPlayerController!.setVolume(0);
      }
    }
    if (_videoPlayerController!.value.isPlaying) {
      _startedPlaying();
      _videoPlayerController?.removeListener(_initializeListener);
    }
  }

  Future<void> _startedPlaying() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
    if (widget.startingTime != null) {
      _popupContinuePlaybackPrompt();
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
    widget.onVideoClosed?.call(
      _videoPlayerController?.value.position,
    );
    _videoPlayerController!.removeListener(_playbackListener);
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
    if (state == AppLifecycleState.resumed && _initialized) {
      _controller?.play();
    } else {
      _controller?.pause();
      if (state == AppLifecycleState.detached) {
        widget.onVideoClosed?.call(
          _videoPlayerController?.value.position,
        );
      }
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_controller!.isPlaying && info.visibleFraction == 0) {
      _controller?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return VisibilityDetector(
          key: _visibilityKey!,
          onVisibilityChanged: _onVisibilityChanged,
          child: Chewie(controller: _controller!));
    } else {
      return const LoadingScreen();
    }
  }
}

//  Center(
//           child: SizedBox.expand(
//             child: ClipRect(
//               child: FittedBox(
//                   fit: BoxFit.contain, child:

extension on VideoPlayerValue {
  bool isFinished() => position >= duration;
}

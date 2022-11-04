import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/blocs/theme/theme_cubit.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/widgets/custom_awesome_dialog.dart';
import 'package:netflox/ui/widgets/video_player/subtitle_picker.dart';
import 'package:netflox/utils/reponsive_size_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'custom_video_player_control.dart';

// ignore: unused_import
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
    this.autoPlay = false,
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
    this.autoPlay = false,
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
  bool _alreadyPlayed = false;
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

    _initChewieController();
  }

  Future<void> _initChewieController() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _videoPlayerController!.addListener(_initializeListener);
    });
    _controller = ChewieController(
        subtitleBuilder: (context, subtitle) =>
            SubtitleBuilder(subtitle: subtitle),
        videoPlayerController: _videoPlayerController!,
        allowedScreenSleep: false,
        zoomAndPan: false,
        useRootNavigator: false,
        showControls: widget.showControl,
        autoPlay: widget.autoPlay,
        fullScreenByDefault: widget.defaultFullScreen,
        allowFullScreen: widget.defaultFullScreen,
        customControls: const CustomControls(),
        errorBuilder: (context, errorMessage) {
          return ErrorScreen(
              errorCode: errorMessage,
              child: IconButton(
                  color: Colors.grey.withOpacity(0.3),
                  onPressed: () => _initChewieController(),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  )));
        },
        autoInitialize: true,
        showControlsOnInitialize: true,
        allowPlaybackSpeedChanging: false,
        additionalOptions: (context) {
          return [
            OptionItem(
                onTap: () {
                  Navigator.of(context).pop();
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
  }

  void _playbackListener() {
    if (_videoPlayerController?.value.isFinished() ?? false) {
      Navigator.of(
        context,
      ).pop();
    }
  }

  void _popupContinuePlaybackPrompt() {
    CustomAwesomeDialog(
            context: context,
            title: 'keep-watching'.tr(context),
            btnOkOnPress: () {
              _controller!.seekTo(widget.startingTime!);
            },
            btnOkText: 'continue'.tr(context),
            btnCancelText: 'no'.tr(context),
            btnCancelOnPress: () {},
            desc:
                "${'continue-watching-prompt'.tr(context)} (${widget.startingTime!.inMinutes}mins)",
            dialogType: DialogType.info)
        .show();
  }

  void _initializeListener() async {
    if (!_initialized && _videoPlayerController!.value.isInitialized) {
      if ((widget.startingTime?.inMinutes ?? 0) > 5) {
        _popupContinuePlaybackPrompt();
      }
      setState(() {
        _initialized = true;
      });
    }
    if (_videoPlayerController!.value.isPlaying) {
      if (widget.mute) {
        _controller!.setVolume(0);
      }
      _videoPlayerController?.removeListener(_initializeListener);
      await Future.delayed(const Duration(seconds: 1));
      _alreadyPlayed = true;
      if (widget.quitOnFinish) {
        _videoPlayerController!.addListener(_playbackListener);
      }
    }
  }

  @override
  void dispose() {
    if (_controller?.isFullScreen ?? false) {
      Navigator.of(context).maybePop();
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _alreadyPlayed) {
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeDataCubit.darkThemeData,
      child: _initialized
          ? Scaffold(
              body: ClipRect(child: Chewie(controller: _controller!)),
            )
          : const LoadingScreen(),
    );
  }
}

extension on VideoPlayerValue {
  bool isFinished() => position >= duration;
}

class SubtitleBuilder extends StatelessWidget {
  final dynamic subtitle;
  const SubtitleBuilder({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final fontSize = _getFontSize(context);
    return Container(
      color: Colors.black26,
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 35),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: AutoSizeText(
        subtitle,
        textAlign: TextAlign.center,
        wrapWords: false,
        maxLines: 4,
        minFontSize: 12,
        maxFontSize: 60,
        style: TextStyle(
            color: const Color.fromARGB(255, 255, 230, 0), fontSize: fontSize),
      ),
    );
  }

  double _getFontSize(BuildContext context) {
    var fontSize = 4.5.hw(context);
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      fontSize /= 2;
    }

    return fontSize;
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CustomYoutubePlayer extends StatefulWidget {
  final String videoId;
  final double maxHeight;
  const CustomYoutubePlayer(
      {super.key, required this.videoId, this.maxHeight = 250});

  @override
  State<CustomYoutubePlayer> createState() => _CustomYoutubePlayerState();
}

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer>
    with WidgetsBindingObserver {
  YoutubePlayerController? _controller;
  Key? _visibilityKey;
  bool _alreadyPlayed = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _visibilityKey = Key(widget.videoId);
    _controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
      showControls: false,
    ));
    _controller!.onInit = (() {
      _controller?.cueVideoById(videoId: widget.videoId);
    });
    _controller!.listen((event) {
      if (event.playerState == PlayerState.playing) {
        _alreadyPlayed = true;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _controller?.playVideo();
    } else {
      _controller?.pauseVideo();
    }
  }

  @override
  void dispose() {
    _controller?.close();
    if (_visibilityKey != null) {
      VisibilityDetectorController.instance.forget(_visibilityKey!);
    }
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: _visibilityKey!,
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 0) {
            _controller!.pauseVideo();
          } else {
            if (_alreadyPlayed) {
              _controller!.playVideo();
            }
          }
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: YoutubePlayer(
              aspectRatio: 16 / 9,
              backgroundColor: Colors.transparent,
              enableFullScreenOnVerticalDrag: false,
              gestureRecognizers: const <
                  Factory<OneSequenceGestureRecognizer>>{},
              controller: _controller),
        ));
  }
}

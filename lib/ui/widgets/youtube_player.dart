import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CustomYoutubePlayer extends StatefulWidget {
  final String videoId;
  const CustomYoutubePlayer({super.key, required this.videoId});

  @override
  State<CustomYoutubePlayer> createState() => _CustomYoutubePlayerState();
}

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
  YoutubePlayerController? _controller;
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
      showFullscreenButton: true,
    ));
    _controller?.onInit = (() {
      _controller?.cueVideoById(videoId: widget.videoId);
    });
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
            aspectRatio: 16 / 9,
            child: AbsorbPointer(
                absorbing: true,
                child: YoutubePlayer(
                    gestureRecognizers: const <
                        Factory<OneSequenceGestureRecognizer>>{},
                    controller: _controller))));
  }
}

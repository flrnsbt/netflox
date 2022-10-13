import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
    return AbsorbPointer(
        absorbing: false,
        child: YoutubePlayer(
            aspectRatio: 16 / 9,
            backgroundColor: Colors.transparent,
            enableFullScreenOnVerticalDrag: false,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            controller: _controller));
  }
}

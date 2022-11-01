import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_state.dart';
import 'package:netflox/data/models/tmdb/library_files.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/widgets/video_player/video_player.dart';
import '../../../data/blocs/http_video_server/http_server_cubit.dart';
import '../../../utils/subtitle_helper.dart';
import '../../screens/loading_screen.dart';

class SFTPVideoFilePlayer extends StatefulWidget {
  final void Function(Duration?)? onVideoClosed;
  final Duration? startingTime;
  final TMDBMediaLibraryFiles remoteFiles;
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
      required this.remoteFiles});

  @override
  State<SFTPVideoFilePlayer> createState() => _SFTPVideoFilePlayerState();
}

class _SFTPVideoFilePlayerState extends State<SFTPVideoFilePlayer> {
  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return BlocProvider(
          create: (context) => HTTPServerVideoBinderCubit()..init(_videoFile!),
          child: BlocBuilder<HTTPServerVideoBinderCubit, HttpVideoBinderState>(
            builder: (context, state) {
              if (state.isRunning()) {
                return NetfloxVideoPlayer.network(
                  onVideoClosed: widget.onVideoClosed,
                  startingTime: widget.startingTime,
                  subtitles: _subtitleFiles,
                  quitOnFinish: widget.quitOnFinish,
                  autoPlay: widget.autoPlay,
                  defaultFullScreen: widget.defaultFullScreen,
                  videoUrl: state.url!,
                );
              } else if (state.failed()) {
                return ErrorScreen(
                  errorCode: state.exception,
                );
              }
              return const LoadingScreen();
            },
          ));
    }
    return const LoadingScreen();
  }

  @override
  void dispose() {
    _videoFile?.close();
    super.dispose();
  }

  bool _ready = false;
  SftpFile? _videoFile;
  Map<Language, Subtitles> _subtitleFiles = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final sftpClient =
        (context.read<SSHConnectionCubit>().state as SSHConnectedState)
            .sftpClient;
    _videoFile =
        await sftpClient.open(widget.remoteFiles.videoFilePath!.filePath);
    _subtitleFiles = await _getSubtitles(sftpClient);
    setState(() {
      _ready = true;
    });
  }

  Future<Map<Language, Subtitles>> _getSubtitles(SftpClient sftpClient) async {
    final remoteSubtitles = widget.remoteFiles.subtitleFilesPath;
    final subtitles = <Language, Subtitles>{};
    for (final sub in remoteSubtitles.entries) {
      final remoteFile = await sftpClient.open(sub.value.filePath);
      final bytes = await remoteFile.readBytes();
      for (final codec in codecs) {
        try {
          final content = codec.decode(bytes);
          final subtitle = getSubtitlesData(content, SubtitleType.srt);
          subtitles.putIfAbsent(sub.key, () => subtitle);
        } catch (e) {
          //
        }
      }
      remoteFile.close();
    }
    return subtitles;
  }
}

const codecs = <Encoding>[utf8, latin1, ascii];

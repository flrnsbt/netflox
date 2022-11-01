import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/connectivity/connectivity_manager.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import 'package:netflox/data/blocs/theme/theme_cubit_cubit.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/widgets/video_player/stream_video_player.dart';
import 'package:netflox/ui/widgets/custom_awesome_dialog.dart';
import '../../data/blocs/sftp_server/sftp_file_transfer/sftp_media_file_access_cubit.dart';
import '../../data/blocs/sftp_server/ssh_connection/ssh_state.dart';

class StreamSFTPMediaScreen extends StatefulWidget {
  final TMDBPlayableMedia playableMedia;
  final Duration? startAt;
  final void Function(Duration? playbackTimestamp)? onVideoClosed;
  const StreamSFTPMediaScreen(
      {Key? key, required this.playableMedia, this.startAt, this.onVideoClosed})
      : super(key: key);

  @override
  State<StreamSFTPMediaScreen> createState() => _StreamSFTPMediaScreenState();
}

class _StreamSFTPMediaScreenState extends State<StreamSFTPMediaScreen>
    with ConnectivityStatefulWidgetListener {
  NetfloxCustomDialog? dialog;
  void initConnection(BuildContext context) {
    context.read<SSHConnectionCubit>().connect();
  }

  @override
  void connectivityChanged(ConnectivityState state) {
    if (state.hasNetworkAccess()) {
      initConnection(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initConnection(context);
    });
  }

  void _openRemoteFile(BuildContext context) =>
      context.read<SFTPMediaReadDirectoryCubit>().read(widget.playableMedia);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeDataCubit.darkThemeData,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: BlocBuilder<SSHConnectionCubit, SSHConnectionState>(
          builder: (context, state) {
            if (state.isConnected()) {
              _openRemoteFile(context);
              return BlocBuilder<SFTPMediaReadDirectoryCubit,
                  SFTPMediaFileAccessState>(
                builder: (context, remoteMediaState) {
                  if (remoteMediaState is SFTPMediaOpenedState) {
                    if (remoteMediaState.remoteFiles.playable()) {
                      return SFTPVideoFilePlayer(
                        remoteFiles: remoteMediaState.remoteFiles,
                        startingTime: widget.startAt,
                        onVideoClosed: widget.onVideoClosed,
                      );
                    } else {
                      return _buildErrorScreen(
                          error: 'server-error',
                          child:
                              _tryAgainButton(() => _openRemoteFile(context)));
                    }
                  } else if (remoteMediaState is SFTPMediaAccessFailedState) {
                    return _buildErrorScreen(
                        child: _tryAgainButton(() => _openRemoteFile(context)));
                  }
                  return const LoadingScreen(
                    loadingMessage: 'fetching-files',
                  );
                },
              );
            } else if (state.isConnecting()) {
              return const LoadingScreen(
                loadingMessage: 'connecting-server',
              );
            }
            return _buildErrorScreen(
                child: _tryAgainButton(() => initConnection(context)));
          },
        ),
      ),
    );
  }

  Widget _tryAgainButton(void Function() onPressed) {
    return ElevatedButton(
        onPressed: onPressed, child: const Text('try-again').tr());
  }

  Widget _buildErrorScreen({Object? error, Widget? child}) {
    return ErrorScreen(
      errorCode: error,
      child: child,
    );
  }
}

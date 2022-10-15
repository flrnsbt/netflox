import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/connectivity/connectivity_manager.dart';
import 'package:netflox/data/blocs/http_video_server/http_server_cubit.dart';
import 'package:netflox/data/blocs/sftp_server/media_remote_file_access/sftp_media_file_access_cubit.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/widgets/video_player.dart';
import 'package:netflox/ui/widgets/custom_awesome_dialog.dart';
import '../../data/blocs/sftp_server/ssh_connection/ssh_state.dart';

class StreamMediaScreen extends StatefulWidget {
  final TMDBPlayableMedia playableMedia;
  const StreamMediaScreen({Key? key, required this.playableMedia})
      : super(key: key);

  @override
  State<StreamMediaScreen> createState() => _StreamMediaScreenState();
}

class _StreamMediaScreenState extends State<StreamMediaScreen>
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

  void _openRemoteFile(BuildContext context) => context
      .read<SFTPMediaAccessCubit>()
      .open(widget.playableMedia.remoteFilePath!);

  void _initHttpServer(BuildContext context, SftpFile video) =>
      context.read<HTTPServerVideoBinderCubit>().init(video);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor: Colors.black,
        body: SizedBox.expand(
          child: BlocBuilder<SSHConnectionCubit, SSHConnectionState>(
            builder: (context, state) {
              if (state.isConnected()) {
                return BlocProvider(
                  create: (context) =>
                      SFTPMediaAccessCubit.fromSSHConnectedState(
                          state as SSHConnectedState)
                        ..open(widget.playableMedia.remoteFilePath!),
                  child: BlocBuilder<SFTPMediaAccessCubit,
                      SFTPMediaFileAccessState>(
                    builder: (context, libraryMedia) {
                      if (libraryMedia is SFTPMediaOpenedState) {
                        final video = libraryMedia.video;
                        return BlocProvider(
                            create: (context) =>
                                HTTPServerVideoBinderCubit()..init(video),
                            child: BlocBuilder<HTTPServerVideoBinderCubit,
                                HttpVideoBinderState>(
                              builder: (context, state) {
                                if (state.isRunning()) {
                                  return NetfloxVideoPlayer(
                                    subtitles: libraryMedia.subtitles,
                                    videoUrl: state.url!,
                                  );
                                } else if (state.failed()) {
                                  return _buildErrorScreen(
                                      child: _tryAgainButton(() =>
                                          _initHttpServer(context, video)));
                                }
                                return const LoadingScreen();
                              },
                            ));
                      } else if (libraryMedia is SFTPMediaAccessFailedState) {
                        return _buildErrorScreen(
                            child: _tryAgainButton(
                                () => _openRemoteFile(context)));
                      }
                      return const LoadingScreen(
                        loadingMessage: 'fetching-files',
                      );
                    },
                  ),
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
        ));
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

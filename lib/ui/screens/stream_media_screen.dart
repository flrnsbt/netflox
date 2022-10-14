import 'package:auto_route/auto_route.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/http_video_server/http_server_cubit.dart';
import 'package:netflox/data/blocs/sftp_server/media_remote_file_access/sftp_media_file_access_cubit.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/media.dart';
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

class _StreamMediaScreenState extends State<StreamMediaScreen> {
  NetfloxCustomDialog? dialog;
  void init(BuildContext context) {
    context.read<SSHConnectionCubit>().connect();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          BlocConsumer<SSHConnectionCubit, SSHConnectionState>(
            // buildWhen: (previous, current) =>
            //     previous == SSHConnectionState.disconnected(),
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
                          return BlocProvider(
                              create: (context) => HTTPServerVideoBinderCubit()
                                ..init(libraryMedia.video),
                              child: BlocBuilder<HTTPServerVideoBinderCubit,
                                  HttpVideoBinderState>(
                                builder: (context, state) {
                                  if (state.isRunning()) {
                                    return NetfloxVideoPlayer(
                                      subtitles: libraryMedia.subtitles,
                                      videoUrl: state.url!,
                                    );
                                  } else {
                                    return const LoadingScreen();
                                  }
                                },
                              ));
                        }
                        return const LoadingScreen();
                      },
                    ));
              }
              return LoadingScreen(
                loadingMessage: 'connecting-server'.tr(context),
              );
            },
            listener: (context, state) {
              dialog?.dismiss();
              dialog = null;
              if (state.failed()) {
                dialog = _errorDialog(context, state.exception!);
              } else if (state.isDisconnected()) {
                dialog = CustomAwesomeDialog(
                        context: context,
                        title: 'server-connection-failed',
                        desc: 'server-connection-failed-desc',
                        btnCancelOnPress: () {
                          context.router.pop();
                        },
                        btnOkText: 'try-again',
                        btnOkOnPress: () {
                          init(context);
                        },
                        dialogType: DialogType.error)
                    .tr();
              }
              dialog?.show();
            },
          ),
          const Positioned(
            left: 25,
            top: 25,
            child: CloseButton(),
          )
        ],
      ),
    );
  }

  CustomAwesomeDialog _errorDialog(
    BuildContext context,
    Object exception,
  ) {
    final netfloxException = NetfloxException.from(exception);
    return ErrorDialog.fromException(
      netfloxException,
      context,
      onPressed: () {
        Navigator.pop(context);
      },
    ).tr();
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/http_server/http_server_cubit.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/img.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/screens/video_player_screen.dart';
import 'package:netflox/ui/widgets/custom_awesome_dialog.dart';
import '../../data/blocs/app_config.dart';
import '../../data/blocs/sftp_server/media_files_access/media_access_cubit.dart';
import '../../data/blocs/sftp_server/ssh_connection/ssh_state.dart';

class StreamMediaScreen extends StatelessWidget {
  final TMDBPlayableMedia playableMedia;
  const StreamMediaScreen({Key? key, required this.playableMedia})
      : super(key: key);

  void init(BuildContext context) {
    context.read<SFTPConnectionCubit>().connect();
  }

  String? _getUrl(BuildContext context) {
    final baseUrl =
        context.read<AppConfigCubit>().state.tmdbApiConfig!.imgDatabaseUrl;
    final imgUrl = playableMedia.img?.getImgUrl();
    if (imgUrl != null) {
      return "$baseUrl$imgUrl";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    init(context);
    NetfloxCustomDialog? dialog;
    final imgUrl = _getUrl(context);

    return BlocConsumer<SFTPConnectionCubit, SSHConnectionState>(
      builder: (context, state) {
        if (state.isConnected()) {
          return BlocProvider(
            create: (context) => LibraryMediaAccessCubit.fromSSHConnectedState(
                state as SSHConnectedState)
              ..open(playableMedia.remoteFilePath!),
            child: BlocConsumer<LibraryMediaAccessCubit, SFTPMediaAccessState>(
              builder: (context, state) {
                if (state is SFTPMediaOpenedState) {
                  final subtitles = state.subtitles;
                  return BlocProvider(
                    create: (context) =>
                        LocalServerVideoBinderCubit()..bind(state.video),
                    child: BlocConsumer<LocalServerVideoBinderCubit,
                        HttpVideoBinderState>(builder: (context, state) {
                      if (state.isRunning()) {
                        final url = state.url!;
                        return NetfloxVideoPlayer(
                          url: url,
                          imgUrl: imgUrl,
                          title: playableMedia.name,
                          subtitles: subtitles,
                        );
                      }
                      return const LoadingScreen();
                    }, listener: (context, state) {
                      if (state.failed()) {
                        final exception =
                            NetfloxException.from(state.exception!);
                        ErrorDialog.fromException(
                          exception,
                          context,
                        ).tr();
                      }
                    }),
                  );
                }
                return const LoadingScreen();
              },
              listener: (context, state) {
                dialog?.dismiss();
                dialog = null;

                if (state is SFTPMediaAccessFailedState) {
                  final exception = NetfloxException.from(state.exception);
                  dialog = ErrorDialog.fromException(
                    exception,
                    context,
                  ).tr();
                }
                dialog?.show();
              },
            ),
          );
        }
        return const LoadingScreen();
      },
      listener: (context, state) {
        print(state);
        dialog?.dismiss();
        dialog = null;

        if (state.failed()) {
          final exception = NetfloxException.from(state.exception!);
          dialog = ErrorDialog.fromException(
            exception,
            context,
          ).tr();
        }
        if (state.isDisconnected()) {
          dialog = CustomAwesomeDialog(
                  context: context,
                  title: 'internet-issue',
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
    );
  }
}

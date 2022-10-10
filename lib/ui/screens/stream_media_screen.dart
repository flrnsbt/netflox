import 'package:auto_route/auto_route.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/http_server/http_server_cubit.dart';
import 'package:netflox/data/blocs/sftp_server/media_remote_file_access/sftp_media_file_access_cubit.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/screens/video_player_screen.dart';
import 'package:netflox/ui/widgets/custom_awesome_dialog.dart';
import '../../data/blocs/app_config.dart';
import '../../data/blocs/sftp_server/ssh_connection/ssh_state.dart';

class StreamMediaScreen extends StatelessWidget {
  final TMDBPlayableMedia playableMedia;
  const StreamMediaScreen({Key? key, required this.playableMedia})
      : super(key: key);

  void init(BuildContext context) {
    context.read<SSHConnectionCubit>().connect();
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
    return BlocConsumer<SSHConnectionCubit, SSHConnectionState>(
      builder: (context, state) {
        if (state.isConnected()) {
          return BlocProvider(
            create: (context) => SFTPMediaAccessCubit.fromSSHConnectedState(
                state as SSHConnectedState)
              ..open(playableMedia.remoteFilePath!),
            child: BlocBuilder<SFTPMediaAccessCubit, SFTPMediaFileAccessState>(
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
                      return LoadingScreen(
                        loadingMessage: 'buffering-video'.tr(context),
                      );
                    }, listener: (context, state) {
                      if (state.failed()) {
                        dialog = _errorDialog(context, state.exception!);
                      }
                    }),
                  );
                }
                return LoadingScreen(
                  loadingMessage: 'retrieving-files'.tr(context),
                );
              },
            ),
          );
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
        }
        if (state.isDisconnected()) {
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

import 'package:auto_route/auto_route.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/sftp_server/media_remote_file_access/sftp_media_file_access_cubit.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/widgets/sftp_video_player.dart';
import 'package:netflox/ui/widgets/custom_awesome_dialog.dart';
import '../../data/blocs/app_config.dart';
import '../../data/blocs/sftp_server/ssh_connection/ssh_state.dart';

class StreamMediaScreen extends StatefulWidget {
  final TMDBPlayableMedia playableMedia;
  const StreamMediaScreen({Key? key, required this.playableMedia})
      : super(key: key);

  @override
  State<StreamMediaScreen> createState() => _StreamMediaScreenState();
}

class _StreamMediaScreenState extends State<StreamMediaScreen> {
  String? _imgUrl;
  NetfloxCustomDialog? dialog;
  void init(BuildContext context) {
    context.read<SSHConnectionCubit>().connect();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init(context);
      _imgUrl = _getUrl(context);
    });
  }

  String? _getUrl(BuildContext context) {
    final baseUrl =
        context.read<AppConfigCubit>().state.tmdbApiConfig!.imgDatabaseUrl;
    final imgUrl = widget.playableMedia.img?.getImgUrl();
    if (imgUrl != null) {
      return "$baseUrl$imgUrl";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: BlocConsumer<SSHConnectionCubit, SSHConnectionState>(
        // buildWhen: (previous, current) =>
        //     previous == SSHConnectionState.disconnected(),
        builder: (context, state) {
          if (state.isConnected()) {
            return BlocProvider(
                create: (context) => SFTPMediaAccessCubit.fromSSHConnectedState(
                    state as SSHConnectedState)
                  ..open(widget.playableMedia.remoteFilePath!),
                child:
                    BlocBuilder<SFTPMediaAccessCubit, SFTPMediaFileAccessState>(
                  builder: (context, libraryMedia) {
                    if (libraryMedia is SFTPMediaOpenedState) {
                      return SftpVideoPlayer(
                        imgUrl: _imgUrl,
                        title: widget.playableMedia.name,
                        subtitles: libraryMedia.subtitles,
                        video: libraryMedia.video,
                      );
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

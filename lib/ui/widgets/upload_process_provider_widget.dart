// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/widgets/download_progress_indicator.dart';
import 'package:provider/provider.dart';
import '../../data/blocs/data_fetcher/library/library_media_cubit.dart';

import '../../data/blocs/sftp_server/sftp_file_transfer/sftp_media_file_access_cubit.dart';
import '../../data/blocs/sftp_server/sftp_file_transfer/sftp_upload_media_files_cubit.dart';
import '../../data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import '../../data/blocs/sftp_server/ssh_connection/ssh_state.dart';
import '../../data/models/tmdb/media.dart';
import '../../data/models/tmdb/library_files.dart';
import '../../services/notification_service.dart';
import 'custom_awesome_dialog.dart';

class UploadProcessManager extends StatelessWidget {
  final Widget child;
  const UploadProcessManager({super.key, required this.child});

  void showProgressDialog(BuildContext context) {
    if (context.read<SFTPMediaFilesUploadCubit>().state.isUploading()) {
      _uploadingDialog(
              context,
              context.read<SFTPMediaFilesUploadCubit>().state
                  as SFTPMediaFileUploadingState)
          .show();
    }
  }

  static CustomAwesomeDialog _uploadingDialog(
          BuildContext context, SFTPMediaFileUploadingState state) =>
      CustomAwesomeDialog(
        context: context,
        dialogType: DialogType.noHeader,
        body: Column(
          children: [
            Text(
              "${'uploading'.tr(context)}: ${state.media?.name ?? ""}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ).tr(),
            const SizedBox(
              height: 10,
            ),
            Text(
              state.fileName,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(
              height: 25,
            ),
            DownloadProgressIndicator(
                bytesTransmitted: state.bytesTransmitted,
                fileSize: state.fileSize),
          ],
        ),
        btnCancelText: 'abort'.tr(context),
        btnCancelOnPress: () =>
            context.read<SFTPMediaFilesUploadCubit>().abort(),
        btnOkText: 'hide'.tr(context),
        btnOkOnPress: () {},
      );

  Future<void> _updateMediaStatus(TMDBLibraryMedia media,
      TMDBMediaLibraryLanguageConfiguration stats) async {
    final mediaStatusManager = LibraryMediaInfoFetchCubit(media);
    try {
      await mediaStatusManager.available(stats);
    } catch (e) {
      //
    }
    mediaStatusManager.close();
  }

  Future<void> _getDirectoryFiles(
      BuildContext context, TMDBLibraryMedia media) {
    return context.read<SFTPMediaReadDirectoryCubit>().read(media);
  }

  @override
  Widget build(BuildContext context) {
    NetfloxCustomDialog? dialog;
    return Provider(
      create: (context) => this,
      child: BlocConsumer<SSHConnectionCubit, SSHConnectionState>(
          listener: (context, state) {
        dialog?.dismiss();
        NotificationService.cancelAll();
      }, builder: (context, connectionState) {
        if (connectionState is SSHConnectedState) {
          return MultiBlocProvider(
              providers: [
                BlocProvider(
                    lazy: false,
                    create: (context) =>
                        SFTPMediaReadDirectoryCubit.fromSSHConnectedState(
                            connectionState, true)),
                BlocProvider(
                    create: (context) =>
                        SFTPMediaFilesUploadCubit.fromSSHConnectedState(
                            connectionState))
              ],
              child: MultiBlocListener(
                listeners: [
                  BlocListener<SFTPMediaFilesUploadCubit,
                      SFTPMediaFileUploadState>(
                    listener: (context, uploadState) async {
                      dialog?.dismiss();
                      dialog = null;
                      NotificationService.cancelAll();
                      if (uploadState.isLoading()) {
                        dialog = LoadingDialog(context);
                      } else if (uploadState is SFTPMediaFileUploadingState) {
                        NotificationService.showProgressNotification(
                          context,
                          uploadState: uploadState,
                        );
                        dialog = _uploadingDialog(context, uploadState);
                      } else if (uploadState
                          is SFTPMediaFileUploadFinishedState) {
                        await _getDirectoryFiles(context, uploadState.media!);
                        await _updateMediaStatus(
                            uploadState.media!, uploadState.mediaLibraryFiles);
                        NotificationService.showFinishedNotification(context);
                      }
                      if (uploadState.failed() &&
                          uploadState.exception != "aborted") {
                        dialog = CustomAwesomeDialog(
                                btnOkOnPress: () {},
                                context: context,
                                title: "error".tr(context),
                                desc: uploadState.exception.toString())
                            .tr();
                      }
                      dialog?.show();
                    },
                  ),
                  BlocListener<SFTPMediaReadDirectoryCubit,
                      SFTPMediaFileAccessState>(
                    listener: (context, accessState) async {
                      dialog?.dismiss();
                      dialog = null;

                      if (accessState.isLoading()) {
                        dialog = LoadingDialog(context);
                      }
                      dialog?.show();
                    },
                  ),
                ],
                child: child,
              ));
        } else {
          return child;
        }
      }),
    );
  }

  Future<void> _deleteUnwantedFiles(BuildContext context) async {
    // await connectionState.sftpClient.removeAll(fileNames);
  }
}

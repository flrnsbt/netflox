import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import '../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../data/blocs/data_fetcher/library/library_media_cubit.dart';
import '../../data/blocs/sftp_server/sftp_file_access/sftp_media_file_access_cubit.dart';
import '../../data/blocs/sftp_server/sftp_file_access/sftp_upload_media_files_cubit.dart';
import '../../data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import '../../data/blocs/sftp_server/ssh_connection/ssh_state.dart';
import '../../data/models/tmdb/library_media_information.dart';
import '../../data/models/tmdb/media.dart';
import '../../data/models/tmdb/media_upload_document.dart';
import 'custom_awesome_dialog.dart';
import 'custom_snackbar.dart';
import 'download_progress_indicator.dart';

class UploadProcessManagerWidget extends StatelessWidget {
  final Widget child;
  const UploadProcessManagerWidget({super.key, required this.child});

  void _showUploadingProgress(
      BuildContext context, SFTPMediaFileUploadingState state) {
    ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        backgroundColor: Theme.of(context).canvasColor,
        content: Row(
          children: [
            Flexible(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'uploading-file'.tr(context),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Flexible(
                    child: Text(
                      state.fileName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 25,
            ),
            Flexible(
              flex: 3,
              child: DownloadProgressIndicator(
                  bytesTransmitted: state.bytesTransmitted,
                  fileSize: state.fileSize),
            )
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                _abort(context);
              },
              icon: const Icon(Icons.stop))
        ]));
  }

  void _abort(BuildContext context) {
    context.read<SFTPMediaFilesUploadCubit>().abort();
  }

  // if (state.success()) {
  //                     ScaffoldMessenger.maybeOf(context)
  //                         ?.clearMaterialBanners();
  //                     showSnackBar(context,
  //                         text: 'upload-completed-successfully'.tr(context));
  //                   }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SSHConnectionCubit, SSHConnectionState>(
        child: child,
        listener: (context, state) {
          if (state.isConnected()) {
            BlocListener<SFTPMediaFilesUploadCubit, SFTPMediaFileUploadState>(
              bloc: SFTPMediaFilesUploadCubit.fromSSHConnectedState(
                  state as SSHConnectedState),
              listener: (context, state) async {
                ScaffoldMessenger.of(context).clearMaterialBanners();
                if (state.isUploading()) {
                  _showUploadingProgress(
                      context, state as SFTPMediaFileUploadingState);
                } else if (state.isFinished()) {
                  // context
                  //     .read<LibraryMediaInfoFetchCubit>()
                  //     .available(_videoLanguage!, _subtitleFiles?.keys);
                }
                if (state.failed()) {
                  CustomAwesomeDialog(
                          context: context, title: 'error', desc: 'error-desc')
                      .tr()
                      .show();
                }
              },
            );
          }
        });
  }
}

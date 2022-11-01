import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/router/router.gr.dart';
import '../data/blocs/sftp_server/sftp_file_transfer/sftp_media_file_access_cubit.dart';
import '../data/blocs/sftp_server/sftp_file_transfer/sftp_upload_media_files_cubit.dart';

const _kNotificationId = "upload_progress_notification";
const _kAbortButtonKey = 'abort_progress_button';

class NotificationService {
  static _checkPermission() async {
    final result = await AwesomeNotifications().isNotificationAllowed();
    if (!result) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static Future<void> init() async {
    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            playSound: true,
            onlyAlertOnce: true,
            channelShowBadge: false,
            importance: NotificationImportance.High,
            channelKey: _kNotificationId,
            channelName: _kNotificationId,
            channelDescription:
                'Upload Notification Progress Notification Channel',
          )
        ],
        debug: false);
    await _checkPermission();
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.channelKey == _kNotificationId) {
      if (receivedAction.buttonKeyPressed == _kAbortButtonKey) {
        _currentNotification?.onAbortButtonPressed();
      }
      if (receivedAction.actionType == ActionType.KeepOnTop) {
        _currentNotification?.onNotificationPressed();
      }
    }
  }

  static Future<void> cancelAll() => AwesomeNotifications().cancelAll();

  static Future<void> showFinishedNotification(
    BuildContext context,
  ) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 0,
          channelKey: _kNotificationId,
          title: 'upload-finished'.tr(context)),
    );
  }

  static UploadNotification? _currentNotification;

  static Future<void> showProgressNotification(
    BuildContext context, {
    required SFTPMediaFileUploadingState uploadState,
  }) async {
    _currentNotification =
        UploadNotification(context, uploadState: uploadState);
    await _currentNotification!.show();
    _currentNotification = null;
  }
}

abstract class Notification {
  const Notification();
}

class UploadNotification extends Notification {
  const UploadNotification(
    this.context, {
    required this.uploadState,
  });

  Future<void> onAbortButtonPressed() {
    return context.read<SFTPMediaFilesUploadCubit>().abort();
  }

  void onNotificationPressed() {
    context.pushRoute(UploadRoute(media: uploadState.media!));
  }

  final BuildContext context;
  final SFTPMediaFileUploadingState uploadState;

  Future<void> show() async {
    final body = uploadState.fileName;
    var title = 'uploading'.tr(context);
    if (uploadState.media?.name != null) {
      title += ": ${uploadState.media!.name}";
    }

    final payload = uploadState.media!
        .libraryIdMap()
        .map((key, value) => MapEntry(key, value.toString()));

    Future<void> show(String body, [int progress = 0]) =>
        AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: uploadState.hashCode,
                channelKey: _kNotificationId,
                progress: progress,
                locked: true,
                category: NotificationCategory.Progress,
                title: title,
                payload: payload,
                body: body,
                notificationLayout: NotificationLayout.ProgressBar,
                actionType: ActionType.KeepOnTop),
            actionButtons: [
              NotificationActionButton(
                key: _kAbortButtonKey,
                label: 'abort'.tr(context),
                showInCompactView: true,
              )
            ]);

    if (Platform.isAndroid) {
      int timeElapsed = 0;
      var totalBytes = 0;
      await uploadState.bytesTransmitted.listen((bytes) async {
        final currentTime = Timestamp.now().seconds;
        final delta = currentTime - timeElapsed;
        if (delta >= 1) {
          timeElapsed = currentTime;
          final bandwidth = (bytes - totalBytes) / 1000000 / delta;
          totalBytes = bytes;
          final progress = (bytes / uploadState.fileSize * 100).toInt();
          final body =
              "${bandwidth.toStringAsFixed(1)} MB/s | ${"file".tr(context)}: ${uploadState.fileName}";
          show(body, progress);
        }
      }).asFuture();
    } else {
      await show(body);
    }
  }
}

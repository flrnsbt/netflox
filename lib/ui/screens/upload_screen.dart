// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_picker/language_picker_dialog.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/blocs/app_localization/app_localization_cubit.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_state.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/widgets/constrained_large_screen_widget.dart';
import 'package:netflox/ui/widgets/custom_awesome_dialog.dart';
import 'package:netflox/ui/widgets/tmdb/list_tmdb_media_card.dart';
import 'package:netflox/ui/widgets/upload_process_provider_widget.dart';
import 'package:netflox/ui/widgets/video_player/video_player.dart';
import '../../data/blocs/sftp_server/sftp_file_transfer/sftp_media_file_access_cubit.dart';
import '../../data/blocs/sftp_server/sftp_file_transfer/sftp_upload_media_files_cubit.dart';
import '../../data/blocs/theme/theme_cubit_cubit.dart';
import '../../data/models/language.dart';
import '../../data/models/tmdb/library_files.dart';
import '../widgets/country_flag_icon.dart';

class UploadScreen extends StatefulWidget {
  final TMDBLibraryMedia media;
  const UploadScreen({Key? key, required this.media}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  NetfloxFilePath? _videoFilePath;
  Language? _videoLanguage;
  Iterable<NetfloxFilePath> _otherRemoteVideoFiles = [];
  final Map<Language?, NetfloxFilePath?> _subtitleFiles = {};

  bool get _isIdle => context.read<SFTPMediaFilesUploadCubit>().state.isIdle();

  void _upload(BuildContext context, SFTPMediaFileUploadState state) async {
    if (state.isUploading() && widget.media == state.media) {
      context.read<UploadProcessManager>().showProgressDialog(context);
    } else {
      _subtitleFiles.removeWhere((key, value) => key == null || value == null);
      if (_videoFilePath != null || _subtitleFiles.isNotEmpty) {
        final remoteFiles = TMDBMediaLibraryFiles(
          subtitleFilesPath: _subtitleFiles.cast(),
          videoFilePath: _videoFilePath,
          videoLanguage: _videoLanguage,
        );
        bool force = false;
        if (state.isUploading()) {
          await CustomAwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  title: 'upload-in-progress',
                  btnOkOnPress: () {},
                  btnCancelOnPress: () {},
                  onDismissCallback: (type) {
                    if (type == DismissType.btnOk) {
                      force = true;
                    }
                  },
                  desc: 'upload-in-progress-desc')
              .tr()
              .show();
        }
        context
            .read<SFTPMediaFilesUploadCubit>()
            .upload(widget.media, remoteFiles, force: force);
      } else {
        var errorMessg = 'language';
        if (_videoFilePath == null) {
          errorMessg = 'video-file';
        }
        CustomAwesomeDialog(
                context: context,
                dialogType: DialogType.info,
                title: 'missing-$errorMessg',
                btnOkOnPress: () {},
                desc: 'no-$errorMessg-provided-desc')
            .tr()
            .show();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await _initConnection();
    await Future.delayed(const Duration(seconds: 1));
    context.read<SFTPMediaReadDirectoryCubit>().read(widget.media);
  }

  FutureOr<void> _initConnection() =>
      context.read<SSHConnectionCubit>().connect();

  Future<bool> _onWillPop() async {
    if (_isIdle && (_videoFilePath?.isLocalFile() ?? false)) {
      bool result = false;
      await CustomAwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              title: 'unsaved-changes',
              btnOkOnPress: () {
                result = true;
              },
              btnCancelOnPress: () {},
              desc: 'unsaved-changes-desc')
          .tr()
          .show();
      return result;
    }
    return true;
  }

  Widget _buildUncompletedVideoRemoteFiles() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              const Icon(Icons.movie),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: const Text(
                  'uncompleted-video-files',
                  maxLines: 1,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ).tr(),
              ),
            ],
          ),
          const SizedBox(
            height: 2,
          ),
          for (final videoRemoteFile in _otherRemoteVideoFiles)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: AutoSizeText(
                "- ${videoRemoteFile.fileUri.fileName}",
                maxLines: 2,
                minFontSize: 8,
                style: const TextStyle(fontSize: 13),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ConstrainedLargeScreenWidget(
        child: WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            BlocBuilder<SFTPMediaFilesUploadCubit, SFTPMediaFileUploadState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: () => _upload(context, state),
                  child: Text(state.isUploading() && widget.media == state.media
                          ? 'uploading'
                          : 'upload')
                      .tr(),
                );
              },
            ),
            const SizedBox(
              width: 15,
            )
          ],
          backgroundColor: Colors.transparent,
          centerTitle: false,
          title: Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: "upload".tr(context),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ": ${widget.media.name}")
            ]),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TMDBListMediaCard(
                    media: widget.media, action: const SizedBox.shrink()),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).cardColor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'video-file',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ).tr(),
                      const SizedBox(
                        height: 10,
                      ),
                      AutoSizeText(
                        'video-file-upload-instruction'.tr(context),
                        minFontSize: 10,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      if (_otherRemoteVideoFiles.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: _buildUncompletedVideoRemoteFiles(),
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      VideoFilePicker(
                        path: _videoFilePath,
                        language: _videoLanguage,
                        onLanguageSelected: (language) => setState(() {
                          _videoLanguage = language;
                        }),
                        onFileSelected: (path) => setState(() {
                          _videoFilePath = path;
                        }),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).cardColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'subtitle-files',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ).tr(),
                      const SizedBox(
                        height: 10,
                      ),
                      AutoSizeText(
                        'subtitle-file-upload-instruction'.tr(context),
                        minFontSize: 10,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SubtitleFilesPicker(
                        values: _subtitleFiles,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SSHConnectionCubit, SSHConnectionState>(
      builder: (context, state) {
        if (state.isConnected()) {
          return BlocListener<SFTPMediaReadDirectoryCubit,
                  SFTPMediaFileAccessState>(
              listener: (context, state) async {
                if (state.opened()) {
                  final remoteFiles =
                      (state as SFTPMediaOpenedState).remoteFiles;
                  _videoFilePath = remoteFiles.videoFilePath;
                  _subtitleFiles.addAll(remoteFiles.subtitleFilesPath);
                  _otherRemoteVideoFiles =
                      remoteFiles.otherFiles.where((e) => e.isExtension(MP4));
                  setState(() {});
                }
              },
              child: _buildContent());
        }
        if (state.failed()) {
          return ErrorScreen(
            errorCode: state.exception,
          );
        }

        return const LoadingScreen();
      },
    );
  }
}

class SubtitleFilesPicker extends StatefulWidget {
  final Map<Language?, NetfloxFilePath?> values;

  const SubtitleFilesPicker({super.key, this.values = const {}});

  @override
  State<SubtitleFilesPicker> createState() => _SubtitleFilesPickerState();
}

class _SubtitleFilesPickerState extends State<SubtitleFilesPicker> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final s in widget.values.entries)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _SubtitleFilePicker(
              language: s.key,
              filePath: s.value,
              subtitleFileSelected: (l, f) {
                setState(() {
                  widget.values.remove(s.key);
                  widget.values[l] = f;
                });
              },
            ),
          ),
        const SizedBox(height: 10),
        _addSubtile(context)
      ],
    );
  }

  Widget _addSubtile(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          widget.values.addAll({null: null});
        });
      },
      icon: const Icon(Icons.add),
      label: const Text('add-subtitle').tr(),
    );
  }
}

class _SubtitleFilePicker extends StatelessWidget {
  final NetfloxFilePath? filePath;
  final Language? language;
  final void Function(Language? language, NetfloxFilePath? filePath)
      subtitleFileSelected;
  const _SubtitleFilePicker(
      {required this.subtitleFileSelected, this.filePath, this.language});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LanguagePicker(
          value: language,
          onLanguageSelected: (language) {
            subtitleFileSelected(language, null);
          },
        ),
        const SizedBox(
          width: 20,
        ),
        if (language != null)
          Flexible(
            child: FilePickerButton(
              filePath: filePath,
              ext: 'srt',
              onFileSelected: (file) {
                subtitleFileSelected(language, file);
              },
            ),
          ),
      ],
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  final Language? value;
  final void Function(Language language) onLanguageSelected;
  const _LanguagePicker({required this.onLanguageSelected, this.value});

  void _showLanguagePicker(BuildContext context) => showDialog(
        context: context,
        builder: (context) => Theme(
          data: context.read<ThemeDataCubit>().state.data.copyWith(
              dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor),
          child: LanguagePickerDialog(
              contentPadding: EdgeInsets.zero,
              isDividerEnabled: true,
              languages: LocalizedLanguage.sortedLocalizedLanguage(context),
              titlePadding: const EdgeInsets.all(8.0),
              itemBuilder: (language) {
                final countryCode = language.countryCode();
                return SizedBox(
                  height: 25,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: AutoSizeText(
                            language.tr(context),
                            maxLines: 1,
                            minFontSize: 8,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        if (countryCode != null)
                          CountryFlagIcon(
                            countryCode: countryCode,
                          ),
                      ]),
                );
              },
              isSearchable: false,
              title: const Text('select-language').tr(),
              onValuePicked: (Language language) {
                onLanguageSelected(language);
              }),
        ),
      );

  @override
  Widget build(BuildContext context) {
    String? countryCode;
    if (value != null) {
      countryCode = languageCodeToCountryCode(value!.isoCode);
    }
    return GestureDetector(
      onTap: () {
        _showLanguagePicker(context);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            CountryFlagIcon(
              countryCode: countryCode,
              fit: BoxFit.fitHeight,
            )
          else
            const Icon(Icons.add),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: AutoSizeText(
              value?.tr(context) ?? 'select-language'.tr(context),
              maxLines: 1,
              minFontSize: 7,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}

class VideoFilePicker extends StatelessWidget {
  final NetfloxFilePath? path;
  final Language? language;
  const VideoFilePicker(
      {super.key,
      this.path,
      this.language,
      required this.onFileSelected,
      required this.onLanguageSelected});
  final void Function(NetfloxFilePath? path) onFileSelected;
  final void Function(Language? language) onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _LanguagePicker(
              value: language, onLanguageSelected: onLanguageSelected),
          const Spacer(),
          Flexible(
            flex: 5,
            child: FilePickerButton(
              filePath: path,
              ext: 'mp4',
              onFileSelected: onFileSelected,
            ),
          ),
        ]),
        if (path?.isLocalFile() ?? false)
          Padding(
              padding: const EdgeInsets.only(top: 15),
              child: _buildVideoPreview())
      ],
    );
  }

  Widget _buildVideoPreview() {
    final file = File(path!.filePath);
    return Container(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: NetfloxVideoPlayer.file(
          videoFile: file,
          quitOnFinish: false,
          mute: true,
          defaultFullScreen: false,
          autoPlay: false,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class FilePickerButton extends StatelessWidget {
  final NetfloxFilePath? filePath;
  final String ext;
  final void Function(NetfloxFilePath? path) onFileSelected;
  FilePickerButton(
      {super.key,
      required this.ext,
      this.filePath,
      required this.onFileSelected});

  bool _retrieving = false;

  Future<void> _pickFile(BuildContext context) async {
    _retrieving = true;
    try {
      final fileResult = await FilePicker.platform.pickFiles(
          allowedExtensions: [ext],
          allowCompression: false,
          type: FileType.custom,
          withReadStream: true);
      final filePath = fileResult?.files.single.path;
      if (filePath != null) {
        onFileSelected(NetfloxFilePath.fromPath(filePath));
      }
    } catch (e) {
      CustomAwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: 'error',
              desc: e.toString(),
              btnOkOnPress: () {})
          .show();
    }
    _retrieving = false;
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Flexible(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
                style: const ButtonStyle(
                    minimumSize: MaterialStatePropertyAll(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: MaterialStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 5, vertical: 2))),
                onPressed: () {
                  if (!_retrieving) {
                    _pickFile(context);
                  }
                },
                child: Text(
                  filePath == null ? 'choose-file' : 'change-file',
                  style: const TextStyle(fontSize: 13),
                ).tr()),
            if (filePath != null) ...[
              const SizedBox(
                height: 5,
              ),
              Flexible(
                  child: AutoSizeText(
                filePath!.fileUri.fileName,
                maxLines: 2,
                textAlign: TextAlign.center,
                wrapWords: true,
                minFontSize: 7,
                style:
                    const TextStyle(fontStyle: FontStyle.italic, fontSize: 10),
              )),
            ]
          ],
        ),
      ),
      const SizedBox(
        width: 8,
      ),
      if (filePath?.isLocalFile() ?? false)
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            onFileSelected(null);
          },
        )
    ]);
  }
}

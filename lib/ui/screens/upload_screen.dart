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
import 'package:netflox/data/blocs/sftp_server/sftp_file_access/sftp_media_file_access_cubit.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import 'package:netflox/data/blocs/sftp_server/ssh_connection/ssh_state.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/media_upload_document.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/widgets/constrained_large_screen_widget.dart';
import 'package:netflox/ui/widgets/custom_awesome_dialog.dart';
import 'package:netflox/ui/widgets/tmdb/list_tmdb_media_card.dart';
import 'package:netflox/ui/widgets/video_player/video_player.dart';
import '../../data/blocs/sftp_server/sftp_file_access/sftp_upload_media_files_cubit.dart';
import '../../data/blocs/theme/theme_cubit_cubit.dart';
import '../../data/models/language.dart';
import '../widgets/country_flag_icon.dart';

class UploadScreen extends StatefulWidget {
  final TMDBLibraryMedia media;
  const UploadScreen({Key? key, required this.media}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _videoFile;
  Language? _videoLanguage;
  Map<Language, File?>? _subtitleFiles;

  void _upload(BuildContext context) async {
    if (_videoFile?.path != null && _videoLanguage != null) {
      context.read<SFTPMediaFilesUploadCubit>().upload(
          widget.media,
          TMDBMediaLibraryUploadDocument(
              videoFile: _videoFile!,
              videoLanguage: _videoLanguage!,
              subtitleFiles: _subtitleFiles));
    } else {
      CustomAwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              title: 'not-saved-files',
              btnOkOnPress: () {},
              desc: 'not-saved-files-desc')
          .tr()
          .show();
    }
  }

  Future _showExitDialog(
          [String title = 'exit-upload-warning',
          String desc = 'exit-upload-warning-desc']) =>
      CustomAwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              title: title,
              btnOkOnPress: () {
                Navigator.pop(context);
              },
              btnCancelOnPress: () {},
              desc: desc)
          .tr()
          .show();

  @override
  void initState() {
    super.initState();
    _initConnection();
  }

  bool get _isUploading =>
      context.read<SFTPMediaFilesUploadCubit>().state.isUploading();

  void _initConnection() {
    context.read<SSHConnectionCubit>().connect();
  }

  Future<bool> _onWillPop() async {
    if (!_isUploading && (_videoFile != null || _subtitleFiles != null)) {
      await _showExitDialog();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SSHConnectionCubit, SSHConnectionState>(
      builder: (context, state) {
        if (state.isConnected()) {
          return BlocListener<SFTPMediaAccessCubit, SFTPMediaFileAccessState>(
              listener: (context, state) {
                if (state.opened()) {
                  final docs = (state as SFTPMediaOpenedState).docs;
                }
              },
              child: ConstrainedLargeScreenWidget(
                child: WillPopScope(
                  onWillPop: _onWillPop,
                  child: Scaffold(
                    appBar: AppBar(
                      actions: [
                        TextButton(
                            onPressed: () => _upload(context),
                            child: const Text('upload').tr()),
                        const SizedBox(
                          width: 15,
                        )
                      ],
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      centerTitle: false,
                      title: Text(
                        "${"upload".tr(context)}: ${widget.media.name}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    body: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 5),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TMDBListMediaCard(
                                    media: widget.media,
                                    action: const SizedBox.shrink()),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Theme.of(context).canvasColor),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'video-file',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ).tr(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      AutoSizeText(
                                        'video-file-upload-instruction'
                                            .tr(context),
                                        minFontSize: 10,
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      VideoFilePicker(
                                        onVideoFileSelected:
                                            (videoFile, language) {
                                          if (videoFile?.path != null) {
                                            _videoFile = File(videoFile!.path!);
                                          }
                                          _videoLanguage = language;
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Theme.of(context).canvasColor),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'subtitle-files',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ).tr(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      AutoSizeText(
                                        'subtitle-file-upload-instruction'
                                            .tr(context),
                                        minFontSize: 10,
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SubtitleFilesPicker(
                                        onFilesSelected: (files) {
                                          _subtitleFiles = {};
                                          for (final e in files.entries) {
                                            if (e.key != null) {
                                              _subtitleFiles!.putIfAbsent(
                                                  e.key!,
                                                  () => e.value != null
                                                      ? File(e.value!.path!)
                                                      : null);
                                            }
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        if (_isUploading)
                          Container(
                            color: Colors.black87,
                          )
                      ],
                    ),
                  ),
                ),
              ));
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
  final void Function(Map<Language?, PlatformFile?> files) onFilesSelected;
  const SubtitleFilesPicker({super.key, required this.onFilesSelected});

  @override
  State<SubtitleFilesPicker> createState() => _SubtitleFilesPickerState();
}

class _SubtitleFilesPickerState extends State<SubtitleFilesPicker> {
  final _subtitleFiles = <Language?, PlatformFile?>{null: null};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final s in _subtitleFiles.entries)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _SubtitleFilePicker(
              language: s.key,
              file: s.value,
              deletionRequested: () {
                setState(() {
                  _subtitleFiles.remove(s.key);
                });
              },
              subtitleFileSelected: (l, f) {
                _subtitleFiles.remove(s.key);
                setState(() {
                  _subtitleFiles.putIfAbsent(l, () => f);
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
      onPressed: () => setState(() {
        _subtitleFiles.putIfAbsent(null, () => null);
      }),
      icon: const Icon(Icons.add),
      label: const Text('add-subtitle').tr(),
    );
  }
}

class _SubtitleFilePicker extends StatelessWidget {
  final Language? language;
  final PlatformFile? file;
  final void Function(Language, PlatformFile?) subtitleFileSelected;
  final void Function()? deletionRequested;
  const _SubtitleFilePicker(
      {required this.subtitleFileSelected,
      this.file,
      this.deletionRequested,
      this.language});

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
        if (language != null)
          Flexible(
            child: FilePickerButton(
              value: file,
              extension: 'srt',
              deleteButtonPressed: () {
                deletionRequested?.call();
              },
              onFileSelected: (file) {
                subtitleFileSelected(language!, file);
              },
            ),
          ),
      ],
    );
  }
}

class _LanguagePicker extends StatefulWidget {
  final Language? value;
  final void Function(Language language) onLanguageSelected;
  const _LanguagePicker({required this.onLanguageSelected, this.value});

  @override
  State<_LanguagePicker> createState() => __LanguagePickerState();
}

class __LanguagePickerState extends State<_LanguagePicker> {
  Language? _currentLanguage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.value;
  }

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
                widget.onLanguageSelected(language);
                setState(() {
                  _currentLanguage = language;
                });
              }),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var countryCode;
    if (_currentLanguage != null) {
      countryCode = languageCodeToCountryCode(_currentLanguage!.isoCode);
    }
    return GestureDetector(
      onTap: () {
        _showLanguagePicker(context);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 46,
            height: 30,
            child: Stack(
              children: [
                const Card(
                  margin: EdgeInsets.zero,
                  child: Center(
                    child: Text("?"),
                  ),
                ),
                if (countryCode != null)
                  CountryFlagIcon(
                    countryCode: countryCode,
                    fit: BoxFit.fitHeight,
                  )
              ],
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: AutoSizeText(
              _currentLanguage?.tr(context) ?? 'select-language'.tr(context),
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

class VideoFilePicker extends StatefulWidget {
  final PlatformFile? value;
  final Language? language;
  final void Function(PlatformFile? videoFile, Language? language)
      onVideoFileSelected;
  const VideoFilePicker(
      {super.key,
      this.value,
      this.language,
      required this.onVideoFileSelected});

  @override
  State<VideoFilePicker> createState() => _VideoFilePickerState();
}

class _VideoFilePickerState extends State<VideoFilePicker> {
  PlatformFile? _videoFile;
  Language? _language;

  @override
  void initState() {
    super.initState();
    _videoFile = widget.value;
    _language = widget.language;
  }

  void _update() {
    widget.onVideoFileSelected(_videoFile, _language);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          _LanguagePicker(
              value: _language,
              onLanguageSelected: (language) {
                setState(() {
                  _language = language;
                  _update();
                });
              }),
          const SizedBox(
            width: 15,
          ),
          Flexible(
            child: FilePickerButton(
              extension: 'mp4',
              onFileSelected: (file) {
                setState(() {
                  _videoFile = file;
                  _update();
                });
              },
            ),
          ),
        ]),
        if (_videoFile != null)
          Padding(
              padding: const EdgeInsets.only(top: 15),
              child: _buildVideoPreview())
      ],
    );
  }

  Widget _buildVideoPreview() {
    final file = _videoFile != null ? File(_videoFile!.path!) : null;
    if (file?.existsSync() ?? false) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: NetfloxVideoPlayer.file(
          videoFile: file!,
          showControl: false,
          quitOnFinish: false,
          defaultFullScreen: false,
          autoPlay: true,
        ),
      );
    } else {
      return const Text("preview-failed").tr();
    }
  }
}

class FilePickerButton extends StatefulWidget {
  final PlatformFile? value;
  final String extension;
  final Function(PlatformFile?) onFileSelected;
  final void Function()? deleteButtonPressed;
  const FilePickerButton(
      {super.key,
      required this.extension,
      this.value,
      this.deleteButtonPressed,
      required this.onFileSelected});

  @override
  State<FilePickerButton> createState() => _FilePickerButtonState();
}

class _FilePickerButtonState extends State<FilePickerButton> {
  String? _fileName;
  final _currentFile = ValueNotifier<PlatformFile?>(null);
  @override
  void initState() {
    super.initState();
    _currentFile.value = widget.value;
    _currentFile.addListener(() {
      setState(() {
        final value = _currentFile.value;
        _fileName = value?.name;
        widget.onFileSelected(value);
      });
    });
  }

  bool _retrieving = false;

  void _pickFile() async {
    _retrieving = true;
    final fileResult = await FilePicker.platform.pickFiles(
        allowedExtensions: [widget.extension],
        allowCompression: false,
        type: FileType.custom,
        withReadStream: true);
    _currentFile.value = fileResult?.files.single;
    _retrieving = false;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
            onPressed: () {
              if (!_retrieving) {
                _pickFile();
              }
            },
            child: Text(
              _fileName == null ? 'choose-file' : 'change-file',
              style: const TextStyle(fontSize: 13),
            ).tr()),
        if (_fileName != null) ...[
          const SizedBox(
            width: 10,
          ),
          Flexible(
              child: Text(
            _fileName!,
            maxLines: 3,
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 10),
          )),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _currentFile.value = null;
              widget.deleteButtonPressed?.call();
            },
          )
        ]
      ],
    );
  }
}

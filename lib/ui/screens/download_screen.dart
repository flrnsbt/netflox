import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import '../../data/blocs/sftp_server/ssh_connection/ssh_connection.dart';

class DownloadScreen extends StatelessWidget {
  final TMDBLibraryMedia media;
  const DownloadScreen({Key? key, required this.media}) : super(key: key);

  void init(BuildContext context) {
    context.read<SSHConnectionCubit>().connect();
  }

  @override
  Widget build(BuildContext context) {
    init(context);
    return Container();
  }
}

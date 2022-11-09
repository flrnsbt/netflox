import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netflox/data/blocs/http_video_server/http_server_cubit.dart';
import 'package:netflox/data/blocs/sftp_server/sftp_file_transfer/sftp_media_file_access_cubit.dart';

import 'package:netflox/utils/rsa_key_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final socket = await SSHSocket.connect(
    serverAddress,
    serverPort,
  );
  final pem = RSAKeysHelper.encodedtoPem(testPrivateKey);
  final sftpClient = await SSHClient(socket,
          username: username, identities: SSHKeyPair.fromPem(pem, passphrase))
      .sftp();
  test("sftp video file retrieval and http binding on localhost", () async {
    final sftpBloc = SFTPMediaReadDirectoryCubit(sftpClient);
    sftpBloc.read(testMovie);
    await sftpBloc.stream.listen((state) {
      debugPrint(state.toString());
      if (state is SFTPMediaOpenedState) {
        final video = state.video;
        final server = HTTPServerVideoBinderCubit();
        server.init(video);
        server.stream.listen((state) {
          debugPrint(state.toString());
        });
      }
    }).asFuture();
  });
  sftpClient.close();
}

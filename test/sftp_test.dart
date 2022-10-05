import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netflox/data/blocs/http_server/http_server_cubit.dart';
import 'package:netflox/data/blocs/sftp_server/media_files_access/media_access_cubit.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/movie.dart';
import 'package:netflox/data/models/tmdb/type.dart';

import 'package:netflox/services/local_storage_manager.dart';
import 'package:netflox/utils/rsa_key_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  LocalStorageManager.init();
  final socket = await SSHSocket.connect(
    "192.168.1.110",
    8888,
  );
  final pem = RSAKeysHelper.encodedtoPem(testPrivateKey);
  final sftpClient = await SSHClient(socket,
          username: "netfloxUser",
          identities: SSHKeyPair.fromPem(pem, passphrase))
      .sftp();
  test("sftp directory retrieval test", () async {
    final sftpBloc = LibraryMediaAccessCubit(sftpClient);
    final media = LibraryMediaInformation(TMDBType.movie, "37652");
    sftpBloc.open(media);
    await sftpBloc.stream.listen((state) {
      print(state);
      if (state is SFTPMediaOpenedState) {
        final video = state.video;
        final server = LocalServerVideoBinderCubit();
        server.bind(video);
        server.stream.listen((state) {
          print(state);
        });
      }
    }).asFuture();
  });
  sftpClient.close();
}

const String kApplicationDocumentsPath =
    '/Users/flrnsbt/test/applicationDocument';

const String kTemporaryPath = '/Users/flrnsbt/test/temporary';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return kTemporaryPath;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return kApplicationDocumentsPath;
  }

  @override
  Future<String?> getLibraryPath() async {
    return kApplicationDocumentsPath;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return kApplicationDocumentsPath;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return kApplicationDocumentsPath;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return <String>[kApplicationDocumentsPath];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>[kApplicationDocumentsPath];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return kApplicationDocumentsPath;
  }
}

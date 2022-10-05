import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:netflox/data/constants/local_server.dart';
part 'http_server_state.dart';

class LocalServerVideoBinderCubit extends Cubit<HttpVideoBinderState> {
  HttpServer? _server;
  ServerSocket? _socket;
  LocalServerVideoBinderCubit() : super(HttpVideoBinderState.off);

  Future<void> bind(SftpFile video) async {
    if (state.isRunning()) {
      _server!.close(force: true);
    }
    emit(HttpVideoBinderState.off);
    try {
      _socket = await ServerSocket.bind(kLocalServerAddress, kLocalServerPort);
      _server = HttpServer.listenOn(_socket!);
      _server!.listen((HttpRequest req) async {
        final fileLength = (await video.stat()).size!;
        if (req.method == "HEAD") {
          req.response.statusCode = 200;
          req.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
          req.response.headers.contentLength = fileLength;
          req.response.close();
        } else {
          int start = 0;
          int end = fileLength - 1;
          req.response.statusCode = HttpStatus.ok;
          req.response.headers.contentType = ContentType.parse("video/mp4");
          req.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
          final range = req.headers['range']?.first.split("=").last.split("-");
          if (range != null) {
            start = int.tryParse(range.first)?.clamp(0, end) ?? 0;
            final int _end = int.tryParse(range.last)?.clamp(start, end) ?? 1;
            if (_end == 1) {
              end = fileLength - 1;
            } else {
              end = _end;
            }
            req.response.statusCode = 206;
          } else {
            req.response.statusCode = 200;
          }
          req.response.headers
              .set(HttpHeaders.connectionHeader, 'keep-alive'); //
          req.response.headers.contentLength = end - start + 1;
          req.response.headers.set(
              HttpHeaders.contentRangeHeader, 'bytes $start-$end/$fileLength');
          final stream = video.read(offset: start).handleError((e) {
            req.response.statusCode = 500;
          });
          req.response.addStream(stream);
        }

        print(req.headers);
        print(req.response.headers);
      });
      emit(HttpVideoBinderState.on);
    } catch (e) {
      emit(HttpVideoBinderState.fail(e));
    }
  }

  @override
  Future<void> close() async {
    await _socket?.close();
    await _server?.close(force: true);
    emit(HttpVideoBinderState.off);
    return super.close();
  }
}

class LocalHostHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (host.isNotEmpty && (host == "127.0.0.1" || host == "localhost")) {
          return true;
        }
        return false;
      };
  }
}

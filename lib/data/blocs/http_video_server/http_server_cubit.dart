import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:netflox/data/constants/local_server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
part 'http_server_state.dart';

class HTTPServerVideoBinderCubit extends Cubit<HttpVideoBinderState> {
  HttpServer? _server;
  HTTPServerVideoBinderCubit() : super(HttpVideoBinderState.off);

  void init(SftpFile video) async {
    final fileSize = (await video.stat()).size ?? 0;
    if (state == HttpVideoBinderState.off) {
      try {
        _server = await shelf_io.serve(((request) async {
          final responseHeader = <String, Object>{};
          int? start;
          int? end;
          final range = request.headers['range'];
          if (range != null) {
            const bytesPrefix = "bytes=";
            if (range.startsWith(bytesPrefix)) {
              final bytesRange = range.substring(bytesPrefix.length);
              final parts = bytesRange.split("-");
              if (parts.length == 2) {
                final rangeStart = parts[0].trim();
                if (rangeStart.isNotEmpty) {
                  start = int.parse(rangeStart);
                }
                final rangeEnd = parts[1].trim();
                if (rangeEnd.isNotEmpty) {
                  end = int.parse(rangeEnd);
                }
              }
            }
          }
          responseHeader.putIfAbsent(
              HttpHeaders.contentTypeHeader, () => 'video/mp4');
          try {
            if (request.method == "HEAD") {
              responseHeader.putIfAbsent(
                  HttpHeaders.acceptRangesHeader, () => 'bytes');
              responseHeader.putIfAbsent(
                  HttpHeaders.contentLengthHeader, () => fileSize.toString());
              return Response.ok(null, headers: responseHeader);
            } else {
              int retrievedLength;
              if (start != null && end != null) {
                retrievedLength = (end + 1) - start;
              } else if (start != null) {
                retrievedLength = fileSize - start;
              } else if (end != null) {
                retrievedLength = (end + 1);
              } else {
                retrievedLength = fileSize;
              }

              final int statusCode = (start != null || end != null) ? 206 : 200;
              start = start ?? 0;
              end = end ?? fileSize - 1;
              responseHeader.putIfAbsent(HttpHeaders.contentLengthHeader,
                  () => retrievedLength.toString());

              if (range != null) {
                responseHeader.putIfAbsent(HttpHeaders.contentRangeHeader,
                    () => 'bytes $start-$end/$fileSize');
                responseHeader.putIfAbsent(
                    HttpHeaders.acceptRangesHeader, () => 'bytes');
              }

              final stream = video
                  .read(offset: start, length: retrievedLength)!
                  .handleError((e) {
                throw e;
              });
              return Response(statusCode,
                  body: stream,
                  headers: responseHeader,
                  context: {"shelf.io.buffer_output": false});
            }
          } catch (e) {
            return Response.internalServerError();
          }
        }), kLocalServerAddress, kLocalServerPort);
        emit(HttpVideoBinderState.on);
      } catch (e) {
        emit(HttpVideoBinderState.fail(e));
      }
    }
  }

  @override
  Future<void> close() async {
    await _server?.close(force: true);
    emit(HttpVideoBinderState.off);
    return super.close();
  }
}

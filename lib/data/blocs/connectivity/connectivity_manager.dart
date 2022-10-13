import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/constants/default_app_timeout.dart';
part 'connectivity_state.dart';

class ConnectivityManager extends Cubit<ConnectivityState> {
  StreamSubscription? _stream;
  ConnectivityManager() : super(ConnectivityState.init) {
    HttpOverrides.global = LocalHostHttpOverrides();
    _stream = Connectivity().onConnectivityChanged.listen((medium) {
      emit(ConnectivityState.update(medium));
    });
  }

  Future<void> check() async {
    final result = await Connectivity().checkConnectivity();
    await Future.delayed(const Duration(seconds: 1));
    emit(ConnectivityState.update(result));
  }

  @override
  Future<void> close() {
    _stream?.cancel();
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
      }
      ..connectionTimeout = kDefaultTimeout;
  }
}

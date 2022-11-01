import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/constants/basic_fetch_status.dart';
import 'package:netflox/data/constants/default_app_timeout.dart';
import '../../services/firestore_service.dart';
import '../models/server_configs/ssh_config.dart';
import '../models/server_configs/tmdb_config.dart';

class AppConfigCubit extends Cubit<AppConfig> {
  AppConfigCubit() : super(const AppConfig()) {
    get();
  }

  FutureOr<void> get([bool force = false]) async {
    if (!state.success() || force) {
      emit(const AppConfig());
      try {
        final config =
            await FirestoreService.config.get().timeout(kDefaultTimeout);
        if (config.size >= 2) {
          final docs = config.docs;
          final tmdbApiConfigData =
              docs.singleWhere((e) => e.id == 'tmdb_api_config');
          final sshConfigData = docs.singleWhere((e) => e.id == 'ssh_config');
          final tmdbApiConfig = TMDBApiConfig.fromMap(tmdbApiConfigData.data());
          final sshConfig = NetfloxSSHConfig.fromMap(sshConfigData.data());
          emit(AppConfig(
              tmdbApiConfig: tmdbApiConfig,
              sshConfig: sshConfig,
              status: BasicServerFetchStatus.success));
        }
      } catch (e) {
        emit(AppConfig(error: e, status: BasicServerFetchStatus.failed));
      }
    }
  }
}

class AppConfig extends Equatable with BasicServerFetchStatusInterface {
  @override
  final BasicServerFetchStatus status;
  final TMDBApiConfig? tmdbApiConfig;
  final NetfloxSSHConfig? sshConfig;

  const AppConfig(
      {this.tmdbApiConfig,
      this.sshConfig,
      this.status = BasicServerFetchStatus.loading,
      this.error});

  @override
  List<Object?> get props => [tmdbApiConfig, sshConfig];

  @override
  final Object? error;
}

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language_picker/languages.dart';

import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import '../../../../services/firestore_service.dart';
import '../../../models/tmdb/library_media_information.dart';
import '../basic_server_fetch_state.dart';

class LibraryMediaInfoFetchCubit
    extends Cubit<BasicServerFetchState<LibraryMediaInformation>> {
  final TMDBLibraryMedia media;
  LibraryMediaInfoFetchCubit(this.media) : super(BasicServerFetchState.init()) {
    var libraryMediaInformation = media.libraryMediaInfo;
    FirestoreService.media.doc(media.id).snapshots().listen((doc) {
      final data = doc.data();
      if (data != null) {
        libraryMediaInformation = LibraryMediaInformation.fromMap(data);
        media.libraryMediaInfo = libraryMediaInformation;
      }
      emit(BasicServerFetchState.success(result: libraryMediaInformation));
    });
  }

  Future<void> sendRequest() async {
    if (state.hasData()) {
      final data = state.result!.toMap();
      data['media_status'] = MediaStatus.pending.name;
      emit(BasicServerFetchState.loading());
      try {
        await FirestoreService.media.doc(media.id).set(data);
      } catch (e) {
        final exception = NetfloxException.from(e);
        emit(BasicServerFetchState.failed(exception));
      }
    }
  }

  Future<void> available(Language language,
      [Iterable<Language>? subtitles]) async {
    if (state.hasData()) {
      emit(BasicServerFetchState.loading());
      final data = state.result!.toMap();
      data['media_status'] = MediaStatus.available.name;
      data['subtitles'] = subtitles?.map((e) => e.isoCode);
      data['languages'] = [language.isoCode];
      data['added_on'] = Timestamp.now();
      try {
        await FirestoreService.media
            .doc(media.id)
            .set(data, SetOptions(merge: true));
      } catch (e) {
        final exception = NetfloxException.from(e);
        emit(BasicServerFetchState.failed(exception));
      }
    }
  }
}

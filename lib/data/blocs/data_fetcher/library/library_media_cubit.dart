import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import '../../../../services/firestore_service.dart';
import '../../../models/tmdb/library_media_information.dart';
import '../../../models/tmdb/library_files.dart';
import '../basic_server_fetch_state.dart';

class LibraryMediaInfoFetchCubit
    extends Cubit<BasicServerFetchState<LibraryMediaInformation>> {
  final TMDBLibraryMedia media;
  final DocumentReference<Map<String, dynamic>> _docRef;
  LibraryMediaInfoFetchCubit(this.media)
      : _docRef = FirestoreService.media.doc(media.id),
        super(BasicServerFetchState.init()) {
    var libraryMediaInformation = media.libraryMediaInfo;

    _docRef.snapshots().listen((doc) async {
      final data = doc.data();
      if (data != null) {
        libraryMediaInformation = LibraryMediaInformation.fromMap(data);
        media.libraryMediaInfo = libraryMediaInformation;
      }
      emit(BasicServerFetchState.success(result: libraryMediaInformation));
    });
  }

  Future<void> _updateData(Map<String, dynamic> data) {
    data.addAll(media.libraryIdMap());
    return _docRef.set(data, SetOptions(merge: true));
  }

  Future<void> sendRequest() async {
    if (!state.isLoading()) {
      final data = <String, dynamic>{};
      data['media_status'] = MediaStatus.pending.name;
      emit(BasicServerFetchState.loading());
      try {
        await _updateData(data);
      } catch (e) {
        final exception = NetfloxException.from(e);
        emit(BasicServerFetchState.failed(exception));
      }
    }
  }

  Future<void> available(
      TMDBMediaLibraryLanguageConfiguration mediaLibraryStats) async {
    if (!state.isLoading()) {
      emit(BasicServerFetchState.loading());
      final data = <String, dynamic>{};
      data['media_status'] = MediaStatus.available.name;
      data['subtitles'] = mediaLibraryStats.subtitleLanguages
          .map<String>((e) => e.isoCode)
          .toList();
      data['languages'] = [
        if (mediaLibraryStats.videoLanguage != null)
          mediaLibraryStats.videoLanguage!.isoCode
      ];
      data['added_on'] = Timestamp.now();
      try {
        await _updateData(data);
      } catch (e) {
        final exception = NetfloxException.from(e);
        emit(BasicServerFetchState.failed(exception));
      }
    }
  }
}

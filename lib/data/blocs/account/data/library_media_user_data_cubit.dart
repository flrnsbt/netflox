// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:netflox/data/blocs/account/auth/auth_cubit.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/services/firestore_service.dart';

class LibraryMediaUserDataCubit extends Cubit<LibraryMediaUserDataState> {
  final DocumentReference<Map<String, dynamic>> _docRef;
  final TMDBLibraryMedia media;
  LibraryMediaUserDataCubit(BuildContext context, this.media)
      : _docRef = FirestoreService.userMediaData(
                context.read<AuthCubit>().state.user!.id)
            .doc(media.id),
        super(const LibraryMediaUserDataState()) {
    _docRef.snapshots().listen((doc) async {
      emit(LibraryMediaUserDataState.fromMap(doc.data()));
    });
  }

  Future<void> updateTimestamp(Duration playbackTimestamp) {
    return _update({"playback_time": playbackTimestamp.inSeconds});
  }

  Future<void> _update(Map<String, dynamic> data) {
    data.addAll(media.libraryIdMap());
    data.putIfAbsent('added_on', () => Timestamp.now());
    return _docRef.set(data, SetOptions(merge: true));
  }

  Future<void> toggleLike() {
    return _update({"liked": !state.liked});
  }
}

class LibraryMediaUserDataState extends Equatable {
  bool get watched => playbackTimestamp != null;
  final Duration? playbackTimestamp;
  final bool liked;

  const LibraryMediaUserDataState({this.playbackTimestamp, bool? liked})
      : liked = liked ?? false;

  @override
  List<Object?> get props => [playbackTimestamp, liked];

  factory LibraryMediaUserDataState.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      return LibraryMediaUserDataState(
        liked: map['liked'],
        playbackTimestamp: map['playback_time'] != null
            ? Duration(seconds: map['playback_time'])
            : null,
      );
    }
    return const LibraryMediaUserDataState();
  }
}

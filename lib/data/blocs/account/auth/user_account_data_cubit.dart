// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:netflox/data/blocs/account/auth/auth_cubit.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/services/firestore_service.dart';

class LibraryMediaUserPlaybackStateCubit
    extends Cubit<LibraryMediaUserPlaybackState> {
  final DocumentReference<Map<String, dynamic>> _docRef;
  LibraryMediaUserPlaybackStateCubit(
      BuildContext context, TMDBPlayableMedia media)
      : _docRef = FirestoreService.userWatchedMedia(
                context.read<AuthCubit>().state.user!.id)
            .doc(media.id),
        super(const LibraryMediaUserPlaybackState()) {
    _docRef.snapshots().listen((event) {
      emit(LibraryMediaUserPlaybackState.fromMap(event.data()));
    });
  }

  void update(Duration playbackTimestamp) {
    _docRef.set({"playback_time": playbackTimestamp.inSeconds},
        SetOptions(merge: true));
  }
}

class LibraryMediaUserPlaybackState extends Equatable {
  bool get watched => playbackTimestamp != null;
  final Duration? playbackTimestamp;

  const LibraryMediaUserPlaybackState([this.playbackTimestamp]);

  @override
  List<Object?> get props => [watched, playbackTimestamp];

  factory LibraryMediaUserPlaybackState.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      return LibraryMediaUserPlaybackState(
        map['playback_time'] != null
            ? Duration(seconds: map['playback_time'])
            : null,
      );
    }
    return const LibraryMediaUserPlaybackState();
  }
}

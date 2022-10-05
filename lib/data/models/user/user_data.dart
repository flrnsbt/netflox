import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../../services/firestore_service.dart';

class NetfloxUserData {
  String? _userId;
  NetfloxUserData.fromId(String userId) : _userId = userId;
  NetfloxUserData.fromMediaData(NetfloxUserMediaData mediaData)
      : _mediaData = mediaData;

  NetfloxUserMediaData? _mediaData;

  FutureOr<NetfloxUserMediaData?> mediaData() async {
    if (_mediaData == null) {
      final doc = await FirestoreService.userMediaData(_userId!).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final mediaData = NetfloxUserMediaData.fromMap(data);
          _mediaData = mediaData;
        }
      }
    }
    return _mediaData;
  }
}

class NetfloxUserMediaData extends Equatable {
  final Set<String> watchedMedias;
  final Set<String> likedMedias;

  const NetfloxUserMediaData(
      {required this.watchedMedias, required this.likedMedias});

  @override
  List<Object?> get props => [watchedMedias, likedMedias];

  Map<String, dynamic> toMap() {
    return {
      'watchedMedias': watchedMedias,
      'likedMedias': likedMedias,
    };
  }

  factory NetfloxUserMediaData.fromMap(Map<String, dynamic>? map) {
    return NetfloxUserMediaData(
      watchedMedias: map?['watchedMedias']?.toSet() ?? {},
      likedMedias: map?['likedMedias']?.toSet() ?? {},
    );
  }
}

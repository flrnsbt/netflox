import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/constants/app_configuration.dart';

class FirestoreService {
  static final users = FirebaseFirestore.instance.collection("users");
  static final media = FirebaseFirestore.instance.collection("medias");
  static final config = FirebaseFirestore.instance.collection("config");
  static final sshConfig = FirebaseFirestore.instance.doc("config/ssh_config");
  static final tmdbConfig =
      FirebaseFirestore.instance.doc("config/tmdb_api_config");

  static DocumentReference<Map<String, dynamic>> user(String id) {
    return FirebaseFirestore.instance.doc('users/$id');
  }

  static DocumentReference<Map<String, dynamic>> userKeys(String id) {
    return FirebaseFirestore.instance.doc('users/$id/data/keys');
  }

  static CollectionReference<Map<String, dynamic>> userWatchedMedia(String id) {
    return FirebaseFirestore.instance
        .collection('users/$id/data/media/watched');
  }

  static CollectionReference<Map<String, dynamic>> userLikedMedia(String id) {
    return FirebaseFirestore.instance.collection('users/$id/data/media/liked');
  }

  static CollectionReference<Map<String, dynamic>> userData(String id) {
    return FirebaseFirestore.instance.collection('users/$id/data');
  }
}

extension FirestorePagedQuery on Query {
  Future<QuerySnapshot<Map<String, dynamic>>> fetchAfterDoc(
      [DocumentSnapshot? startFromDoc,
      int pageSize = kDefaultPageItemNumber]) async {
    Query<Map<String, dynamic>> query =
        limit(pageSize) as Query<Map<String, dynamic>>;
    if (startFromDoc != null) {
      query = query.startAfterDocument(startFromDoc);
    }
    return query.get();
  }
}

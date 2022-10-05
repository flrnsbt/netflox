import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;
  final StreamController<User?> _streamController;
  FirebaseAuthService({FirebaseAuth? auth, void Function(User?)? onUserChanged})
      : _auth = auth ?? FirebaseAuth.instance,
        _streamController = StreamController.broadcast() {
    _auth.authStateChanges().listen((event) {
      _streamController.add(event);
    });
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get stream => _streamController.stream;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  void close() {
    _streamController.close();
  }

  FutureOr<void> update({String? newEmail, String? newPassword}) async {
    try {
      if (newEmail != null) {
        await currentUser?.updateEmail(newEmail);
      }
      if (newPassword != null) {
        await currentUser?.updatePassword(newPassword);
      }
      _streamController.add(currentUser);
    } catch (e) {
      _streamController.addError(e);
    }
  }

  Future<String?> signUp(
      {required String email, required String password}) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return userCredential.user?.uid;
  }

  FutureOr<void> reauthenticate(
      {required String password, String? email}) async {
    if (currentUser != null && (currentUser!.email != null || email != null)) {
      try {
        await currentUser?.reauthenticateWithCredential(
            EmailAuthProvider.credential(
                email: email ?? currentUser!.email!, password: password));
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  FutureOr<void> delete() {
    return _auth.currentUser?.delete();
  }
}

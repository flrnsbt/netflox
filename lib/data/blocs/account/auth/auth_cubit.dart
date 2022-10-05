import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:netflox/data/models/user/user.dart';
import 'package:netflox/services/firebase_auth_service.dart';
import 'package:netflox/utils/rsa_key_helper.dart';
import '../../../../services/firestore_service.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuthService _authService;
  StreamSubscription<User?>? _listener;
  AuthCubit({FirebaseAuthService? authService})
      : _authService = authService ?? FirebaseAuthService(),
        super(AuthState.signedOut()) {
    _listener = _authService.stream.listen((User? user) async {
      emit(AuthState.loading());
      if (user == null) {
        emit(AuthState.signedOut());
      } else {
        Map<String, dynamic>? data;
        Object? exception;
        try {
          final id = user.uid;
          data = await _retrieveUserData(id);
          final keyPair = await _retrieveRSAKey(id);
          data.putIfAbsent("key_pair", () => keyPair);
        } catch (e) {
          exception = e;
        }
        final netfloxUser = NetfloxUser.fromUser(user, data: data);
        emit(AuthState.signedIn(user: netfloxUser, message: exception));
      }
    }, onError: (e) {
      print("ERROR: $e");
    });
  }

  @override
  Future<void> close() async {
    _listener?.cancel();
    super.close();
  }

  Future<Map<String, dynamic>> _retrieveUserData(String id) async {
    final doc = await FirestoreService.user(id).get();
    Map<String, dynamic>? data;
    if (doc.exists) {
      emit(AuthState.loading("retrieving-user-data"));
      data = doc.data();
    } else {
      emit(AuthState.loading("generating-user-data"));
      data = NetfloxUser.defaultUserData;
      doc.reference.set(data);
    }
    await Future.delayed(const Duration(seconds: 1));
    return data!;
  }

  Future<List<SSHKeyPair>?> _retrieveRSAKey(String id) async {
    final doc = await FirestoreService.userKeys(id)
        .get(const GetOptions(source: Source.server));
    if (doc.exists) {
      emit(AuthState.loading("retrieving-user-key"));
      String? pem = doc.get('private_key');
      if (pem != null) {
        pem = RSAKeysHelper.encodedtoPem(pem);
        final keyPair = SSHKeyPair.fromPem(pem, id);
        return keyPair;
      }
    }
    return null;
  }

  Future<void> wait() {
    return stream.firstWhere((e) => e != AuthState.loading());
  }

  FutureOr<void> deleteAccount() async {
    try {
      final id = _authService.currentUser!.uid;
      await FirestoreService.userKeys(id).delete();
      await FirestoreService.user(id).delete();
      await _authService.delete();
    } catch (e) {
      emit(state.copyWith(message: e));
    }
  }

  FutureOr<void> updateAccountDetails(
      {String? newEmail, String? newPassword}) async {
    try {
      await _authService.update(newEmail: newEmail, newPassword: newPassword);
    } catch (e) {
      emit(state.copyWith(message: e));
    }
  }

  void signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      emit(state.copyWith(message: e));
    }
  }
}

import 'package:dartssh2/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserType {
  user,
  admin;

  factory UserType.fromString(String? name) {
    return UserType.values
        .firstWhere((e) => e.name == name, orElse: () => UserType.user);
  }
}

class NetfloxUser extends Equatable {
  static const defaultUserData = <String, dynamic>{
    "userType": "user",
    "verified": false,
  };

  final String id;
  final String displayName;
  final String? email;
  final String? imgURL;
  final UserType userType;
  final bool verified;
  final List<SSHKeyPair>? sshKeyPair;

  bool isAdmin() => userType == UserType.admin;
  bool isNormalUser() => userType == UserType.user;

  const NetfloxUser({
    required this.id,
    required this.displayName,
    this.userType = UserType.user,
    this.verified = false,
    this.email,
    this.imgURL,
    this.sshKeyPair,
  });

  Map<String, dynamic> toMap() {
    return {
      'userType': userType,
      'verified': verified,
    };
  }

  factory NetfloxUser.fromUser(User user, {Map<String, dynamic>? data}) {
    final finalData = user.toMap();
    if (data != null) {
      finalData.addAll(data);
    }
    return NetfloxUser.fromMap(finalData);
  }

  factory NetfloxUser.fromUserCredential(UserCredential userCredential,
      {Map<String, dynamic>? data}) {
    return NetfloxUser.fromUser(userCredential.user!, data: data);
  }

  factory NetfloxUser.fromMap(Map<String, dynamic> map) {
    return NetfloxUser(
      id: map['id'],
      userType: UserType.fromString(map['userType']),
      verified: map['verified'] ?? false,
      displayName:
          map['firstName'] ?? map['email']?.split("@").first ?? map['id'],
      email: map['email'] ?? '',
      imgURL: map['imgURL'],
      sshKeyPair: map['key_pair'],
    );
  }

  @override
  String toString() {
    return 'NetfloxUser(id: $id, firstName: $displayName, email: $email, imgURL: $imgURL, verified: $verified)';
  }

  @override
  List<Object?> get props {
    return [id];
  }
}

extension on User {
  Map<String, dynamic> toMap() {
    return {
      "displayName": displayName ?? email?.split("@").first ?? uid,
      "id": uid,
      "email": email,
      "imgURL": photoURL
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserClass { moderator, admin, coAdmin, user }

class UserAuth {
  late final String? uid;
  late final DateTime? creationTime;
  late final DateTime? lastSignInTime;
  late String? displayName;
  late String? phoneNum;
  UserClass? userClass = UserClass.user;
  late List? groups;
  late String? email;
  late List? groupsAdmin;
  late bool? isAnonymous;
  late List? cities;

  UserAuth(
      {this.uid,
      this.groupsAdmin,
      this.creationTime,
      this.lastSignInTime,
      this.isAnonymous,
      this.userClass,
      this.phoneNum,
      this.groups,
      this.cities,
      this.displayName,
      this.email});

  static UserClass parseUserClass(Object rank) {
    switch (rank.toString()) {
      case "moderator":
        return UserClass.moderator;
      case "admin":
        return UserClass.admin;
      case "coAdmin":
        return UserClass.coAdmin;
      default:
        return UserClass.user;
    }
  }
}

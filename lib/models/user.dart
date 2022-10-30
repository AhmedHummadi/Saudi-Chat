import 'package:cloud_firestore/cloud_firestore.dart';

enum UserClass { moderator, admin, coAdmin, user }

class UserAuth {
  // a user can only be admin or subadmin to 1 group

  late final String? uid;
  late final DateTime? creationTime;
  late final DateTime? lastSignInTime;
  late String? displayName;
  late String? phoneNum;
  UserClass? userClass = UserClass.user;
  late List? groups;
  late String? email;
  late DocumentReference? groupAdmin;
  late bool? isAnonymous;
  late List? cities;

  UserAuth(
      {this.uid,
      this.groupAdmin,
      this.creationTime,
      this.lastSignInTime,
      this.isAnonymous,
      this.userClass,
      this.phoneNum,
      this.groups,
      this.cities,
      this.displayName,
      this.email});

  static bool checkIfClassIsLower(
      {required UserClass targetClass, required String rank}) {
    switch (rank.toString()) {
      case "moderator":
        return targetClass == UserClass.admin ||
            targetClass == UserClass.coAdmin ||
            targetClass == UserClass.user;
      case "admin":
        return targetClass == UserClass.coAdmin ||
            targetClass == UserClass.user;
      case "coAdmin":
        return targetClass == UserClass.user;
      default:
        return false;
    }
  }

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

  static UserAuth parseFromUserDocument(Map data) {
    return UserAuth(
        uid: data["id"],
        phoneNum: data["phoneNum"],
        email: data["email"],
        displayName: data["name"],
        groupAdmin: data["groupAdmin"],
        groups: data["groups"],
        creationTime: data["creationTime"] != null
            ? (data["creationTime"] as Timestamp).toDate()
            : null,
        lastSignInTime: data["lastSignInTime"] != null
            ? (data["lastSignInTime"] as Timestamp).toDate()
            : null,
        cities: data["cities"],
        userClass: UserAuth.parseUserClass(data["userClass"]));
  }
}

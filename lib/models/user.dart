import 'package:cloud_firestore/cloud_firestore.dart';

class UserAuth {
  late final String? uid;
  late final DateTime? creationTime;
  late final DateTime? lastSignInTime;
  late String? displayName;
  late String? phoneNum;
  late List? groups;
  late String? email;
  late DocumentReference? nadiAdminDoc;
  late bool? isAnonymous;
  late List? cities;

  UserAuth(
      {this.uid,
      this.nadiAdminDoc,
      this.creationTime,
      this.lastSignInTime,
      this.isAnonymous,
      this.phoneNum,
      this.groups,
      this.cities,
      this.displayName,
      this.email});
}

// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saudi_chat/models/image.dart';

class NadiData {
  late final String? id;
  late final String? location;
  late String? nadiName;
  late List? news;
  late ImageClass? iconImage;
  late String? phoneNum;
  late String? email;

  NadiData(
      {this.news,
      this.phoneNum,
      this.nadiName,
      this.iconImage,
      this.email,
      this.id,
      this.location});

  static NadiData parse(Map map) {
    return NadiData(
        id: map["id"] ?? map["nadi_id"],
        location: map["location"],
        nadiName: map["name"],
        iconImage: map["iconImage"],
        news: map["news"],
        phoneNum: map["phoneNum"],
        email: map["email"]);
  }
}

class GroupData {
  late final NadiData? nadiData;
  late final String? id;
  late final List? messages;
  late final List? time_of_messages;
  late final List? users_doc_references;
  late final List? users_name;
  late List? blockedUsers;
  late final DocumentReference? reference;

  GroupData(
      {this.messages,
      this.nadiData,
      this.reference,
      this.id,
      this.blockedUsers,
      this.time_of_messages,
      this.users_doc_references,
      this.users_name});

  static GroupData parse(Map map) {
    return GroupData(
        messages: map["messages"],
        blockedUsers: map["blockedUsers"],
        id: map["id"] ?? map["nadi_id"],
        time_of_messages: map["time_of_messages"],
        users_doc_references: map["users_doc_reference"],
        users_name: map["users_name"],
        nadiData: NadiData.parse(map["nadi_data"]));
  }
}

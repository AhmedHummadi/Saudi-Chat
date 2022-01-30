// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class NadiData {
  late final String? id;
  late final String? location;
  late String? nadiName;
  late List? news;
  late String? phoneNum;
  late String? email;

  NadiData(
      {this.news,
      this.phoneNum,
      this.nadiName,
      this.email,
      this.id,
      this.location});

  static NadiData parse(Map map) {
    return NadiData(
        id: map["id"],
        location: map["location"],
        nadiName: map["name"],
        news: map["news"],
        phoneNum: map["phoneNum"],
        email: map["email"]);
  }
}

class GroupData {
  late final Map? nadiData;
  late final List? messages;
  late final List? time_of_messages;
  late final List? users_doc_references;
  late final List? users_name;
  late final DocumentReference? reference;

  GroupData(
      {this.messages,
      this.nadiData,
      this.reference,
      this.time_of_messages,
      this.users_doc_references,
      this.users_name});

  static GroupData parse(Map map) {
    return GroupData(
        messages: map["messages"],
        time_of_messages: map["time_of_messages"],
        users_doc_references: map["users_doc_reference"],
        users_name: map["users_name"],
        nadiData: map["nadiData"]);
  }
}

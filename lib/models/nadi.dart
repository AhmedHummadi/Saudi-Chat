import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saudi_chat/models/news_form.dart';

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

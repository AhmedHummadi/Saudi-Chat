// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saudi_chat/models/nadi.dart';

class NewsForm {
  late String? title;
  late String? description;
  late String? imageUrl;
  late Timestamp? dateCreated;
  late ImageProvider? previewImageP;
  late String? created_by;
  late NadiData? nadi;
  late DocumentReference? nadiDoc;

  NewsForm(
      {this.dateCreated,
      this.imageUrl,
      this.nadi,
      this.nadiDoc,
      this.previewImageP,
      this.created_by,
      this.description,
      this.title});

  static NewsForm parse(Map map) {
    return NewsForm(
        title: map["title"],
        created_by: map["created_by"],
        description: map["description"],
        dateCreated: map["dateCreated"],
        imageUrl: map["imageUrl"],
        nadi: NadiData.parse(map["nadi"]),
        nadiDoc: map["nadiDoc"]);
  }
}

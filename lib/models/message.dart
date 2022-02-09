// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum NewMessageCommandEnum { addMessage, removeMessage }

class Message {
  late String? message;
  late String? userName;
  late String? businessName;
  late String? documentId;
  late Timestamp? time;

  Message(
      {this.message,
      this.time,
      this.userName,
      this.businessName,
      this.documentId});

  // ignore: empty_constructor_bodies
  Timestamp get getTime {
    return Timestamp.now();
  }
}

class NewMessageCommand {
  late final NewMessageCommandEnum command;
  late final Widget widget;
  late final Message message;

  NewMessageCommand(
      {required this.command, required this.message, required this.widget});
}

class ImageMessage extends Message {
  late final String url;
  late final String storage_path;

  ImageMessage(
      {String? userName,
      String? documentId,
      Timestamp? time,
      required this.url,
      required this.storage_path})
      : super(userName: userName, documentId: documentId, time: time);
}

class VoiceMessage extends Message {
  late final String? url;
  late final String? storage_path;
  late final Duration durationMilliseconds;

  VoiceMessage(
      {String? userName,
      String? documentId,
      Timestamp? time,
      this.url,
      required this.durationMilliseconds,
      this.storage_path})
      : super(userName: userName, documentId: documentId, time: time);
}

class VideoMessage extends Message {
  late final String url;
  late final String storage_path;

  VideoMessage(
      {String? userName,
      String? documentId,
      Timestamp? time,
      required this.url,
      required this.storage_path})
      : super(userName: userName, documentId: documentId, time: time);
}

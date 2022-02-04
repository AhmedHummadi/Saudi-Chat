// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum NewMessageCommandEnum { addMessage, removeMessage }

class Message {
  late String? message;
  late String? userName;
  late String? businessName;
  late String? documentId;
  late String? time;

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

  ImageMessage({required this.url, required this.storage_path});
}

class VoiceMessage extends Message {
  late final String url;
  late final String storage_path;

  VoiceMessage({required this.url, required this.storage_path});
}

class VideoMessage extends Message {
  late final String url;
  late final String storage_path;

  VideoMessage({required this.url, required this.storage_path});
}

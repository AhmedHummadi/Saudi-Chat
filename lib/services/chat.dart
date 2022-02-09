// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'package:saudi_chat/models/message.dart';
import 'package:saudi_chat/models/nadi.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:gallery_saver/files.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum MessageException {
  create_message_error,
  add_message_error,
  add_voice_error,
  add_file_error,
  add_user_to_group_error,
  null_user_name_error,
  remove_group_error,
}

class MessageDatabase {
  final firebase_storage.FirebaseStorage firestorage =
      firebase_storage.FirebaseStorage.instance;

  final CollectionReference messagesCollection =
      DataBaseService().messagesCollection;

  final Future<Directory> cache = getTemporaryDirectory();

  // add message to group chat
  Future addMessageToGroup({
    String? groupId,
    DocumentReference? groupDocument,
    required Message message,
  }) async {
    if (groupId != null) {
      try {
        void addMessage() async {
          if (message.userName != null) {
            if (message.message!.trim() != "") {
              DocumentSnapshot doc =
                  await messagesCollection.doc(groupId).get();
              Map data = doc.data() as Map;
              GroupData groupData = GroupData.parse(data);

              List messageData = groupData.messages as List;
              List userNamesData = groupData.users_name as List;
              List timeData = groupData.time_of_messages as List;
              List docsData = groupData.users_doc_references as List;

              messageData.add(message.message);
              userNamesData.add(message.userName);
              print(message.userName);
              timeData.add(message.getTime);
              docsData.add(DataBaseService()
                  .authUsersCollection
                  .doc(message.documentId));
              await messagesCollection.doc(groupId).update({
                "messages": messageData,
                "users_name": userNamesData,
                "time_of_messages": timeData,
                "users_doc_reference": docsData,
              });
            }
          } else {
            return Future.error(MessageException.null_user_name_error);
          }
        }

        addMessage();
      } catch (e) {
        print(e.toString());
        return Future.error(MessageException.add_message_error);
      }
    } else if (groupDocument != null) {
      try {
        void addMessage() async {
          if (message.userName != null) {
            if (message.message!.trim() != "") {
              DocumentSnapshot doc = await groupDocument.get();
              Map data = doc.data() as Map;

              GroupData groupData = GroupData.parse(data);

              List messageData = groupData.messages as List;
              List userNamesData = groupData.users_name as List;
              List timeData = groupData.time_of_messages as List;
              List docsData = groupData.users_doc_references as List;

              messageData.add(message.message);
              userNamesData.add(message.userName);
              print(message.userName);
              timeData.add(message.getTime);
              docsData.add(DataBaseService()
                  .authUsersCollection
                  .doc(message.documentId));
              await groupDocument.update({
                "messages": messageData,
                "users_name": userNamesData,
                "time_of_messages": timeData,
                "users_doc_reference": docsData,
              });
            }
          } else {
            return Future.error(MessageException.null_user_name_error);
          }
        }

        addMessage();
      } catch (e) {
        print(e.toString());
        return Future.error(MessageException.add_message_error);
      }
    }
  }

  Future addVoiceMessage(
      File audioFile, String groupId, VoiceMessage message) async {
    try {
      firebase_storage.Reference _storage = firestorage
          .ref("$groupId/audio_messages/${audioFile.path.split("/").last}");
      firebase_storage.TaskSnapshot uploadTask =
          await _storage.putFile(audioFile);

      String url = await uploadTask.ref.getDownloadURL();
      DocumentReference groupDocument = messagesCollection.doc(groupId);

      DocumentSnapshot doc = await groupDocument.get();
      Map data = doc.data() as Map;
      GroupData groupData = GroupData.parse(data);

      List messageData = groupData.messages as List;
      List userNamesData = groupData.users_name as List;
      List timeData = groupData.time_of_messages as List;
      List docsData = groupData.users_doc_references as List;

      messageData.add({
        "url": url,
        "storage_path": uploadTask.ref.fullPath,
        "duration": message.durationMilliseconds.inMilliseconds
      });
      userNamesData.add(message.userName);
      timeData.add(message.getTime);
      docsData
          .add(DataBaseService().authUsersCollection.doc(message.documentId));

      docsData
          .add(DataBaseService().authUsersCollection.doc(message.documentId));
      await groupDocument.update({
        "messages": messageData,
        "users_name": userNamesData,
        "time_of_messages": timeData,
        "users_doc_reference": docsData,
      });

      return url;
    } catch (e) {
      print(e.toString());
      return Future.error(MessageException.add_voice_error);
    }
  }

  Future addImageOrVideoToGroup(
      File file, String groupId, String imageName, Message message) async {
    try {
      final String fileId = const Uuid().v4();
      bool isvideo = isVideo(file.path);
      firebase_storage.Reference _storage = firestorage.ref(
          "$groupId/${groupId.split("-").first}/${imageName.trim() == ".mp4" || imageName.trim() == ".jpg" || imageName.trim() == ".png" ? (fileId + (isvideo ? ".mp4" : ".jpg")) : imageName}");
      firebase_storage.TaskSnapshot uploadTask = await _storage.putFile(file);

      String url = await uploadTask.ref.getDownloadURL();
      DocumentReference groupDocument = messagesCollection.doc(groupId);

      DocumentSnapshot doc = await groupDocument.get();
      Map data = doc.data() as Map;
      GroupData groupData = GroupData.parse(data);

      List messageData = groupData.messages as List;
      List userNamesData = groupData.users_name as List;
      List timeData = groupData.time_of_messages as List;
      List docsData = groupData.users_doc_references as List;

      messageData.add({"url": url, "storage_path": uploadTask.ref.fullPath});
      userNamesData.add(message.userName);
      timeData.add(message.getTime);
      docsData
          .add(DataBaseService().authUsersCollection.doc(message.documentId));
      await groupDocument.update({
        "messages": messageData,
        "users_name": userNamesData,
        "time_of_messages": timeData,
        "users_doc_reference": docsData,
      });

      return url;
    } catch (e) {
      print(e.toString());
      // return Future.error(e);
      return Future.error(MessageException.add_file_error);
    }
  }

  Future<bool> checkIfChatboxIsOpen(
      {String? fromId, String? toId, String? groupId, List? userGroups}) async {
    assert((fromId != null && toId != null) || groupId != null);
    var messagesChatboxes = await messagesCollection.get();

    if (groupId == null && userGroups == null) {
      return messagesChatboxes.docs.any(
          (element) => element.id == groupId || element.id == "$fromId-$toId");
    } else {
      // will check if any of the groups are already open from the user groups
      return userGroups!.any((userGroup) => userGroup["nadi_id"] == groupId);
    }
  }

  Future removeMessagGroup(
      {DocumentReference? documentReference, String? groupId}) async {
    assert(documentReference != null || groupId != null);
    try {
      final Directory cacheDir = await cache;
      final String cachePath = cacheDir.path;
      final bool videosExist =
          await Directory("$cachePath/${groupId ?? documentReference!.id}")
              .exists();
      if (videosExist) {
        await Directory("$cachePath/${groupId ?? documentReference!.id}")
            .delete(recursive: true);
      }
      await documentReference!.delete();
    } catch (e) {
      print(e.toString());
      return Future.error(MessageException.remove_group_error);
    }
  }
}

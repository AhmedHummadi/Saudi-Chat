import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saudi_chat/models/message.dart';
import 'package:saudi_chat/models/nadi.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceStorage {
  final Future<SharedPreferences> _preferences =
      SharedPreferences.getInstance();

  Future<Message?> getLastReadMessageFromGroup(
      GroupData group, String groupId) async {
    final SharedPreferences preferences = await _preferences;

    final String key = "lastReadMessage" + groupId;

    if (preferences.containsKey(key)) {
      // there is data about the last read message in the storage
      // so now we will send back the value of the last read message
      // for the chat list to show if any new messages are there

      // each index will represent a data in the list for the Message parsing

      // 0 - message
      // 1 - userName
      // 2 - userDocId

      List<String> values = preferences.getStringList(key)!;
      return Message(
          message: values[0], userName: values[1], documentId: values[2]);
    } else {
      return null;
    }
  }

  Future<bool> setLastReadMessageFromGroup(
      {required String message,
      required String userName,
      required String userDocId,
      required String groupDocId}) async {
    final SharedPreferences preferences = await _preferences;

    final String key = "lastReadMessage" + groupDocId;

    // we will set the last message data with the key
    // provided above for chat list

    // each index will represent a data in the list for the Message parsing

    // 0 - message
    // 1 - userName
    // 2 - userDocId

    return await preferences.setStringList(key, [message, userName, userDocId]);
  }

  Future<bool> isLastMessageUnread(
      String groupDocId, Message latestMessage) async {
    // this function will see if the latest message from the group is the last message read by the user
    // if yes then it will return true so that the chat list then show the gradient outline circle
    // to represent that there are unread messages

    final DocumentSnapshot groupDoc =
        await DataBaseService().messagesCollection.doc(groupDocId).get();

    final GroupData data = GroupData.parse(groupDoc.data() as Map);

    final Message? lastReadMessage =
        await getLastReadMessageFromGroup(data, groupDocId);

    if (lastReadMessage != null) {
      return !(latestMessage.message == lastReadMessage.message &&
          latestMessage.userName == lastReadMessage.userName &&
          lastReadMessage.documentId == latestMessage.documentId);
    } else {
      if (groupDoc.get("messages").isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }
  }
}

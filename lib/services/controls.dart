import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/services/database.dart';

class ControlsService {
  Future<void> postNews(Map details) async {
    try {
      DocumentSnapshot nadiDoc =
          await (details["nadiDoc"] as DocumentReference).get();

      CollectionReference newsCollection = nadiDoc.reference.collection("News");

      await newsCollection.doc().set({
        "dateCreated": details["dateCreated"],
        "imageUrl": details["imageUrl"],
        "created_by": details["created_by"],
        "nadi": details["nadi"],
        "nadiDoc": details["nadiDoc"],
        "description": details["description"],
        "title": details["title"],
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> assignAdmin(
      DocumentSnapshot userDoc, DocumentSnapshot groupDoc) async {
    try {
      // we will get first go into the groupDoc's Admin collection
      // and add the userDoc there with any additional info
      // then we will go to the usersDoc and change the
      // groupAdmin to the group document

      // if he is already an admin/moderator
      if (userDoc.get("groupAdmin") != null) {
        Fluttertoast.showToast(msg: "User is already Admin");
        return false;
      }

      // if he is not a member in the group yet
      if ((await groupDoc.reference
              .collection("members")
              .where("doc_reference", isEqualTo: userDoc.reference)
              .get())
          .docs
          .isEmpty) {
        Fluttertoast.showToast(msg: "User is not a member in the group");
        return false;
      }

      // if he is a moderator and can't be admin
      if (userDoc.get("userClass") == "moderator") {
        Fluttertoast.showToast(msg: "User is a moderator and can't be admin");
        return false;
      }

      // add the doc into the admins collection
      await groupDoc.reference.collection("admins").doc(userDoc.id).set(
          userDoc.data() as Map<String, dynamic>
            ..addAll({"doc_reference": userDoc.reference}));

      // update the userClass in the user doc in the members collection

      DocumentReference userDocInGroup =
          groupDoc.reference.collection("members").doc(userDoc.id);

      DocumentSnapshot userGroupDocumentSnapshot = await userDocInGroup.get();

      if (userGroupDocumentSnapshot.get("userClass") == "moderator") {
        Fluttertoast.showToast(msg: "User is a moderator and can't be admin");
        return false;
      }

      userDocInGroup.update({"userClass": "admin"});

      userDoc.reference
          .update({"groupAdmin": groupDoc.reference, "userClass": "admin"});
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> assignModerator(DocumentSnapshot userDoc) async {
    try {
      if (userDoc.get("groupAdmin") != null) {
        Fluttertoast.showToast(msg: "User is an Admin and can't be Moderator");
        return false;
      }

      if (userDoc.get("userClass") == "moderator") {
        Fluttertoast.showToast(msg: "User is already a Moderator");
        return false;
      }

      await userDoc.reference.update({"userClass": "moderator"});
      List userGroups = userDoc.get("groups") as List;

      for (var group in userGroups) {
        DocumentReference ref =
            DataBaseService().messagesCollection.doc(group["nadiReference"].id);

        QuerySnapshot snapshot = await ref.collection("members").get();
        DocumentSnapshot userDocInGroup =
            snapshot.docs.where((element) => element.id == userDoc.id).single;
        userDocInGroup.reference.update({"userClass": "moderator"});
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }

  FutureOr<bool> demoteUser(DocumentSnapshot userDoc, UserClass userClass,
      UserAuth streamedUser) async {
    if (userDoc.id == streamedUser.uid) {
      Fluttertoast.showToast(msg: "You cannot demote yourself");
      return false;
    }

    // check if they are already the class that they will be demoted to
    if (userDoc.get("userClass") == userClass.name) {
      Fluttertoast.showToast(msg: "User is already ${userClass.name}");
      return false;
    }

    // check if they are the lowest rank (user)
    if (userDoc.get("userClass") == "user") {
      Fluttertoast.showToast(msg: "User is a user, cannot demote further");
      return false;
    }

    if (UserAuth.checkIfClassIsLower(
        targetClass: UserAuth.parseUserClass(userDoc.get("userClass")),
        rank: userClass.toString())) {
      Fluttertoast.showToast(msg: "Class is higher than current user class");
      return false;
    }

    if (userDoc.get("userClass") == "moderator" &&
        (userClass == UserClass.admin || userClass == UserClass.coAdmin)) {
      Fluttertoast.showToast(
          msg:
              "Cannot demote to admin/coAdmin without a group to administrate");
      return false;
    }

    await userDoc.reference.update({"userClass": userClass.name});

    List userGroups = userDoc.get("groups") as List;

    for (var group in userGroups) {
      DocumentReference ref =
          DataBaseService().messagesCollection.doc(group["nadiReference"].id);

      QuerySnapshot snapshot = await ref.collection("members").get();
      DocumentSnapshot userDocInGroup =
          snapshot.docs.where((element) => element.id == userDoc.id).single;
      userDocInGroup.reference.update({"userClass": userClass.name});
    }

    return true;
  }
}

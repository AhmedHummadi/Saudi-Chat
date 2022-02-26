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

      List newsData = nadiDoc.get("news");

      // then add what we want to it
      newsData.add(details);

      // then update the existing list in the document with the updated list
      await nadiDoc.reference.update({"news": newsData});
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> assignAdmin(
      DocumentSnapshot userDoc, DocumentSnapshot groupDoc) async {
    try {
      // we will get first go into the groupDoc's Admin collection
      // and add the userDoc there with any additional info
      // then we will go to the usersDoc and then add the group
      // document reference in the groupAdmins list

      // if he is already an admin/moderator
      if (((userDoc.get("groupsAdmin") as List).contains(groupDoc.reference))) {
        Fluttertoast.showToast(msg: "User is already admin");
        return false;
      }

      // if he is not a member in the group yet
      if (!(await groupDoc.reference.collection("members").get())
          .docs
          .any((element) => element.id == userDoc.id)) {
        Fluttertoast.showToast(msg: "User is not a member in the group");
        return false;
      }

      // if he is a moderator and can't be admin
      if (userDoc.get("userClass") == "moderator") {
        Fluttertoast.showToast(msg: "User is an moderator and can't be admin");
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
      List groupsAdmin = userDoc.get("groupsAdmin") as List;
      groupsAdmin.add(groupDoc.reference);

      userDoc.reference
          .update({"groupsAdmin": groupsAdmin, "userClass": "admin"});
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> assignModerator(DocumentSnapshot userDoc) async {
    try {
      if ((userDoc.get("groupsAdmin") as List).isNotEmpty) {
        Fluttertoast.showToast(msg: "User is an Admin and can't be moderator");
        return false;
      }

      if (userDoc.get("userClass") == "moderator") {
        Fluttertoast.showToast(msg: "User is already a moderator");
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

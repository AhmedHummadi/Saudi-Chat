// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:saudi_chat/models/location.dart';
import 'package:saudi_chat/models/nadi.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum DataBaseServiceException {
  create_user_data_exception,
  get_business_search_results_exception,
  delete_user_document_exception,
  add_user_to_group_error
}

class DataBaseService {
  late final String? uid;

  DataBaseService({this.uid});

  // collection reference

  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection("Groups");

  final CollectionReference authUsersCollection =
      FirebaseFirestore.instance.collection("Users");

  final CollectionReference nadiCollection =
      FirebaseFirestore.instance.collection("Nadis");

  QuerySnapshot? nadiQuerySnapshot;

  // userdata from snapshot
  UserAuth _userAuthFromDocSnapshot(DocumentSnapshot snapshot) {
    return UserAuth(
        uid: uid ?? snapshot.id,
        cities: snapshot.get("cities"),
        groups: snapshot.get("groups"),
        groupsAdmin: snapshot.get("groupsAdmin"),
        userClass: UserAuth.parseUserClass(snapshot.get("userClass")),
        email: snapshot.get("email"),
        isAnonymous: snapshot.get("isAnonymous"),

        // creationTime: DateTime.parse(snapshot.get("creationTime").toString()),
        // lastSignInTime: DateTime.parse(snapshot.get("lastSignInTime").toString()),
        phoneNum: snapshot.get("phoneNum"),
        displayName: snapshot.get("name"));
  }

  // ignore: unused_element
  NadiData nadiDataFromDoc(
      {QueryDocumentSnapshot? snapshot, DocumentSnapshot? documentSnapshot}) {
    assert(snapshot != null || documentSnapshot != null);
    if (snapshot != null) {
      return NadiData(
        phoneNum: snapshot.get("phoneNum"),
        location: snapshot.get("location"),
        nadiName: snapshot.get("name"),
        id: snapshot.id,
        email: snapshot.get("email"),
      );
    } else {
      return NadiData(
        phoneNum: documentSnapshot!.get("phoneNum"),
        location: documentSnapshot.get("location"),
        nadiName: documentSnapshot.get("name"),
        id: documentSnapshot.id,
        email: documentSnapshot.get("email"),
      );
    }
  }

  // user auth Stream
  Stream<UserAuth> get userAuthStream {
    return authUsersCollection
        .doc(uid)
        .snapshots()
        .map(_userAuthFromDocSnapshot);
  }

  // stream of message collection
  Stream<QuerySnapshot> get messageStream => messagesCollection.snapshots();

  Future searchUsersByEmail(StreamController streamController, String input,
      QuerySnapshot userDocuments) async {
    try {
      streamController.sink.add(ConnectionState.waiting);

      List<QueryDocumentSnapshot> matchingDocs = userDocuments.docs
          .where((doc) => checkForInputMatchStartOnly(
              input: input, name: doc.get("email").toString()))
          .toList();
      if (matchingDocs.isEmpty) {
        streamController.sink.add([]);
        return;
      } else {
        streamController.sink.add(matchingDocs);
        return;
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "an unknown error has occured");
    }
  }

  Future searchGroupsByName(StreamController streamController, String input,
      QuerySnapshot groupDocuments) async {
    try {
      streamController.sink.add(ConnectionState.waiting);

      List<QueryDocumentSnapshot> matchingDocs =
          groupDocuments.docs.where((doc) {
        return checkForInputMatch(
            input: input, name: doc.get("nadi_data")["name"].toString());
      }).toList();
      if (matchingDocs.isEmpty) {
        streamController.sink.add([]);
        return;
      } else {
        streamController.sink.add(matchingDocs);
        return;
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "an unknown error has occured");
    }
  }

  Future addUserToNadiGroup(user, groupId) async {
    // this function will add the user to the group
    // when he searches for a group from the search bar
    // and then presses it it will add him in the members
    // collection in the groups document by his id then add all
    // the required data in it

    DocumentSnapshot groupDocument =
        await messagesCollection.doc(groupId).get();

    // first we add the user to the groups members data

    Future addUserToGroup() async {
      DocumentReference membersData =
          groupDocument.reference.collection("members").doc(user.uid);

      membersData.set({
        "name": user.displayName,
        "email": user.email,
        "cities": user.cities,
        "userClass": "user",
        "phoneNum": user.phoneNum,
        "creationTime": user.creationTime,
        "lastSignInTime": user.lastSignInTime,
        "doc_reference": DataBaseService().authUsersCollection.doc(user.uid)
      });
    }

    // then we add the group to the users group list
    Future addGroupToUserList() async {
      DocumentSnapshot userDoc =
          await DataBaseService().authUsersCollection.doc(user.uid).get();
      List groupsData = userDoc.get("groups");

      Map data = {
        "nadi_id": groupDocument.id,
        "nadiReference": nadiCollection.doc(groupDocument.id)
      };
      data.addAll(groupDocument.get("nadi_data") as Map<dynamic, dynamic>);
      // ignore: unnecessary_cast
      groupsData.add(data);

      await userDoc.reference.update({
        "groups": groupsData,
      });
    }

    // we call both function for the user to successfully enter the group
    await addUserToGroup();
    await addGroupToUserList();
    return groupDocument.reference;
  }

  Future<bool> removeUserFromGroup(
      {required UserAuth streamedUser, required NadiData nadi}) async {
    DocumentReference usersDocument = authUsersCollection.doc(streamedUser.uid);

    DocumentReference groupDocument = messagesCollection.doc(nadi.id);
    try {
      /// We want to first remove the group from the users groups
      /// list so that it updates everything that the viewer sees
      /// in the app. [removeGroupFromUsersJoinedGroups()]
      /// Then we want to delete the users document from the members
      /// collection in the groups document

      Future removeGroupFromUsersJoinedGroups() async {
        // First we will get the groups list
        List updatedGroupList = streamedUser.groups!
          ..removeWhere((item) => item["nadi_id"] == nadi.id);

        // Then we will update the user document
        return await usersDocument.update({"groups": updatedGroupList});
      }

      Future kickUserFromGroupsMembersList() async {
        //?? This will not remove the users messages from the group

        // We will simply get a reference to the users document in the members collection then delete it
        CollectionReference membersCollectionReference =
            groupDocument.collection("members");

        return await membersCollectionReference.doc(streamedUser.uid).delete();
      }

      await removeGroupFromUsersJoinedGroups();
      await kickUserFromGroupsMembersList();
    } catch (e) {
      print(e);
    }
    if ((await groupDocument
            .collection("members")
            .where("doc_reference", isEqualTo: usersDocument)
            .get())
        .docs
        .isNotEmpty) {
      // If the document still exists then return false
      return false;
    } else {
      return true;
    }
  }

  // update user auth data
  Future createUserAuthData({UserAuth? userAuth}) async {
    try {
      final DocumentReference userDoc =
          authUsersCollection.doc(userAuth!.uid ?? uid);
      await userDoc.set({
        "name": userAuth.displayName,
        "email": userAuth.email,
        "isAnonymous": userAuth.isAnonymous,
        "userClass": "user",
        "groups": [],
        "cities": userAuth.cities,
        "phoneNum": userAuth.phoneNum,
        "groupsAdmin": [],
        "creationTime": userAuth.creationTime,
        "lastSignInTime": userAuth.lastSignInTime
      });
      return await messagesCollection.get().then((collection) async {
        List<QueryDocumentSnapshot> filteredGorups = collection.docs
            .where((groups) => userAuth.cities!
                .any((city) => groups.get("nadi_data")["location"] == city))
            .toList();
        for (var group in filteredGorups) {
          // for each message group that matches the users cities preferences

          Future addGroupToUserDoc() async {
            var userDoc = await authUsersCollection.doc(userAuth.uid).get();

            // get the groups list
            List groupsData = userDoc.get("groups");

            // make a map then add the id of the group then add the nadi data in it
            Map data = {
              "nadi_id": group.id,
              "nadiReference": nadiCollection.doc(group.id)
            };
            data.addAll((group.data() as Map<dynamic, dynamic>)["nadi_data"]);

            // add the data to the users group data
            // ignore: unnecessary_cast
            groupsData.add(data);

            // and finally update it
            await userDoc.reference.update({
              "groups": groupsData,
            });
          }

          Future addUserToGroupMembers() async {
            DocumentReference membersData =
                group.reference.collection("members").doc(userAuth.uid);

            membersData.set({
              "name": userAuth.displayName,
              "email": userAuth.email,
              "cities": userAuth.cities,
              "userClass": "user",
              "phoneNum": userAuth.phoneNum,
              "creationTime": userAuth.creationTime,
              "lastSignInTime": userAuth.lastSignInTime,
              "doc_reference":
                  DataBaseService().authUsersCollection.doc(userAuth.uid)
            });
          }

          await addGroupToUserDoc();
          await addUserToGroupMembers();
        }
      });
    } catch (e) {
      print(e.toString());
      return Future.error(DataBaseServiceException.create_user_data_exception);
    }
  }

  bool checkForInputMatchStartOnly(
      {required String input, required String name}) {
    // this is the algorithm that will be used to give the results of
    // the search, it takes the input and the nadi name and does all these
    // bool expressions to see if the input should match the name and give
    // the nadi as the result of the searchz

    return name.startsWith(input) ||
        name == input ||
        name.toLowerCase() == input ||
        name.toLowerCase() == input.toLowerCase() ||
        name.trim() == input ||
        name.startsWith(input.toLowerCase()) ||
        name.startsWith(input) ||
        name.startsWith(input.trim()) ||
        name.startsWith(input.trim().toLowerCase()) ||
        name.toLowerCase().startsWith(input.toLowerCase()) ||
        input.startsWith(name) ||
        input.toLowerCase() == name ||
        input.trim() == name ||
        input.trim() == name.trim();
  }

  bool checkForInputMatch({
    required String input,
    required String name,
    List? businessCatagories,
  }) {
    // this is the algorithm that will be used to give the results of
    // the search, it takes the input and the nadi name and does all these
    // bool expressions to see if the input should match the name and give
    // the nadi as the result of the searchz

    bool normalCheck = name.contains(input) ||
        name == input ||
        name.toLowerCase() == input ||
        name.toLowerCase() == input.toLowerCase() ||
        name.trim() == input ||
        name.contains(input.toLowerCase()) ||
        name.contains(input) ||
        name.contains(input.trim()) ||
        name.contains(input.trim().toLowerCase()) ||
        name.toLowerCase().contains(input.toLowerCase()) ||
        name.startsWith(input) ||
        input.contains(name) ||
        input.startsWith(name) ||
        input.toLowerCase() == name ||
        input.trim() == name ||
        input.trim() == name.trim();
    if (businessCatagories == null) {
      if (input.contains(" in ")) {
        var inNameInput = input.split(" in ").first;
        return name.contains(inNameInput) ||
            name == inNameInput ||
            name.toLowerCase() == inNameInput ||
            name.toLowerCase() == inNameInput.toLowerCase() ||
            name.trim() == inNameInput ||
            name.contains(inNameInput.toLowerCase()) ||
            name.contains(inNameInput) ||
            name.contains(inNameInput.trim()) ||
            name.contains(inNameInput.trim().toLowerCase()) ||
            name.toLowerCase().contains(inNameInput.toLowerCase()) ||
            name.endsWith(inNameInput) ||
            name.startsWith(inNameInput) ||
            inNameInput.contains(name) ||
            inNameInput.endsWith(name) ||
            inNameInput.startsWith(name) ||
            inNameInput.toLowerCase() == name ||
            inNameInput.trim() == name ||
            inNameInput.trim() == name.trim();
      } else {
        return normalCheck;
      }
    } else {
      if (input.contains(" in ")) {
        var inNameInput = input.split(" in ").first;
        return name.contains(inNameInput) ||
            name == inNameInput ||
            name.toLowerCase() == inNameInput ||
            name.toLowerCase() == inNameInput.toLowerCase() ||
            name.trim() == inNameInput ||
            name.contains(inNameInput.toLowerCase()) ||
            name.contains(inNameInput) ||
            name.contains(inNameInput.trim()) ||
            name.contains(inNameInput.trim().toLowerCase()) ||
            name.toLowerCase().contains(inNameInput.toLowerCase()) ||
            name.endsWith(inNameInput) ||
            name.startsWith(inNameInput) ||
            inNameInput.contains(name) ||
            inNameInput.endsWith(name) ||
            inNameInput.startsWith(name) ||
            inNameInput.toLowerCase() == name ||
            inNameInput.trim() == name ||
            inNameInput.trim() == name.trim() ||
            businessCatagories.any((element) => element == inNameInput) ||
            businessCatagories.any(
                (element) => element.toString().toLowerCase() == inNameInput) ||
            businessCatagories.any((element) =>
                element.toString().toLowerCase() ==
                inNameInput.toLowerCase()) ||
            businessCatagories.any(
                (element) => element.toString() == inNameInput.toLowerCase()) ||
            businessCatagories
                .any((element) => element == inNameInput.trim()) ||
            businessCatagories.any((element) =>
                element.toString().toLowerCase() == inNameInput.trim()) ||
            businessCatagories.any((element) =>
                element.toString().toLowerCase() ==
                inNameInput.trim().toLowerCase()) ||
            businessCatagories.any((element) =>
                element.toString() == inNameInput.trim().toLowerCase());
      } else {
        return normalCheck ||
            businessCatagories.any((element) => element == input) ||
            businessCatagories
                .any((element) => element.toString().toLowerCase() == input) ||
            businessCatagories.any((element) =>
                element.toString().toLowerCase() == input.toLowerCase()) ||
            businessCatagories
                .any((element) => element.toString() == input.toLowerCase()) ||
            businessCatagories.any((element) => element == input.trim()) ||
            businessCatagories.any((element) =>
                element.toString().toLowerCase() == input.trim()) ||
            businessCatagories.any((element) =>
                element.toString().toLowerCase() ==
                input.trim().toLowerCase()) ||
            businessCatagories.any(
                (element) => element.toString() == input.trim().toLowerCase());
      }
    }
  }

  bool checkForFilterCatagoryMatch(
      String input, Map filters, List businessCatagories) {
    if (filters["catagories"].isEmpty || filters["catagories"] == null) {
      return true;
    } else {
      return filters["catagories"]
          .any((element) => businessCatagories.contains(element));
    }
  }

  bool checkForInLocationMatch(String input, MyLocation location, String name) {
    if (input.contains(" in ")) {
      String inputLocation = input.split(" in ").last;
      List locationVals = [
        location.administrativeArea,
        location.country,
        location.county,
        location.region,
        location.regionCode,
        location.locality
      ];
      return locationVals.any((location) =>
          location == inputLocation ||
          location.toLowerCase() == inputLocation ||
          location.toLowerCase() == inputLocation.toLowerCase() ||
          location.trim() == inputLocation ||
          location.endsWith(inputLocation) ||
          location.startsWith(inputLocation) ||
          location.toLowerCase().startsWith(inputLocation) ||
          location.toLowerCase().startsWith(inputLocation.toLowerCase()) ||
          location.startsWith(inputLocation.toLowerCase()) ||
          inputLocation.endsWith(location) ||
          inputLocation.startsWith(location) ||
          inputLocation.toLowerCase() == location ||
          inputLocation.trim() == location ||
          inputLocation.trim() == location.trim());
    } else {
      return true;
    }
  }

  // search in bussiness data collection
  Future<List<DocumentSnapshot>?> getSearchResultsFromBusinesses(
      {required String queryText, MyLocation? userLocation}) async {
    try {
      if (nadiQuerySnapshot == null) {
        await nadiCollection.get().then((value) => nadiQuerySnapshot = value);
      }
      List<DocumentSnapshot> searchResults = [];
      // ignore: avoid_function_literals_in_foreach_calls
      nadiQuerySnapshot!.docs.forEach((doc) {
        String bussinessName = doc.get("name").toString();

        if (checkForInputMatch(input: queryText, name: bussinessName)) {
          searchResults.add(doc);
        }
      });
      // ignore: unnecessary_null_comparison

      if (userLocation != null) {
        searchResults.sort((doc1, doc2) {
          Map doc1Location = doc1.get("location");
          Map doc2Location = doc2.get("location");
          return Geolocator.distanceBetween(
                  userLocation.latitude!.toDouble(),
                  userLocation.longitude!.toDouble(),
                  doc1Location["latitude"].toDouble(),
                  doc1Location["longitude"].toDouble())
              .compareTo(Geolocator.distanceBetween(
                  userLocation.latitude!.toDouble(),
                  userLocation.longitude!.toDouble(),
                  doc2Location["latitude"].toDouble(),
                  doc2Location["longitude"]!.toDouble()));
        });
      } else {
        Position? lastKnownPosition =
            await Geolocator.getLastKnownPosition().catchError((error) => null);
        if (lastKnownPosition != null) {
          searchResults.sort((doc1, doc2) {
            Map doc1Location = doc1.get("location");
            Map doc2Location = doc2.get("location");
            return Geolocator.distanceBetween(
                    lastKnownPosition.latitude.toDouble(),
                    lastKnownPosition.longitude.toDouble(),
                    doc1Location["latitude"].toDouble(),
                    doc1Location["longitude"].toDouble())
                .compareTo(Geolocator.distanceBetween(
                    lastKnownPosition.latitude.toDouble(),
                    lastKnownPosition.longitude.toDouble(),
                    doc2Location["latitude"].toDouble(),
                    doc2Location["longitude"]!.toDouble()));
          });
        }
      }

      return searchResults;
    } catch (e) {
      print(e.toString());
      return Future.error(
          DataBaseServiceException.get_business_search_results_exception);
    }
  }

  // delete user document
  Future deleteUserDocument() async {
    try {
      return await authUsersCollection.doc(uid).delete();
    } catch (e) {
      print(e.toString());
      return Future.error(
          DataBaseServiceException.delete_user_document_exception);
    }
  }
}

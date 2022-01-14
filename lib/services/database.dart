// ignore_for_file: constant_identifier_names

import 'dart:async';
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
        nadiAdminDoc: snapshot.get("nadiAdminDoc"),
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

  Future addUserToNadiGroup(user, groupId) async {
    // this function will add the user to the group
    // when he searches for a group from the search bar
    // and then presses it it will add him in the members
    // list from the group and add the group to the groups
    // list in the user document
    DocumentSnapshot groupDocument =
        await messagesCollection.doc(groupId).get();

    // first we add the user to the groups members data

    Future addUserToGroup() async {
      // first will get the list
      List membersData = groupDocument.get("members");

      // then add what we want to it
      membersData.add({
        "name": user.displayName,
        "email": user.email,
        "cities": user.cities,
        "phoneNum": user.phoneNum,
        "creationTime": user.creationTime,
        "lastSignInTime": user.lastSignInTime,
        "doc_reference": DataBaseService().authUsersCollection.doc(user.uid)
      });

      // then update the existing list in the document with the updated list
      await groupDocument.reference.update({"members": membersData});
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

  Future createNadiData(NadiData nadiData) async {
    try {
      var nadiDoc = nadiCollection.doc();
      await nadiDoc.set({
        "location": nadiData.location,
        "name": nadiData.nadiName,
        "phoneNum": nadiData.phoneNum,
        "email": nadiData.email
      });
      await messagesCollection.doc(nadiDoc.id).set({
        "nadi_data": {
          "location": nadiData.location,
          "name": nadiData.nadiName,
          "phoneNum": nadiData.phoneNum,
          "email": nadiData.email
        },
        "messages": [],
        "time_of_messages": [],
        "users_name": [],
        "users_doc_reference": [],
      });
    } catch (e) {
      rethrow; // TODO: Test
    }
  }

  // update user auth data
  Future createUserAuthData({UserAuth? userAuth}) async {
    try {
      await authUsersCollection.doc(userAuth!.uid ?? uid).set({
        "name": userAuth.displayName,
        "email": userAuth.email,
        "isAnonymous": userAuth.isAnonymous,
        "groups": [],
        "cities": userAuth.cities,
        "phoneNum": userAuth.phoneNum,
        "nadiAdminDoc": null,
        "creationTime": userAuth.creationTime,
        "lastSignInTime": userAuth.lastSignInTime
      });
      return await messagesCollection.get().then((collection) {
        collection.docs
            .where((doc) => userAuth.cities!
                .any((city) => doc.get("nadi_data")["location"] == city))
            .forEach((group) async {
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
            List membersData = group["members"] as List;

            membersData.add({
              "name": userAuth.displayName,
              "email": userAuth.email,
              "isAdmin": userAuth.nadiAdminDoc != null,
              "cities": userAuth.cities,
              "phoneNum": userAuth.phoneNum,
              "creationTime": userAuth.creationTime,
              "lastSignInTime": userAuth.lastSignInTime,
              "doc_reference": authUsersCollection.doc(userAuth.uid)
            });
            await group.reference.update({"members": membersData});
          }

          await addGroupToUserDoc();
          await addUserToGroupMembers();
        });
      });
    } catch (e) {
      print(e.toString());
      return Future.error(DataBaseServiceException.create_user_data_exception);
    }
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
        name.endsWith(input) ||
        name.startsWith(input) ||
        input.contains(name) ||
        input.endsWith(name) ||
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
        Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
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

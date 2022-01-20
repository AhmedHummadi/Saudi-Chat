import 'dart:async';

import 'package:saudi_chat/models/nadi.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/chat/chat_page.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  final dynamic streamedUser;
  const ChatList({Key? key, required this.streamedUser}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  List<Widget> widgetsList = [];
  List<String> listOfPopUpItems = ["End Chat"];

  @override
  Widget build(BuildContext context) {
    // the auth data about the user
    dynamic streamedUser = Provider.of<UserAuth>(context);
    return StreamBuilder<QuerySnapshot>(
        stream: DataBaseService().messageStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (streamedUser.cities != null) {
              //buildNadiData(snapshot.data!, streamedUser);
              // condition helps to not redo finddocuments() and
              // build the tree multiple times
              if (snapshot.data!.docs.where((element) {
                    // Map data = element.data() as Map;
                    List groups = (streamedUser.groups as List).map((group) {
                      return group["nadi_id"];
                    }).toList();
                    return groups.contains(element.id);
                  }).length !=
                  widgetsList.length) {
                findDocuments(snapshot.data, streamedUser, (widgets) {
                  setState(() {
                    widgetsList = widgets;
                  });
                });
              }
            }

            return SingleChildScrollView(
              child:
                  Column(mainAxisSize: MainAxisSize.max, children: widgetsList),
            );
          } else {
            return const Center(
              child: Text("Loading..."),
            );
          }
        });
  }

  Widget buildItem(
      {required BuildContext context,
      required NadiData data,
      required DocumentReference bussinessDoc,
      required dynamic streamedUser,
      required DocumentReference documentReference}) {
    return GestureDetector(
      onTap: () async {
        await onItemTap(streamedUser, documentReference, bussinessDoc);
      },
      child: Column(
        children: [
          SizedBox(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: Image.asset(
                    "assets/new_nadi_profile_pic.jpg",
                  ).image,
                ),
                title: Text(
                  data.nadiName!,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          const Divider(
            indent: 1,
            endIndent: 1,
            thickness: 0.8,
            height: 0,
            color: Colors.grey,
          )
        ],
      ),
    );
  }

  /*void buildNadiData(QuerySnapshot<Object?> nadiData, streamedUser) async {
    print("In Build Nadi Data");
    List<NadiData> nadisThatDontExist = nadis;
    nadiData.docs.map((messageDoc) {
      nadisThatDontExist.removeWhere(
          ((nadi) => !(nadi.nadiName == messageDoc["nadi_data"]["name"])));
    });
    for (var element in nadisThatDontExist) {
      print(element.nadiName);
      await DataBaseService().createNadiData(element);
    }
  }*/

  void findDocuments(QuerySnapshot<Object?>? nadiMessageData, streamedUser,
      Function(List<Widget> widgets) fun) async {
    List<Widget> widgets = [];
    if (nadiMessageData != null && nadiMessageData.docs.isNotEmpty) {
      widgets = [];
      List<QueryDocumentSnapshot> documentsList = nadiMessageData.docs;
      // ignore: avoid_function_literals_in_foreach_calls
      documentsList.forEach((nadiMessageDoc) async {
        List groups =
            (streamedUser.groups as List).map((e) => e["nadi_id"]).toList();
        if (groups.contains(nadiMessageDoc.id)) {
          String merchantId = nadiMessageDoc.id;
          DocumentReference bussinessDoc =
              DataBaseService().nadiCollection.doc(merchantId);
          DocumentSnapshot doc = await bussinessDoc.get();

          NadiData docData =
              DataBaseService().nadiDataFromDoc(documentSnapshot: doc);
          widgets.add(buildItem(
              context: context,
              data: docData,
              streamedUser: streamedUser,
              bussinessDoc: bussinessDoc,
              documentReference: nadiMessageDoc.reference));

          fun(widgets);
        }
      });
    }
  }

  Future onItemTap(dynamic streamedUser, DocumentReference doc,
      DocumentReference bussinessDoc) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatPage(
          groupDocument: doc,
          bussinessDoc: bussinessDoc,
          streamedUser: streamedUser);
    }));
  }

  Widget buildNoOpenChatBoxes(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      child: Text("No Open Chat Boxes"),
    );
  }
}

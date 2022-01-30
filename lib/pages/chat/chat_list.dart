import 'dart:async';

import 'package:saudi_chat/models/message.dart';
import 'package:saudi_chat/models/nadi.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/chat/chat_page.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/services/device_storage.dart';

class ChatList extends StatefulWidget {
  final bool? isHomeStyle;
  const ChatList({Key? key, this.isHomeStyle}) : super(key: key);

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

              List<DocumentSnapshot> docs =
                  snapshot.data!.docs.where((element) {
                // Map data = element.data() as Map;
                List groups = (streamedUser.groups as List).map((group) {
                  return group["nadi_id"];
                }).toList();
                return groups.contains(element.id);
              }).toList();
              if (docs.length != widgetsList.length) {
                findDocuments(docs, snapshot.data, streamedUser, (widgets) {
                  setState(() {
                    widgetsList = widgets;
                  });
                });
              }
            }

            return widget.isHomeStyle == true
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widgetsList),
                  )
                : SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.max, children: widgetsList),
                  );
          } else {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  "Loading...",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w500),
                ),
              ),
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
                  radius: 28,
                  backgroundImage: Image.asset(
                    "assets/new_nadi_profile_pic.jpg",
                  ).image,
                ),
                title: Text(
                  data.nadiName!,
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: Colors.black),
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey[700],
            thickness: 0.7,
            height: 10,
          )
        ],
      ),
    );
  }

  // this is the function that will build all the widgets
  // that will be used to view the groups in the home page
  // Horizontal style
  Widget buildHomeItem(
      {required BuildContext context,
      required NadiData data,
      required bool unreadMessages,
      required DocumentReference groupDoc,
      required dynamic streamedUser,
      required DocumentReference documentReference}) {
    List<Color> gradientColors = unreadMessages == true
        ? [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.surface
          ]
        : [Colors.grey.shade200, Colors.grey.shade400];

    const double kContainerRadius = 82;

    const double kBorderThickness = 2;

    final kGradientBoxDecoration = BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        shape: BoxShape.circle);

    return GestureDetector(
      onTap: () async {
        await onItemTap(streamedUser, documentReference, groupDoc);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 0, 4),
        child: Column(
          children: [
            Container(
              decoration: kGradientBoxDecoration,
              height: kContainerRadius,
              padding: const EdgeInsets.all(kBorderThickness),
              child: Container(
                height: kContainerRadius - (kBorderThickness + 2),
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: Image.asset(
                    "assets/new_nadi_profile_pic.jpg",
                  ).image,
                ),
              ),
            ),
            SizedBox(
              width: kContainerRadius,
              height: 14,
              child: Center(
                child: Text(
                  data.nadiName!,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void findDocuments(
      List<DocumentSnapshot> docs,
      QuerySnapshot<Object?>? nadiMessageData,
      streamedUser,
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

          widgets.add(widget.isHomeStyle == true
              ? buildHomeItem(
                  context: context,
                  data: docData,
                  unreadMessages: await DeviceStorage()
                      .isLastMessageUnread(bussinessDoc.id),
                  streamedUser: streamedUser,
                  groupDoc: bussinessDoc,
                  documentReference: nadiMessageDoc.reference)
              : buildItem(
                  context: context,
                  data: docData,
                  streamedUser: streamedUser,
                  bussinessDoc: bussinessDoc,
                  documentReference: nadiMessageDoc.reference));

          if (widget.isHomeStyle == false) {
            widgets.insert(
                0,
                const SizedBox(
                  height: 10,
                ));
          }

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

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // the auth data about the user
    dynamic streamedUser = Provider.of<UserAuth>(context);
    return FutureBuilder(
        future: DataBaseService().messagesCollection.get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (streamedUser.cities != null) {
              //buildNadiData(snapshot.data!, streamedUser);
              // condition helps to not redo finddocuments() and
              // build the tree multiple times

              // get all the docs for the chat list
              List<DocumentSnapshot> docs =
                  (snapshot.data! as QuerySnapshot).docs.where((element) {
                // Map data = element.data() as Map;
                List groups = (streamedUser.groups as List).map((group) {
                  return group["nadi_id"];
                }).toList();
                return groups.contains(element.id);
              }).toList();

              if (docs.length != widgetsList.length) {
                findDocuments(
                    docs, (snapshot.data as QuerySnapshot), streamedUser,
                    (widgets) {
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
        await onItemTap(context, streamedUser, documentReference, bussinessDoc);
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
              ? _BuildHomeItem(
                  context: context,
                  data: docData,
                  streamedUser: streamedUser,
                  nadiDoc: bussinessDoc,
                  groupDoc: nadiMessageDoc.reference,
                )
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

  Widget buildNoOpenChatBoxes(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      child: Text("No Open Chat Boxes"),
    );
  }
}

// ignore: unused_element

class _BuildHomeItem extends StatelessWidget {
  final BuildContext context;
  final NadiData data;
  final DocumentReference nadiDoc;
  final dynamic streamedUser;
  final DocumentReference groupDoc;

  _BuildHomeItem({
    Key? key,
    required this.context,
    required this.data,
    required this.nadiDoc,
    required this.streamedUser,
    required this.groupDoc,
  }) : super(key: key);

  final StreamController unreadMessageBoolsController = StreamController();

  @override
  Widget build(BuildContext context) {
    const double kContainerRadius = 82;

    const double kBorderThickness = 2;

    return StreamBuilder<DocumentSnapshot>(
      stream: groupDoc.snapshots(),
      builder: (context, snapshot) {
        // this subscription will keep getting the latest message
        // from the group snapshots stream, if the latest message is not the last read message
        // then it will send the data down the unreadMessage sink and update what the user sees

        if (snapshot.hasData) {
          final GroupData groupData =
              GroupData.parse(snapshot.data!.data() as Map);

          final Message latestMessage = Message(
              message: groupData.messages!.last,
              userName: groupData.users_name!.last,
              documentId: groupData.users_doc_references!.last.id);

          DeviceStorage()
              .isLastMessageUnread(nadiDoc.id, latestMessage)
              .then((isUnread) {
            unreadMessageBoolsController.sink.add(isUnread);
          });
        }

        return StreamBuilder(
            stream: unreadMessageBoolsController.stream,
            builder: (context, snapshot) {
              return GestureDetector(
                onTap: () async {
                  await onItemTap(context, streamedUser, groupDoc, nadiDoc);
                  unreadMessageBoolsController.sink.add(false);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 0, 4),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 500),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: snapshot.data != null &&
                                        snapshot.data == true
                                    ? [
                                        Theme.of(context).colorScheme.secondary,
                                        Theme.of(context).primaryColor
                                      ]
                                    : [
                                        Colors.grey.shade200,
                                        Colors.grey.shade400
                                      ]),
                            shape: BoxShape.circle),
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
                                .copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
      },
    );
  }
}

Future onItemTap(BuildContext context, dynamic streamedUser,
    DocumentReference doc, DocumentReference bussinessDoc) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return ChatPage(
        groupDocument: doc,
        bussinessDoc: bussinessDoc,
        streamedUser: streamedUser);
  }));
}

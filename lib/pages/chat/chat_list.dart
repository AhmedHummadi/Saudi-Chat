import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:saudi_chat/models/message.dart';
import 'package:saudi_chat/models/nadi.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/chat/chat_page.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/services/device_storage.dart';
import 'package:saudi_chat/shared/widgets.dart';

class ChatList extends StatefulWidget {
  final bool? isHomeStyle;
  final Map? groupInfoCardData;
  final Function onAddGroupTapped;
  const ChatList(
      {Key? key,
      this.isHomeStyle,
      this.groupInfoCardData,
      required this.onAddGroupTapped})
      : super(key: key);

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
              if (docs.length > widgetsList.length) {
                if (widget.isHomeStyle == true) {
                  findDocumentsHomeStyle(
                      docs, (snapshot.data as QuerySnapshot), streamedUser,
                      (widgets) {
                    setState(() {
                      widgetsList = widgets;
                    });
                  });
                } else {
                  findDocumentsGroupCardStyleStyle(
                      docs, widget.groupInfoCardData!, streamedUser, (widgets) {
                    setState(() {
                      widgetsList = widgets;
                    });
                  });
                }
              }
            }

            return widget.isHomeStyle == true
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: widgetsList),
                        GestureDetector(
                          onTap: () => widget.onAddGroupTapped(),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(19, 10, 0, 0),
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints.tight(const Size(66, 66)),
                              child: Transform.rotate(
                                angle: 0.2725,
                                child: DottedBorder(
                                    strokeWidth: 3,
                                    borderType: BorderType.Circle,
                                    radius: const Radius.circular(82),
                                    padding: EdgeInsets.zero,
                                    dashPattern: const [((82 * 3.14) / 7), 20],
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    strokeCap: StrokeCap.round,
                                    child: Transform.rotate(
                                      angle: 12.3,
                                      child: Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 36,
                                        ),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
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
                      color: Colors.grey,
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

  void findDocumentsHomeStyle(
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
          String nadiId = nadiMessageDoc.id;
          DocumentReference bussinessDoc =
              DataBaseService().nadiCollection.doc(nadiId);
          DocumentSnapshot doc = await bussinessDoc.get();

          NadiData docData =
              DataBaseService().nadiDataFromDoc(documentSnapshot: doc);

          widgets.add(_BuildHomeItem(
            isGroupInfoStyle: false,
            context: context,
            data: docData,
            streamedUser: streamedUser,
            nadiDoc: bussinessDoc,
            groupDoc: nadiMessageDoc.reference,
          ));
          fun(widgets);
        }
      });
    }
  }

  void findDocumentsGroupCardStyleStyle(List<DocumentSnapshot> docs,
      Map groupData, streamedUser, Function(List<Widget> widgets) fun) async {
    List<Widget> widgets = [];

    widgets = [];
    // ignore: avoid_function_literals_in_foreach_calls

    List groups =
        (streamedUser.groups as List).map((e) => e["nadi_id"]).toList();
    if (groups.contains(groupData["nadi_id"])) {
      String nadiId = groupData["nadi_id"];
      DocumentReference bussinessDoc =
          DataBaseService().nadiCollection.doc(nadiId);
      DocumentSnapshot doc = await bussinessDoc.get();

      NadiData docData =
          DataBaseService().nadiDataFromDoc(documentSnapshot: doc);

      widgets.add(_BuildHomeItem(
        isGroupInfoStyle: true,
        groupInfoCardData: widget.groupInfoCardData,
        context: context,
        data: docData,
        streamedUser: streamedUser,
        nadiDoc: bussinessDoc,
        groupDoc:
            DataBaseService().messagesCollection.doc(groupData["nadi_id"]),
      ));
      fun(widgets);
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
  final bool isGroupInfoStyle;
  final Map? groupInfoCardData;
  final NadiData data;
  final DocumentReference nadiDoc;
  final dynamic streamedUser;
  final DocumentReference groupDoc;

  _BuildHomeItem({
    Key? key,
    this.groupInfoCardData,
    required this.isGroupInfoStyle,
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
      builder: (context, groupDocSnapshot) {
        // this subscription will keep getting the latest message
        // from the group snapshots stream, if the latest message is not the last read message
        // then it will send the data down the unreadMessage sink and update what the user sees

        if (groupDocSnapshot.hasData) {
          final GroupData groupData =
              GroupData.parse(groupDocSnapshot.data!.data() as Map);

          final Message latestMessage = Message(
              time: groupData.time_of_messages!.isEmpty
                  ? null
                  : groupData.time_of_messages!.last,
              message: groupData.messages!.isEmpty
                  ? null
                  : groupData.messages!.last.toString(),
              userName: groupData.users_name!.isEmpty
                  ? null
                  : groupData.users_name!.last,
              documentId: groupData.users_doc_references!.isEmpty
                  ? null
                  : groupData.users_doc_references!.last.id);

          DeviceStorage()
              .isLastMessageUnread(nadiDoc.id, latestMessage, streamedUser)
              .then((isUnread) {
            if (Navigator.canPop(context)) {
              unreadMessageBoolsController.sink.add(false);
            } else {
              unreadMessageBoolsController.sink.add(isUnread);
            }
          });
        }

        return StreamBuilder(
            stream: unreadMessageBoolsController.stream,
            builder: (context, snapshot) {
              // if the style is for the homeopage so it will make a normal
              // looking one

              if (isGroupInfoStyle == false) {
                return GestureDetector(
                  onTap: () {
                    onItemTap(context, streamedUser, groupDoc, nadiDoc);
                    unreadMessageBoolsController.sink.add(false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 0, 4),
                    child: Column(
                      children: [
                        NewMessageCircleAvatar(
                            snapshot: snapshot,
                            radius: kContainerRadius,
                            borderThickness: kBorderThickness),
                        SizedBox(
                          width: kContainerRadius,
                          child: Center(
                            child: Text(
                              data.nadiName!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
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
              } else {
                // if the style is for the groups page so it will make in the the
                // form of a group info card
                return GroupInfoCard(
                    unreadMessageSnapshot: snapshot,
                    groupData: groupInfoCardData!);
              }
            });
      },
    );
  }
}

onItemTap(BuildContext context, dynamic streamedUser, DocumentReference doc,
    DocumentReference nadiDocument) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return ChatPage(
        groupDocument: doc,
        nadiDocument: nadiDocument,
        streamedUser: streamedUser);
  }));
}

// ignore_for_file: prefer_is_empty
import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_persistent_keyboard_height/flutter_persistent_keyboard_height.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:saudi_chat/models/nadi.dart';
import 'package:saudi_chat/models/message.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/chat/audio_container.dart';
import 'package:saudi_chat/pages/chat/microphone_button.dart';
import 'package:saudi_chat/pages/chat/nadi_details.dart';
import 'package:saudi_chat/pages/chat/view_video.dart';
import 'package:saudi_chat/services/chat.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saudi_chat/services/device_storage.dart';
import 'package:saudi_chat/shared/constants.dart';
import 'package:gallery_saver/files.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/shared/photo_viewer.dart';
import 'package:saudi_chat/shared/widgets.dart';

final List<String> arabicLetters = [
  "ز",
  "ظ",
  "ط",
  "د",
  "ج",
  "ح",
  "خ",
  "ه",
  "ق",
  "ع",
  "ف",
  "غ",
  "ض",
  "ص",
  "ث",
  "ا",
  "ل",
  "ب",
  "و",
  "ة",
  "ى",
  "لا",
  "ر",
  "ؤ",
  "ء",
  "ئ",
  "ت",
  "ن",
  "ي"
];

class ChatPage extends StatefulWidget {
  final DocumentReference? groupDocument;
  final String? groupId;
  final dynamic streamedUser;
  final DocumentReference nadiDocument;

  const ChatPage(
      {Key? key,
      this.groupDocument,
      this.groupId,
      this.streamedUser,
      required this.nadiDocument})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isLoading = false;

  final StreamController widgetStream = StreamController();

  bool? _kBottomOffset;

  @override
  void dispose() {
    widgetStream.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic streamedUser =
        widget.streamedUser ?? Provider.of<UserAuth>(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: documentStream,
        builder: (context, snapshot) {
          // every time a new message is sent,
          // this stream will be trigered

          if (snapshot.hasData) {
            Map data = snapshot.data!.data() as Map;
            GroupData groupData = GroupData.parse(data);

            List messages = groupData.messages as List;
            List userNames = groupData.users_name as List;
            List times = groupData.time_of_messages as List;
            List userDocs = groupData.users_doc_references as List;

            final NewMessageCommand command = NewMessageCommand(
                command: NewMessageCommandEnum.addMessage,
                message: messages.isNotEmpty && messages.last is Map
                    ? messages.last["storage_path"].toString().endsWith(".mp3")
                        ? //voice message
                        VoiceMessage(
                            durationMilliseconds: Duration(
                                milliseconds: messages.last["duration"]),
                            documentId:
                                userDocs.isEmpty ? null : userDocs.last.id,
                            time: times.isEmpty ? null : times.last,
                            userName: userNames.isEmpty ? null : userNames.last,
                            url: messages.last["url"],
                            storage_path: messages.last["storage_path"])
                        : messages.last["storage_path"]
                                .toString()
                                .endsWith(".mp4")
                            ? // video message
                            VideoMessage(
                                documentId:
                                    userDocs.isEmpty ? null : userDocs.last.id,
                                time: times.isEmpty ? null : times.last,
                                userName:
                                    userNames.isEmpty ? null : userNames.last,
                                url: messages.last["url"],
                                storage_path: messages.last["storage_path"])
                            :
                            // image message
                            ImageMessage(
                                documentId:
                                    userDocs.isEmpty ? null : userDocs.last.id,
                                time: times.isEmpty ? null : times.last,
                                userName:
                                    userNames.isEmpty ? null : userNames.last,
                                url: messages.last["url"],
                                storage_path: messages.last["storage_path"])
                    : Message(
                        time: times.isEmpty ? null : times.last,
                        message: messages.isEmpty ? null : messages.last,
                        userName: userNames.isEmpty ? null : userNames.last,
                        documentId: userDocs.isEmpty ? null : userDocs.last.id),
                widget: MessageItem(
                    userNames: userNames,
                    streamedUser: streamedUser,
                    i: messages.length - 1,
                    messages: messages,
                    times: times));

            if ((command.message.message != null &&
                        command.message.message!.isNotEmpty
                    ? messages.contains(command.message.message)
                    : true) &&
                times.contains(command.message.time) &&
                userNames.contains(command.message.userName)) {
              // a brand new message

              widgetStream.sink.add(command);
            }

            return PersistentKeyboardHeightProvider(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  toolbarHeight: 60,
                  title: GestureDetector(
                    onTap: () async {
                      QuerySnapshot membersCollection = await widget
                          .groupDocument!
                          .collection("members")
                          .get();

                      Navigator.push(context, MaterialPageRoute(
                          // needs PageRouteBuilder
                          /*transitionDuration: Duration(milliseconds: 200),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.linear;
            
                                final tween = Tween(begin: begin, end: end);
                                final curvedAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: curve,
                                );
            
                                return SlideTransition(
                                  position: tween.animate(curvedAnimation),
                                  child: child,
                                );
                              },*/
                          builder: (context) {
                        return NadiDetails(
                          streamUser: streamedUser,
                          groupDocument: widget.groupDocument!,
                          membersCollection: membersCollection,
                          groupData: snapshot.data!.data() as Map,
                        );
                      }));
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: Image.asset(
                            "assets/new_nadi_profile_pic.jpg",
                          ).image,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          snapshot.data!.get("nadi_data")["name"].toString(),
                          style: const TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Stack(fit: StackFit.expand, children: [
                        _ChatWidgets(
                          keyboardOn: _kBottomOffset,
                          document: snapshot
                              .data!, // the documentSnapshot of the group
                          streamedUser: streamedUser,
                          widgetStream: widgetStream,
                        ),
                        BottomFieldBar(
                            streamedUser: streamedUser,
                            businessStream: bussinessStream,
                            widgetStream: widgetStream,
                            changeBottomOffset: (keyboardOn) {
                              if (mounted) {
                                setState(() {
                                  _kBottomOffset = keyboardOn;
                                });
                              } else {
                                _kBottomOffset = keyboardOn;
                              }
                            },
                            onLoadingStart: () {
                              if (mounted) {
                                setState(() {
                                  isLoading = true;
                                });
                              }
                            },
                            onLoadingEnd: () {
                              if (mounted) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            groupDocument: widget.groupDocument,
                            groupId: widget.groupId),
                        PendingBar(
                            visible: isLoading,
                            strokeWidth: 4,
                            colors: [
                              Colors.grey.shade200,
                              Theme.of(context).colorScheme.secondaryContainer
                            ],
                            radius: 0)
                      ]),
                    ),
                    OffstageOffsetWidget(kBottomOffset: _kBottomOffset)
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Stream<DocumentSnapshot> get documentStream {
    if (widget.groupDocument != null) {
      return widget.groupDocument!.snapshots();
    } else if (widget.groupId != null) {
      return DataBaseService()
          .messagesCollection
          .doc(widget.groupId)
          .snapshots();
    } else {
      throw ("No DocumentReference and Group Id have been passed In, There needs to be at least 1 of them");
    }
  }

  Stream<NadiData> get bussinessStream {
    return widget.nadiDocument.snapshots().map((event) => NadiData(
          id: event.id,
          phoneNum: event.get("phoneNum"),
          nadiName: event.get("nadiName"),
          email: event.get("email"),
          location: event.get("location"),
        ));
  }
}

class _ChatWidgets extends StatefulWidget {
  final DocumentSnapshot document; // group Document
  final UserAuth streamedUser;
  final StreamController widgetStream;
  final bool? keyboardOn;
  const _ChatWidgets(
      {Key? key,
      required this.keyboardOn,
      required this.streamedUser,
      required this.widgetStream,
      required this.document})
      : super(key: key);

  @override
  State<_ChatWidgets> createState() => _ChatWidgetsState();
}

class _ChatWidgetsState extends State<_ChatWidgets> {
  final _scrollController = ScrollController();

  Message? lastMessage;

  bool isTop = false;

  List<Widget> columnChildren =
      []; // the list that will be the main for the widgets to display

  List<NewMessageCommand> commands = [];

  // for sending in new widgets and adding them to column children

  // view of messages for different sides A-B
  final myAlign = Alignment.centerRight;
  final theirAlign = Alignment.centerLeft;
  final myAlignment = CrossAxisAlignment.end;
  final theirAlignment = CrossAxisAlignment.start;
  final myTextAlignment = TextAlign.end;
  final theirTextAlignment = TextAlign.start;

  int _kColumnChildrenViewLength = 60;

  List<Widget> buildWidgets(
      {required DocumentSnapshot document, required dynamic streamedUser}) {
    // group document data

    List<Widget> widgets = [];

    Map data = document.data() as Map;
    GroupData groupData = GroupData.parse(data);

    List messages = groupData.messages as List;
    List userNames = groupData.users_name as List;
    List times = groupData.time_of_messages as List;
    // ignore: unused_local_variable
    List userDocs = groupData.users_doc_references as List;

    // this will loop through the each message and
    // make a list of widgets for each message
    for (int i = 0; i < messages.length; i++) {
      if (userNames.isNotEmpty) {
        // this is the widget that will be used if
        // the message is an image or video

        // adds the widgets for displaying to
        // the widgets list to then return it
        // and use it in a column that will show
        // all of these messages

        widgets.add(MessageItem(
            streamedUser: streamedUser,
            userNames: userNames,
            i: i,
            messages: messages,
            times: times));
        commands.add(NewMessageCommand(
            command: NewMessageCommandEnum.addMessage,
            message: Message(
                message: messages[i] is! String ? null : messages[i],
                userName: userNames[i],
                documentId: userDocs[i].id,
                time: times[i]),
            widget: MessageItem(
                streamedUser: streamedUser,
                userNames: userNames,
                i: i,
                messages: messages,
                times: times)));
      }
    }
    if (widgets.isNotEmpty && widgets.length > 1) {
      widgets.removeLast();
    }
    columnChildren = widgets;

    return widgets;
  }

  @override
  void dispose() {
    if (lastMessage != null && lastMessage!.time != null) {
      DeviceStorage().setLastReadMessageFromGroup(
          time: lastMessage!.time!,
          userName: lastMessage!.userName!,
          userDocId: lastMessage!.documentId!,
          groupDocId: widget.document.id,
          message: lastMessage!.message ?? '');
    }

    super.dispose();
  }

  @override
  void initState() {
    // this will limit the amount of items a user sees in the page
    // if he reaches the end of the limit, then it will add more
    // until it reaches the end, this listner does the job

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        setState(() {
          isTop = _scrollController.position.pixels == 0;
          if (!isTop) {
            _kColumnChildrenViewLength +=
                columnChildren.length >= (_kColumnChildrenViewLength + 30)
                    ? 30
                    : columnChildren.length - _kColumnChildrenViewLength;
          }
        });
      } else {
        setState(() {
          isTop = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight =
        PersistentKeyboardHeight.of(context).keyboardHeight;

    return StreamBuilder(
        stream: widget.widgetStream.stream,
        builder: (context, snapshot) {
          /// this is the StreamBuilder that will keep updating with
          /// every new data passing in, it will not update all of the
          /// widget like all the old method, instead it will build all of the
          /// widgets at the start with initState and buildWidgets, then we will
          /// use widgetStream to send all of the new messages down the stream and add them
          /// to the widget list instead of updating all of the widgets list

          NewMessageCommand? nmc;

          if (snapshot.hasData) {
            nmc = snapshot.data as NewMessageCommand?;

            commands.contains(nmc) ? null : commands.add(nmc!);

            // should be the last message in the chat list
            lastMessage = nmc!.message;
          }

          List<Widget> getColumnChildren() {
            Map data = widget.document.data() as Map;
            GroupData groupData = GroupData.parse(data);

            List messages = groupData.messages as List;
            // ignore: unused_local_variable
            List userNames = groupData.users_name as List;
            List times = groupData.time_of_messages as List;
            // ignore: unused_local_variable
            List userDocs = groupData.users_doc_references as List;

            // this method is used for checking if the last message
            // in columnChildren is not the same, because the data added
            // in the stream sometimes gets repeated twice, so this method
            // helps prevent the user from seeing two of the same messages
            return (nmc == null
                ? columnChildren
                // ignore: unnecessary_type_check
                : nmc.message is ImageMessage ||
                        nmc.message is VoiceMessage ||
                        nmc.message is VideoMessage
                    ? columnChildren.last == nmc.widget
                        ? columnChildren
                        : columnChildren.contains(nmc.widget)
                            ? columnChildren
                            : columnChildren.any((element) {
                                var elem = element as MessageItem;
                                return nmc!.message.time == times[elem.i] &&
                                    nmc.message.userName == userNames[elem.i];
                              })
                                ? columnChildren
                                : (columnChildren..add(nmc.widget))
                    : messages.length == columnChildren.length &&
                            columnChildren.last == nmc.widget
                        ? columnChildren
                        : columnChildren.contains(nmc.widget)
                            ? columnChildren
                            : columnChildren.any((element) {
                                var elem = element as MessageItem;
                                return nmc!.message.time == times[elem.i] &&
                                    nmc.message.userName == userNames[elem.i]
                                    ;
                              })
                                ? columnChildren
                                : (columnChildren..add(nmc.widget)));
          }

          return ScrollConfiguration(
            behavior: NoGlowScrollBehaviour(),
            child: SingleChildScrollView(
              reverse: true,
              controller: _scrollController,
              child: Column(children: [
                const SizedBox(
                  height: 15,
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: (columnChildren.isEmpty
                            ? (buildWidgets(
                                streamedUser: widget.streamedUser,
                                document: widget.document,
                              ))
                            : getColumnChildren())
                        .getRange(
                            columnChildren.length > 60
                                ? columnChildren.length -
                                    _kColumnChildrenViewLength
                                : 0,
                            columnChildren.length)
                        .toList()),
                SizedBox(
                  height: widget.keyboardOn == null
                      ? 75
                      : widget.keyboardOn == true
                          ? 75
                          : keyboardHeight + 75,
                )
              ]),
            ),
          );
        });
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem(
      {Key? key,
      required this.userNames,
      required this.i,
      required this.messages,
      required this.times,
      required this.streamedUser})
      : super(key: key);

  final List userNames;
  final int i;
  final UserAuth streamedUser;

  final List messages;
  final List times;
  final myAlign = Alignment.centerRight;
  final theirAlign = Alignment.centerLeft;
  final myAlignment = CrossAxisAlignment.end;
  final theirAlignment = CrossAxisAlignment.start;
  final myTextAlignment = TextAlign.end;
  final theirTextAlignment = TextAlign.start;

  @override
  Widget build(BuildContext context) {
    final bool elementCheck = userNames[i] == streamedUser.displayName;
    final bool isImage =
        messages[i] is Map && (messages[i] as Map).containsKey("url");

    // checks wether the message is a video
    final bool isVideo = isImage &&
        (messages[i] as Map)["storage_path"].toString().endsWith("mp4");

    final bool isAudio = isImage &&
        (messages[i] as Map)["storage_path"].toString().endsWith("mp3");

    final Widget? image;
    if (isImage) {
      if (!isVideo) {
        if (isAudio) {
          image = AudioContainer(
              elementcheck: elementCheck,
              duration: Duration(milliseconds: messages[i]["duration"]),
              audioUrl: messages[i]["url"],
              storagePath: messages[i]["storage_path"]);
        } else {
          image = makeImage(messages[i]);
        }
      } else {
        image = ViewVideo(
            storagePath: messages[i]["storage_path"],
            videoPosition: null,
            url: messages[i]["url"]);
      }
    } else {
      image = null;
    }

    bool checkBeforeTime() {
      List<String> stringList =
          times.map((e) => DateFormat.jm().format(e.toDate())).toList();

      if (i > 0 && stringList[i] == stringList[i - 1]) {
        if (i + 1 < stringList.length) {
          if (stringList[i] == stringList[i + 1]) {
            return false;
          } else {
            return true;
          }
        } else {
          return true;
        }
      } else if (i + 1 < stringList.length) {
        if (stringList[i] == stringList[i + 1]) {
          return false;
        } else {
          return true;
        }
      } else {
        return true;
      }
    }

    EdgeInsets messagePadding() {
      // this function will help stick the message that are from the same user together
      if (i > 0) {
        Message m1 = Message(
            message: messages[i] is! String
                ? messages[i]["storage_path"]
                : messages[i],
            time: times[i],
            userName: userNames[i]);

        Message m2 = Message(
            message: messages[i - 1] is! String
                ? messages[i - 1]["storage_path"]
                : messages[i - 1],
            time: times[i - 1],
            userName: userNames[i - 1]);

        if (m1.userName == m2.userName) {
          return const EdgeInsets.fromLTRB(16, 0, 16, 0);
        } else {
          return const EdgeInsets.fromLTRB(16.0, 16, 16, 0);
        }
      } else {
        return const EdgeInsets.fromLTRB(16.0, 16, 16, 0);
      }
    }

    return Align(
      alignment: elementCheck ? myAlign : theirAlign,
      child: GestureDetector(
        /* to delete message, can be upgraded to select !!! NOT FINISHED !!!
      onLongPressStart: (details) {
        // give options on message
        var keyContext = alignKey.currentContext;
        var box = keyContext!.findRenderObject() as RenderBox;
        var offset = box.localToGlobal(Offset.zero);
        print(box.size.width);
        var pos = alignKey.currentContext!.size!
            .bottomLeft(Offset(box.size.width, offset.dy - 50));
        print(MediaQuery.of(context).size.height);
        print(offset.dx);
        showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
                box.size.width,
                pos.dy,
                MediaQuery.of(context).size.width - box.size.width,
                MediaQuery.of(context).size.height - pos.dy),
            items: [PopupMenuItem(child: Text("Hi"))]);
      },*/
        child: Padding(
          padding: messagePadding(),
          child: Column(
            crossAxisAlignment: elementCheck ? myAlignment : theirAlignment,
            children: [
              Visibility(
                visible: (elementCheck
                        ? false
                        // ignore: prefer_const_constructors
                        : true) &&
                    messagePadding().top == 16,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                  child: InkWell(
                    splashColor: Colors.grey.shade300.withOpacity(0.6),
                    highlightColor: Colors.grey.shade300.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      List items = streamedUser.userClass == UserClass.admin ||
                              streamedUser.userClass == UserClass.coAdmin ||
                              streamedUser.userClass == UserClass.moderator
                          ? ["Block user"]
                          : [];
                      showDialog(
                          context: context,
                          builder: (context) => Dialog(
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: items
                                    .map((e) => InkWell(
                                          child: SizedBox(
                                            height: 56,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 18, 0, 0),
                                              child: Text(
                                                e.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6,
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              )));
                    },
                    child: Text(
                      elementCheck ? "" : userNames[i],
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign:
                          elementCheck ? myTextAlignment : theirTextAlignment,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Material(
                elevation: 1.4,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: elementCheck
                            ? Theme.of(context).primaryColorLight
                            : Theme.of(context).colorScheme.surfaceTint),
                    // ignore: prefer_const_constructors
                    constraints: BoxConstraints.loose(Size.fromWidth(
                        MediaQuery.of(context).size.width / 1.5)),
                    child: Padding(
                      padding: isImage
                          ? isVideo
                              ? const EdgeInsets.all(4.0)
                              : isAudio
                                  ? const EdgeInsets.all(4)
                                  : const EdgeInsets.all(6.0)
                          : const EdgeInsets.all(8.0),
                      child: messages[i].toString().length > 28 ||
                              messages[i] is Map
                          ? messages[i] is Map &&
                                  (messages[i] as Map).containsKey("duration")
                              ? Stack(
                                  alignment: elementCheck
                                      ? Alignment.bottomRight
                                      : isAudio
                                          ? Alignment.bottomRight
                                          : Alignment.bottomLeft,
                                  children: [
                                    Text(
                                      DateFormat.jm().format(times[i].toDate()),
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ]..insert(
                                      0,
                                      (isImage
                                          ? isVideo
                                              ? Hero(
                                                  tag:
                                                      (image! as ViewVideo).url,
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      child: image),
                                                )
                                              : isAudio
                                                  ? image
                                                  : GestureDetector(
                                                      child: Hero(
                                                        tag: (image!
                                                                as CachedNetworkImage)
                                                            .imageUrl,
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                            child: image),
                                                      ),
                                                      onTap: () async {
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        DetailScreen(
                                                                          isVideo:
                                                                              isVideo,
                                                                          videoPosition:
                                                                              null,
                                                                          storagePath:
                                                                              messages[i]["storage_path"],
                                                                          tag: (image as CachedNetworkImage)
                                                                              .imageUrl,
                                                                          imageUrl:
                                                                              image.imageUrl,
                                                                        )));
                                                      },
                                                    )
                                          : Text(
                                              messages[i],
                                              maxLines: null,
                                              style: getMessageTextStyle(
                                                  elementCheck, context),
                                              textDirection: messages[i]
                                                      .toString()
                                                      .characters
                                                      .any((element) =>
                                                          arabicLetters.any(
                                                              (arabicLetter) =>
                                                                  arabicLetter ==
                                                                  element))
                                                  ? TextDirection.rtl
                                                  : TextDirection.ltr,
                                              textAlign: messages[i]
                                                      .toString()
                                                      .characters
                                                      .any((element) =>
                                                          arabicLetters.any(
                                                              (arabicLetter) =>
                                                                  arabicLetter ==
                                                                  element))
                                                  ? TextAlign.right
                                                  : TextAlign.left,
                                            )) as Widget))
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: elementCheck
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                        height:
                                            messages[i].toString().length > 28
                                                ? 6
                                                : 0),
                                    Text(
                                      DateFormat.jm().format(times[i].toDate()),
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ]..insert(
                                      0,
                                      (isImage
                                          ? isVideo
                                              ? Hero(
                                                  tag:
                                                      (image! as ViewVideo).url,
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      child: image),
                                                )
                                              : isAudio
                                                  ? image
                                                  : GestureDetector(
                                                      child: Hero(
                                                        tag: (image!
                                                                as CachedNetworkImage)
                                                            .imageUrl,
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                            child: image),
                                                      ),
                                                      onTap: () async {
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        DetailScreen(
                                                                          isVideo:
                                                                              isVideo,
                                                                          videoPosition:
                                                                              null,
                                                                          storagePath:
                                                                              messages[i]["storage_path"],
                                                                          tag: (image as CachedNetworkImage)
                                                                              .imageUrl,
                                                                          imageUrl:
                                                                              image.imageUrl,
                                                                        )));
                                                      },
                                                    )
                                          : Text(
                                              messages[i],
                                              maxLines: null,
                                              style: getMessageTextStyle(
                                                  elementCheck, context),
                                              textDirection: messages[i]
                                                      .toString()
                                                      .characters
                                                      .any((element) =>
                                                          arabicLetters.any(
                                                              (arabicLetter) =>
                                                                  arabicLetter ==
                                                                  element))
                                                  ? TextDirection.rtl
                                                  : TextDirection.ltr,
                                              textAlign: messages[i]
                                                      .toString()
                                                      .characters
                                                      .any((element) =>
                                                          arabicLetters.any(
                                                              (arabicLetter) =>
                                                                  arabicLetter ==
                                                                  element))
                                                  ? TextAlign.right
                                                  : TextAlign.left,
                                            )) as Widget))
                          : SizedBox(
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: messages[i].toString().length > 28
                                          ? 6
                                          : 0,
                                      width: messages[i].toString().length > 28
                                          ? 0
                                          : elementCheck
                                              ? 6
                                              : 8,
                                    ),
                                  ]
                                    ..insert(
                                        elementCheck ? 0 : 1,
                                        (isImage
                                            ? isVideo
                                                ? Hero(
                                                    tag: (image! as ViewVideo)
                                                        .url,
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        child: image),
                                                  )
                                                : isAudio
                                                    ? image
                                                    : GestureDetector(
                                                        child: Hero(
                                                          tag: (image!
                                                                  as CachedNetworkImage)
                                                              .imageUrl,
                                                          child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                              child: image),
                                                        ),
                                                        onTap: () async {
                                                          await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DetailScreen(
                                                                            isVideo:
                                                                                isVideo,
                                                                            videoPosition:
                                                                                null,
                                                                            storagePath:
                                                                                messages[i]["storage_path"],
                                                                            tag:
                                                                                (image as CachedNetworkImage).imageUrl,
                                                                            imageUrl:
                                                                                image.imageUrl,
                                                                          )));
                                                        },
                                                      )
                                            : Text(
                                                messages[i],
                                                style: getMessageTextStyle(
                                                        elementCheck, context)!
                                                    .copyWith(
                                                        fontSize: messages[i]
                                                                .toString()
                                                                .characters
                                                                .any((element) =>
                                                                    arabicLetters.any((arabicLetter) =>
                                                                        arabicLetter ==
                                                                        element))
                                                            ? 15
                                                            : 16),
                                                textDirection: messages[i]
                                                        .toString()
                                                        .characters
                                                        .any((element) =>
                                                            arabicLetters.any(
                                                                (arabicLetter) =>
                                                                    arabicLetter ==
                                                                    element))
                                                    ? TextDirection.rtl
                                                    : TextDirection.ltr,
                                                textAlign: elementCheck
                                                    ? myTextAlignment
                                                    : theirTextAlignment,
                                              )) as Widget)
                                    ..insert(
                                      elementCheck ? 2 : 0,
                                      Text(
                                        DateFormat.jm()
                                            .format(times[i].toDate()),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                    )),
                            ),
                    )),
              ),
              const SizedBox(
                height: 5,
              )
            ],
          ),
        ),
      ),
    );
  }

  TextStyle? getMessageTextStyle(bool elementCheck, BuildContext context) {
    return elementCheck
        ? Theme.of(context).textTheme.headline6
        : Theme.of(context).textTheme.headline5;
  }
}

CachedNetworkImage makeImage(dynamic message) {
  return CachedNetworkImage(
    fadeOutDuration: const Duration(milliseconds: 500),
    placeholder: (context, _) {
      return const SizedBox(
          height: 80, width: 80, child: SpinKitCircle(color: Colors.white));
    },
    errorWidget: (context, error, _) {
      return SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: Row(
            children: const [
              Icon(Icons.error_outline),
              Text("Could not load image")
            ],
          ),
        ),
      );
    },
    imageUrl: message["url"].toString(),
    filterQuality: FilterQuality.medium,
  );
}

class BottomFieldBar extends StatefulWidget {
  final String? groupId;
  final DocumentReference? groupDocument;
  final Function onLoadingStart;
  final Function onLoadingEnd;
  final dynamic streamedUser;
  final Stream<NadiData> businessStream;
  final StreamController widgetStream;
  final Function(bool? keyboardOn) changeBottomOffset;
  const BottomFieldBar(
      {Key? key,
      this.groupId,
      required this.widgetStream,
      required this.onLoadingStart,
      required this.changeBottomOffset,
      required this.onLoadingEnd,
      this.groupDocument,
      required this.streamedUser,
      required this.businessStream})
      : super(key: key);

  @override
  _BottomFieldBarState createState() => _BottomFieldBarState();
}

class _BottomFieldBarState extends State<BottomFieldBar> {
  final controller = TextEditingController();

  FocusNode focusNode = FocusNode();

  // to show or hide the emoji keyboard
  bool isEmojiVisible = false;
  bool isKeyboardVisible = false;

  double keyboardHeight = 0;

  bool wasFocused = false;

  String currentText = "";

  Future<void> pickFile(streamedUser, pickType) async {
    try {
      final XFile? insertedFile = pickType == "image"
          ? await ImagePicker().pickImage(source: ImageSource.gallery)
          : await ImagePicker().pickVideo(source: ImageSource.gallery);

      if (insertedFile != null) {
        widget.onLoadingStart();

        final File storedImage = File(insertedFile.path);

        MessageDatabase()
            .addImageOrVideoToGroup(
                storedImage,
                widget.groupId ?? widget.groupDocument!.id,
                (isVideo(insertedFile.path)
                    ? "${insertedFile.name}.mp4"
                    : "${insertedFile.name}.jpg"),
                Message(
                    userName: streamedUser.displayName,
                    documentId: streamedUser.uid))
            .whenComplete(() => widget.onLoadingEnd());
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Could not open gallery. An error has accured");
      print(e.toString()); // TODO: Test
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChanged);
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // this will add a listener to check if the user has opened the textfield
    // or is it selected to switch from the emojikeyboard to keyboard or nothing

    focusNode.addListener(_onFocusChanged);

    // this will keep updating every time the user has opened the keyboard
    // it will change the offset for the chat messages and hidden box
    // and remove the moji keyboard if its on

    controller.addListener(() => mounted
        ? setState(() {
            currentText = controller.text;
          })
        : currentText = controller.text);

    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible) {
        widget.changeBottomOffset(true);
      } else if (isEmojiVisible) {
        widget.changeBottomOffset(false);
      } else {
        widget.changeBottomOffset(null);
      }
      if (mounted) {
        setState(() {
          isKeyboardVisible = visible;
        });
      } else {
        isKeyboardVisible = visible;
      }

      if (isKeyboardVisible && isEmojiVisible) {
        setState(() {
          isEmojiVisible = false;
        });
      }
    });

    super.initState();
  }

  void _onFocusChanged() {
    setState(() {
      wasFocused = true;
    });
  }

  void onEmojiSelected(String emoji) => setState(() {
        controller.text = controller.text + emoji;
      });

  Future toggleEmojiKeyboard() async {
    // if the emojiKeyboard is on, then switch to keyboard
    // if the emojikeyboard is off, then switch to emoji keyboard
    // if none are on, then open emoji keyboard

    if (isEmojiVisible) {
      setState(() {
        isEmojiVisible = false;
        isKeyboardVisible = true;
      });
      FocusScope.of(context).requestFocus();
      if (wasFocused) {
        widget.changeBottomOffset(true);
      } else {
        widget.changeBottomOffset(null);
      }
      return;
    }

    if (!isEmojiVisible && isKeyboardVisible) {
      setState(() {
        isEmojiVisible = true;
        isKeyboardVisible = false;
      });

      FocusScope.of(context).unfocus();
      widget.changeBottomOffset(false);
      return;
    }

    // if none are on
    setState(() {
      isEmojiVisible = true;
      isKeyboardVisible = false;
    });
    FocusScope.of(context).unfocus();
    widget.changeBottomOffset(false);
    return;
  }

  Future<bool> onBackPress() {
    if (isEmojiVisible) {
      setState(() {
        isEmojiVisible = false;
        isKeyboardVisible = false;
      });

      FocusScope.of(context).unfocus();
      widget.changeBottomOffset(null);
      return Future.value(false);
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    dynamic streamedUser = widget.streamedUser;

    final double keyboardHeight =
        PersistentKeyboardHeight.of(context).keyboardHeight;

    assert(widget.groupDocument != null || widget.groupId != null);
    return WillPopScope(
        onWillPop: () => onBackPress(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.background,
                    height: 67,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceTint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 0, 15),
                                  child: GestureDetector(
                                    child: Icon(
                                        isEmojiVisible
                                            ? Icons.keyboard_rounded
                                            : Icons.emoji_emotions_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    onTap: toggleEmojiKeyboard,
                                  )),
                              Container(
                                constraints: BoxConstraints(
                                    maxHeight: 100,
                                    maxWidth:
                                        (MediaQuery.of(context).size.width /
                                                2) -
                                            20),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 3, 0, 3),
                                  child: Theme(
                                    data: ThemeData(
                                      primaryColor: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      colorScheme: ColorScheme.light(
                                          primary: Colors.grey.shade100,
                                          secondary: Theme.of(context)
                                              .colorScheme
                                              .onBackground),
                                    ),
                                    child: TextField(
                                        textAlign:
                                            currentText.characters.any((element) => arabicLetters.any((arabicLetter) => arabicLetter == element))
                                                ? TextAlign.right
                                                : TextAlign.left,
                                        textDirection: currentText
                                                .toString()
                                                .characters
                                                .any((element) => arabicLetters.any(
                                                    (arabicLetter) =>
                                                        arabicLetter ==
                                                        element))
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        focusNode: focusNode,
                                        keyboardType: TextInputType.multiline,
                                        textInputAction:
                                            TextInputAction.newline,
                                        onEditingComplete: () async {
                                          // ignore: unnecessary_null_comparison
                                          if (controller.text != null &&
                                              controller.text.isNotEmpty) {
                                            if (streamedUser.displayName !=
                                                null) {
                                              MessageDatabase()
                                                  .addMessageToGroup(
                                                      message: Message(
                                                          documentId:
                                                              streamedUser.uid,
                                                          message:
                                                              controller.text,
                                                          userName: streamedUser
                                                              .displayName),
                                                      groupDocument:
                                                          widget.groupDocument);

                                              controller.clear();
                                            }
                                          }
                                        },
                                        style: TextStyle(
                                            fontFamily: "Roboto",
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                        showCursor: true,
                                        controller: controller,
                                        maxLines: null,
                                        decoration: textInputDecoration.copyWith(
                                            border: InputBorder.none,
                                            hintText: "Message",
                                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8)))),
                                  ),
                                ),
                              ),
                              IconButton(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 6),
                                  splashRadius: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                  onPressed: () async {
                                    // ignore: unnecessary_null_comparison
                                    if (controller.text != null &&
                                        controller.text.isNotEmpty) {
                                      if (streamedUser.displayName == null) {
                                        setState(() {});
                                      }
                                      MessageDatabase().addMessageToGroup(
                                          message: Message(
                                              documentId: streamedUser.uid,
                                              message: controller.text,
                                              userName:
                                                  streamedUser.displayName),
                                          groupDocument: widget.groupDocument);
                                      controller.clear();
                                    }
                                  },
                                  icon: const Icon(Icons.send_rounded))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 2.5),
                          child: Container(
                            width: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary),
                            child: IconButton(
                                splashRadius: 26.3,
                                color: Colors.white,
                                onPressed: () async {
                                  String? type = await showModalBottomSheet(
                                      context: context,
                                      constraints: BoxConstraints.loose(
                                          Size.fromHeight(MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  6 +
                                              12)),
                                      enableDrag: false,
                                      builder: (context) {
                                        return Column(children: [
                                          ScreenWidthCard(
                                              highlightColor: Colors.grey[200],
                                              splashColor: Colors.transparent,
                                              onTap: () => Navigator.pop(
                                                  context, "image"),
                                              child: Row(children: [
                                                const SizedBox(
                                                  width: 12,
                                                ),
                                                Icon(
                                                  Icons.image_outlined,
                                                  size: 32,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .caption!
                                                      .color,
                                                ),
                                                const SizedBox(
                                                  width: 26,
                                                ),
                                                Text(
                                                  "Pick an Image",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption!
                                                      .copyWith(fontSize: 18),
                                                )
                                              ]),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  12),
                                          ScreenWidthCard(
                                              highlightColor: Colors.grey[200],
                                              splashColor: Colors.transparent,
                                              onTap: () => Navigator.pop(
                                                  context, "video"),
                                              child: Row(children: [
                                                const SizedBox(
                                                  width: 12,
                                                ),
                                                Icon(
                                                  Icons.slideshow_rounded,
                                                  size: 32,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .caption!
                                                      .color,
                                                ),
                                                const SizedBox(
                                                  width: 26,
                                                ),
                                                Text(
                                                  "Pick a Video",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption!
                                                      .copyWith(fontSize: 18),
                                                )
                                              ]),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  12),
                                          const SizedBox(
                                            height: 12,
                                          )
                                        ]);
                                      });
                                  if (type != null) {
                                    await pickFile(streamedUser, type);
                                  }
                                },
                                icon: const Icon(
                                  Icons.image_outlined,
                                  size: 26,
                                )),
                          ),
                        ),
                        MicrophoneButton(
                            groupId: widget.groupId ?? widget.groupDocument!.id,
                            streamedUser: streamedUser,
                            onLoadingStart: widget.onLoadingStart,
                            onLoadingEnd: widget.onLoadingEnd),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Offstage(
              offstage: !isEmojiVisible,
              child: EmojiPickerWidget(
                onEmojiSelected: onEmojiSelected,
                keyboardHeight: keyboardHeight == 0
                    ? MediaQuery.of(context).size.height / 2.8
                    : keyboardHeight,
              ),
            ),
          ],
        ));
  }
}

class OffstageOffsetWidget extends StatelessWidget {
  final bool? kBottomOffset;
  const OffstageOffsetWidget({Key? key, required this.kBottomOffset})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight =
        PersistentKeyboardHeight.of(context).keyboardHeight;
    return Offstage(
      offstage: kBottomOffset == null ? true : !kBottomOffset!,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: keyboardHeight == 0
            ? MediaQuery.of(context).size.height / 2.83
            : keyboardHeight,
        color: Colors.transparent,
      ),
    );
  }
}

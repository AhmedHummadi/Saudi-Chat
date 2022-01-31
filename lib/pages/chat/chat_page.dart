// ignore_for_file: prefer_is_empty
import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saudi_chat/models/nadi.dart';
import 'package:saudi_chat/models/message.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/chat/audio_container.dart';
import 'package:saudi_chat/pages/chat/chat_list.dart';
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
import 'package:just_audio/just_audio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "package:images_picker/images_picker.dart";
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/shared/photo_viewer.dart';
import 'package:saudi_chat/shared/widgets.dart';

class ChatPage extends StatefulWidget {
  final DocumentReference? groupDocument;
  final String? groupId;
  final dynamic streamedUser;
  final DocumentReference bussinessDoc;

  const ChatPage(
      {Key? key,
      this.groupDocument,
      this.groupId,
      this.streamedUser,
      required this.bussinessDoc})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Widget> columnChildren = [];

  bool isLoading = false;

  Message? lastMessage;

  @override
  void dispose() {
    if (lastMessage != null) {
      DeviceStorage().setLastReadMessageFromGroup(
          message: lastMessage!.message!,
          userName: lastMessage!.userName!,
          userDocId: lastMessage!.documentId!,
          groupDocId: widget.groupId ?? widget.groupDocument!.id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic streamedUser =
        widget.streamedUser ?? Provider.of<UserAuth>(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: documentStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (columnChildren.length !=
                (snapshot.data!.get("messages") as List).length) {
              buildWidgets(
                  streamedUser: streamedUser,
                  document: snapshot.data!,
                  function: (text) {
                    columnChildren = text;
                  });
            }
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 60,
                // ignore: prefer_const_constructors
                actions: [
                  IconButton(
                      onPressed: () => showCenterScreenMenu(
                          context,
                          CenterScreenOptionsMenu(
                            items: [
                              CenterScreenOptionsMenuItem(
                                  text: "Delete a message",
                                  value: 0,
                                  height: 50),
                              CenterScreenOptionsMenuItem(
                                  text: "Kick/Ban a member",
                                  value: 1,
                                  height: 50),
                            ],
                            onSelected: (index) {
                              switch (index) {
                                case 0:
                                  // Delete a message
                                  break;
                                case 1:
                                  // Kick/Ban a member
                                  break;
                              }
                            },
                          )),
                      icon: const Icon(
                        Icons.admin_panel_settings,
                        size: 30,
                      ))
                ],
                title: GestureDetector(
                  onTap: () async {
                    QuerySnapshot membersCollection =
                        await widget.groupDocument!.collection("members").get();

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
              body: Stack(fit: StackFit.expand, children: [
                SingleChildScrollView(
                  reverse: true,
                  child: Column(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: columnChildren,
                    ),
                    const SizedBox(
                      height: 64.0,
                    )
                  ]),
                ),
                BottomFieldBar(
                    streamedUser: streamedUser,
                    businessStream: bussinessStream,
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
                      Theme.of(context).colorScheme.secondaryVariant
                    ],
                    radius: 10)
              ]),
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
    return widget.bussinessDoc.snapshots().map((event) => NadiData(
          id: event.id,
          phoneNum: event.get("phoneNum"),
          nadiName: event.get("nadiName"),
          email: event.get("email"),
          location: event.get("location"),
        ));
  }

  void buildWidgets(
      {required DocumentSnapshot document,
      required dynamic streamedUser,
      required Function(List<Widget> widget) function}) {
    // group document data

    Map data = document.data() as Map;
    GroupData groupData = GroupData.parse(data);

    List messages = groupData.messages as List;
    List userNames = groupData.users_name as List;
    List times = groupData.time_of_messages as List;
    List userDocs = groupData.users_doc_references as List;

    // messages for displaying
    List<Widget> widgets = [];

    lastMessage = Message(
        message: messages.last,
        userName: userNames.last,
        documentId: userDocs.last.id);

    // view of messages for different sides A-B
    var myAlign = Alignment.centerRight;
    var theirAlign = Alignment.centerLeft;
    var myAlignment = CrossAxisAlignment.end;
    var theirAlignment = CrossAxisAlignment.start;
    var myTextAlignment = TextAlign.end;
    var theirTextAlignment = TextAlign.start;

    // this will loop through the each message and
    // make a list of widgets for each message
    for (var i = 0; i < messages.length; i++) {
      if (userNames.length > 0 && messages.length > 0) {
        GlobalKey alignKey = GlobalKey();
        // checks if the image is the users message
        // to show it in their side
        bool elementCheck = userNames.elementAt(i) == streamedUser.displayName;

        //checks wether the message is an image
        bool isImage = messages.elementAt(i) is Map &&
            (messages.elementAt(i) as Map).containsKey("url");

        // checks wether the message is a video
        bool isVideo = isImage &&
            (messages.elementAt(i) as Map)["storage_path"]
                .toString()
                .endsWith("mp4");

        bool isAudio = isImage &&
            (messages.elementAt(i) as Map)["storage_path"]
                .toString()
                .endsWith("mp3");

        // this is the widget that will be used if
        // the message is an image or video
        final Widget? image = isImage
            ? !isVideo
                ? isAudio
                    ? AudioContainer(
                        audioUrl: messages.elementAt(i)["url"],
                        storagePath: messages.elementAt(i)["storage_path"])
                    : makeImage(messages, i)
                : ViewVideo(
                    storagePath: messages[i]["storage_path"],
                    videoPosition: null,
                    url: messages[i]["url"])
            : null;

        // adds the widgets for displaying to
        // the widgets list to then return it
        // and use it in a column that will show
        // all of these messages
        widgets.add(Align(
          key: alignKey,
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
              padding: const EdgeInsets.fromLTRB(16.0, 10, 16, 10),
              child: Column(
                crossAxisAlignment: elementCheck ? myAlignment : theirAlignment,
                children: [
                  Visibility(
                    visible: elementCheck
                        ? false
                        // ignore: prefer_const_constructors
                        : true,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                      child: Text(
                        elementCheck ? "" : userNames.elementAt(i),
                        textAlign:
                            elementCheck ? myTextAlignment : theirTextAlignment,
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
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(context).colorScheme.onBackground),
                      // ignore: prefer_const_constructors
                      constraints: BoxConstraints.loose(Size.fromWidth(240)),
                      child: Padding(
                        padding: isImage
                            ? isVideo
                                ? const EdgeInsets.all(4.0)
                                : isAudio
                                    ? const EdgeInsets.all(4)
                                    : const EdgeInsets.all(6.0)
                            : const EdgeInsets.all(8.0),
                        child: isImage
                            ? isVideo
                                ? Hero(
                                    tag: (image! as ViewVideo).url,
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: image),
                                  )
                                : isAudio
                                    ? image
                                    : GestureDetector(
                                        child: Hero(
                                          tag: (image! as CachedNetworkImage)
                                              .imageUrl,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              child: image),
                                        ),
                                        onTap: () async {
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailScreen(
                                                        isVideo: isVideo,
                                                        videoPosition: null,
                                                        storagePath: messages[i]
                                                            ["storage_path"],
                                                        tag: (image
                                                                as CachedNetworkImage)
                                                            .imageUrl,
                                                        imageUrl:
                                                            image.imageUrl,
                                                      )));
                                        },
                                      )
                            : SelectableText(
                                messages.elementAt(i),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                textAlign: elementCheck
                                    ? myTextAlignment
                                    : theirTextAlignment,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Visibility(
                      visible: times.elementAt(i) ==
                              (i - 1 != (-1) ? times.elementAt(i - 1) : "null")
                          ? false
                          // ignore: prefer_const_constructors
                          : true,
                      child: Text(times.elementAt(i)))
                ],
              ),
            ),
          ),
        ));
      }
      function(widgets);
    }
  }

  CachedNetworkImage makeImage(List<dynamic> messages, int i) {
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
      imageUrl: messages.elementAt(i)["url"].toString(),
      filterQuality: FilterQuality.medium,
    );
  }
}

class BottomFieldBar extends StatefulWidget {
  final String? groupId;
  final DocumentReference? groupDocument;
  final Function onLoadingStart;
  final Function onLoadingEnd;
  final dynamic streamedUser;
  final Stream<NadiData> businessStream;
  const BottomFieldBar(
      {Key? key,
      this.groupId,
      required this.onLoadingStart,
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

  Future<void> pickFile(streamedUser) async {
    try {
      final List<Media>? insertedFiles = await ImagesPicker.pick(
          maxSize: 100000000, // 100 MB
          pickType: PickType.all);

      if (insertedFiles != null && insertedFiles.isNotEmpty) {
        widget.onLoadingStart();

        final Media pickerFile = insertedFiles.single;

        final File storedImage = File(pickerFile.path);

        final XFile insertedImage =
            XFile.fromData(await storedImage.readAsBytes());
        MessageDatabase()
            .addImageOrVideoToGroup(
                storedImage,
                widget.groupId ?? widget.groupDocument!.id,
                (isVideo(pickerFile.path)
                    ? "${insertedImage.name}.mp4"
                    : "${insertedImage.name}.jpg"),
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
  Widget build(BuildContext context) {
    dynamic streamedUser = widget.streamedUser;

    assert(widget.groupDocument != null || widget.groupId != null);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 15, 0, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.surface),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: InkWell(
                      child: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: 100,
                        maxWidth: (MediaQuery.of(context).size.width / 2) - 20),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 3, 0, 3),
                      child: Theme(
                        data: ThemeData(
                          primaryColor: Colors.white,
                          colorScheme: ColorScheme.light(
                              primary: Colors.grey.shade100,
                              secondary: Colors.white),
                        ),
                        child: TextField(
                            textInputAction: TextInputAction.send,
                            onEditingComplete: () async {
                              // ignore: unnecessary_null_comparison
                              if (controller.text != null &&
                                  controller.text.isNotEmpty) {
                                if (streamedUser.displayName != null) {
                                  MessageDatabase().addMessageToGroup(
                                      message: Message(
                                          documentId: streamedUser.uid,
                                          message: controller.text,
                                          userName: streamedUser.displayName),
                                      groupDocument: widget.groupDocument);

                                  controller.clear();
                                }
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            showCursor: true,
                            controller: controller,
                            decoration: textInputDecoration.copyWith(
                                border: InputBorder.none,
                                hintText: "Message",
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.8)))),
                      ),
                    ),
                  ),
                  IconButton(
                      splashRadius: 20,
                      color: Colors.white,
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
                                  userName: streamedUser.displayName),
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
                    color: Theme.of(context).colorScheme.surface),
                child: IconButton(
                    splashRadius: 26.3,
                    color: Colors.white,
                    onPressed: () async {
                      await pickFile(streamedUser);
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
    );
  }
}

List<AudioPlayer> currentAudioPlaying = [];

// ignore: must_be_immutable

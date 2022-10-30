import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/admin/assign_admin.dart';
import 'package:saudi_chat/pages/admin/assign_mod.dart';
import 'package:saudi_chat/pages/admin/demote_user.dart';
import 'package:saudi_chat/pages/news/post_news_page.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:saudi_chat/shared/widgets.dart';

class _MainControlPanel extends StatefulWidget {
  final bool assignAdmin;
  final bool assignModerator;
  final bool postNews;
  final bool demoteUser;
  final UserClass userActionSearchtype;
  const _MainControlPanel(
      {Key? key,
      required this.demoteUser,
      required this.userActionSearchtype,
      required this.assignAdmin,
      required this.assignModerator,
      required this.postNews})
      : super(key: key);

  @override
  State<_MainControlPanel> createState() => _MainControlPanelState();
}

class _MainControlPanelState extends State<_MainControlPanel> {
  final StreamController userSearchStream = StreamController();
  DocumentSnapshot? userDoc;
  QuerySnapshot? usersDocuments;
  final TextEditingController userTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final UserAuth streamedUser = Provider.of<UserAuth>(context);
    return Column(
      children: [
        Visibility(
          visible: widget.assignAdmin,
          child: ScreenWidthCard(
              splashColor: Colors.transparent,
              highlightColor: const Color.fromARGB(172, 230, 230, 230),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AssignAdmin(
                    streamedUser: streamedUser,
                  );
                }));
              },
              height: 56,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.person_add_alt_1,
                    size: 38,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  Text(
                    "Assign admin to group",
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 20, color: Colors.grey[800]),
                  )
                ],
              )),
        ),
        Visibility(
          visible: widget.assignModerator,
          child: ScreenWidthCard(
              splashColor: Colors.transparent,
              highlightColor: const Color.fromARGB(172, 230, 230, 230),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AssignMod(streamedUser: streamedUser);
                }));
              },
              height: 56,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.add_moderator,
                    size: 36,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(
                    width: 42,
                  ),
                  Text(
                    "Assign moderator",
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 20, color: Colors.grey[800]),
                  )
                ],
              )),
        ),
        Visibility(
          visible: widget.demoteUser,
          child: ScreenWidthCard(
              splashColor: Colors.transparent,
              highlightColor: const Color.fromARGB(172, 230, 230, 230),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return DemoteUser(streamedUser: streamedUser);
                }));
              },
              height: 56,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.person_off,
                    size: 36,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(
                    width: 42,
                  ),
                  Text(
                    "Demote User",
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 20, color: Colors.grey[800]),
                  )
                ],
              )),
        ),
        Visibility(
          visible: widget.postNews,
          child: ScreenWidthCard(
              splashColor: Colors.transparent,
              highlightColor: const Color.fromARGB(172, 230, 230, 230),
              onTap: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return AddNewsPage(streamedUser: streamedUser);
                }));
              },
              height: 56,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.post_add,
                    size: 36,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(
                    width: 42,
                  ),
                  Text(
                    "Post news",
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 20, color: Colors.grey[800]),
                  )
                ],
              )),
        ),
        Divider(
          height: 26,
          endIndent: 14,
          indent: 14,
          color: Colors.grey[800],
          thickness: 0.6,
        ),
        Builder(builder: (context) {
          assert(widget.userActionSearchtype != UserClass.user);
          switch (widget.userActionSearchtype) {
            case UserClass.moderator:
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Theme(
                        data: ThemeData(
                            textSelectionTheme: TextSelectionThemeData(
                                cursorColor:
                                    Theme.of(context).colorScheme.primary)),
                        child: MyTextField(
                            controller: userTextController,
                            formKey: _formKey,
                            hintText: "Search by email...",
                            inputStyle: TextStyle(color: Colors.grey.shade800),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade500)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade500)),
                            validatorText: "Please select a user",
                            onChangedVal: (input) async {
                              if (usersDocuments == null) {
                                var docs = await DataBaseService()
                                    .authUsersCollection
                                    .get();
                                setState(() {
                                  usersDocuments = docs;
                                });
                              }
                              if (input != null && input.length > 3) {
                                setState(() {
                                  DataBaseService().searchUsersByEmail(
                                      userSearchStream, input, usersDocuments!);
                                });
                              } else {
                                userSearchStream.sink.add(null);
                              }
                            },
                            validateCondition: (val, errorText) =>
                                userDoc != null ? null : errorText),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    StreamBuilder(
                      stream: userSearchStream.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data;
                          if (data == ConnectionState.waiting) {
                            // loading
                            return Container();
                          } else {
                            // the list of users
                            if (data is List) {
                              if (data.isEmpty) {
                                // no users found
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  width: Size.infinite.width,
                                  height: 70,
                                  child: const Center(
                                    child: Text(
                                      "No results found",
                                      style: TextStyle(
                                          fontSize: 26, letterSpacing: 1.1),
                                    ),
                                  ),
                                );
                              }
                              // users found
                              return SingleChildScrollView(
                                child: Column(
                                    children: data.map((e) {
                                  DocumentSnapshot user = e;
                                  return UserInfoCard(
                                      userData: UserAuth.parseFromUserDocument(
                                          user.data() as Map<String, dynamic>
                                            ..addAll({"id": user.id})),
                                      searchFieldController:
                                          userTextController);
                                }).toList()),
                              );
                            } else {
                              // should be an error
                              return const Text("an unknown error has occured");
                            }
                          }
                        }
                        // data is null and there isnt anything in stream
                        return Container();
                      },
                    ),
                  ],
                ),
              );

            case UserClass.admin:
              return Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: SingleChildScrollView(
                  child: FutureBuilder(
                      future:
                          streamedUser.groupAdmin!.collection("members").get(),
                      builder: (context, future) {
                        if (future.hasData) {
                          // data is not null

                          List<DocumentSnapshot> membersDocuments =
                              (future.data as QuerySnapshot).docs
                                ..removeWhere((element) =>
                                    element.get("name") ==
                                    streamedUser.displayName);

                          return Column(
                            children: membersDocuments
                                .map((memberDoc) => UserInfoCard(
                                      userData: UserAuth.parseFromUserDocument(
                                          memberDoc.data()
                                              as Map<String, dynamic>
                                            ..addAll({"id": memberDoc.id})),
                                    ))
                                .toList(),
                          );
                        } else {
                          // data is null
                          return Container();
                        }
                      }),
                ),
              );

            case UserClass.coAdmin:
              return Container();
            default:
              return Container();
          }
        })
      ],
    );
  }

  void onUserTapped(DocumentSnapshot doc) {
    setState(() {
      userDoc = doc;
    });

    // remove the users shown
    userSearchStream.sink.add(null);

    // remove the query text
    userTextController.clear();
  }
}

class ModeratorPanelPage extends StatelessWidget {
  const ModeratorPanelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _MainControlPanel(
        demoteUser: true,
        assignAdmin: true,
        assignModerator: true,
        userActionSearchtype: UserClass.moderator,
        postNews: true);
  }
}

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _MainControlPanel(
        demoteUser: false,
        userActionSearchtype: UserClass.admin,
        assignAdmin: true,
        assignModerator: false,
        postNews: true);
  }
}

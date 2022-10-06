import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:saudi_chat/shared/loadingWidget.dart';
import 'package:saudi_chat/shared/widgets.dart';

class AssignPage extends StatefulWidget {
  final UserAuth streamedUser;
  final Future<bool> Function(DocumentSnapshot userDoc,
      DocumentSnapshot? groupDoc, UserClass? userClass)? function;
  final bool withGroup;
  final String appBarTitle;
  final bool withClassDropdown;
  const AssignPage(
      {Key? key,
      required this.streamedUser,
      required this.appBarTitle,
      this.function,
      required this.withClassDropdown,
      required this.withGroup})
      : super(key: key);

  @override
  State<AssignPage> createState() => _AssignPageState();
}

class _AssignPageState extends State<AssignPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  DocumentSnapshot? userDoc;

  DocumentSnapshot? groupDoc;

  UserClass? dropDownClass;

  // this is the stream that will be controlling the search for the
  // users, every time a query is sent, it will look at all the docs
  // in the users and return the results from checkInputMatch() that is used
  // in the search widget, it will send the results down the stream through
  // userSearchStream.sink.add([data]) and we will use StreamBuilder and
  // userSearchStream.stream together so that every time new data is sent down
  // the stream, the StreamBuilder will update and the data will be shown
  // null = no data, ConnectionState.waiting = loading, [] = no results
  // this method is better than using setState({}) every time we want
  // to update the ui with the new results
  final StreamController userSearchStream = StreamController();

  // this is the stream that will be controlling the group search
  // the exact same as the userSearchStream
  final StreamController groupSearchStream = StreamController();

  // the documents we will use the search on
  QuerySnapshot? usersDocuments;
  QuerySnapshot? groupsDocuments;

  final TextEditingController userTextController = TextEditingController();
  final TextEditingController groupTextController = TextEditingController();

  @override
  void dispose() {
    userSearchStream.close();
    groupSearchStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 12,
                ),
                Text("User:",
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 20)),
                const SizedBox(
                  height: 14,
                ),
                userDoc == null
                    ? MyTextField(
                        controller: userTextController,
                        formKey: _formKey,
                        hintText: "Search by email...",
                        inputStyle: TextStyle(color: Colors.grey.shade700),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade400)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade400)),
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
                            userDoc != null ? null : errorText)
                    : Column(
                        children: [
                          Container(
                            height: 70,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.surface),
                            child: ListTile(
                              textColor: Colors.white,
                              title: Text(userDoc!.get("email")),
                              subtitle: Text(widget.appBarTitle == "Demote User"
                                  ? userDoc!.get("userClass")
                                  : userDoc!.get("name")),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  userDoc = null;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                                height: 50,
                                width: Size.infinite.width,
                                child: const Center(
                                  child: Text("Reset",
                                      style: TextStyle(
                                        fontSize: 24,
                                        letterSpacing: 1.4,
                                      )),
                                ),
                              ))
                        ],
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
                        if (data is List) {
                          if (data.isEmpty) {
                            // no results found
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                      letterSpacing: 1.1),
                                ),
                              ),
                            );
                          }
                          // there is data
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              width: Size.infinite.width,
                              constraints: BoxConstraints.loose(
                                  const Size.fromHeight(210)),
                              child: SingleChildScrollView(
                                child: Column(
                                    children: data.map((e) {
                                  DocumentSnapshot user = e;
                                  return GestureDetector(
                                    onTap: () => onUserTapped(user),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints.tight(
                                          Size(Size.infinite.width, 70)),
                                      child: ListTile(
                                        title: Text(user.get("email")),
                                        subtitle: Text(user.get("name")),
                                      ),
                                    ),
                                  );
                                }).toList()),
                              ),
                            ),
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
                const SizedBox(
                  height: 12,
                ),
                Visibility(
                  visible: widget.withGroup == true,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Group:",
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(fontSize: 20)),
                        const SizedBox(
                          height: 14,
                        ),
                        groupDoc == null
                            ? MyTextField(
                                controller: groupTextController,
                                formKey: _formKey,
                                hintText: "Search by name...",
                                inputStyle:
                                    TextStyle(color: Colors.grey.shade700),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400)),
                                validatorText: "Please select a group",
                                onChangedVal: (input) async {
                                  if (groupsDocuments == null) {
                                    var docs = await DataBaseService()
                                        .messagesCollection
                                        .get();
                                    setState(() {
                                      groupsDocuments = docs;
                                    });
                                  }
                                  if (input != null && input.length > 3) {
                                    setState(() {
                                      DataBaseService().searchGroupsByName(
                                          groupSearchStream,
                                          input,
                                          groupsDocuments!);
                                    });
                                  } else {
                                    groupSearchStream.sink.add(null);
                                  }
                                },
                                validateCondition: (val, errorText) =>
                                    userDoc != null ? null : errorText)
                            : Column(
                                children: [
                                  Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface),
                                    child: ListTile(
                                      textColor: Colors.white,
                                      title: Text(
                                          groupDoc!.get("nadi_data")["name"]),
                                      subtitle: Text(
                                          groupDoc!.get("nadi_data")["email"]),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          groupDoc = null;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        height: 50,
                                        width: Size.infinite.width,
                                        child: const Center(
                                          child: Text("Reset",
                                              style: TextStyle(
                                                fontSize: 24,
                                                letterSpacing: 1.4,
                                              )),
                                        ),
                                      ))
                                ],
                              ),
                        const SizedBox(
                          height: 10,
                        ),
                        StreamBuilder(
                          stream: groupSearchStream.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var data = snapshot.data;
                              if (data == ConnectionState.waiting) {
                                // loading
                                return Container();
                              } else {
                                if (data is List) {
                                  if (data.isEmpty) {
                                    // no results found
                                    return const Text("No results found");
                                  }
                                  // there is data
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      width: Size.infinite.width,
                                      constraints: BoxConstraints.loose(
                                          const Size.fromHeight(210)),
                                      child: SingleChildScrollView(
                                        child: Column(
                                            children: data.map((e) {
                                          Map nadi = e.get("nadi_data");
                                          return GestureDetector(
                                            onTap: () => onGroupTapped(e),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints.tight(
                                                  Size(
                                                      Size.infinite.width, 70)),
                                              child: ListTile(
                                                dense: false,
                                                title: Text(nadi["name"]),
                                                subtitle: Text(nadi["email"]),
                                              ),
                                            ),
                                          );
                                        }).toList()),
                                      ),
                                    ),
                                  );
                                } else {
                                  // should be an error
                                  return const Text(
                                      "an unknown error has occured");
                                }
                              }
                            }
                            // data is null and there isnt anything in stream
                            return Container();
                          },
                        ),
                      ]),
                ),
                Visibility(
                    visible: widget.withClassDropdown,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("To:",
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(fontSize: 20)),
                        const SizedBox(
                          height: 14,
                        ),
                        MyDropdownField(
                            labelTextStyle: TextStyle(color: Colors.grey[700]),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    width: 1.4, color: Colors.grey.shade400)),
                            itemsList: const [
                              "Moderator",
                              "Admin",
                              "Co-Admin",
                              "User"
                            ],
                            onChanged: (val) {
                              setState(() {
                                switch (val) {
                                  case "Moderator":
                                    setState(() {
                                      dropDownClass = UserClass.moderator;
                                    });
                                    break;
                                  case "Admin":
                                    setState(() {
                                      dropDownClass = UserClass.admin;
                                    });
                                    break;
                                  case "Co-Admin":
                                    setState(() {
                                      dropDownClass = UserClass.coAdmin;
                                    });
                                    break;
                                  case "User":
                                    setState(() {
                                      dropDownClass = UserClass.user;
                                    });
                                    break;
                                  default:
                                }
                              });
                            },
                            labelText: "Class")
                      ],
                    )),
                const SizedBox(
                  height: 30,
                ),
                Visibility(
                    visible: (widget.withGroup == false
                            ? widget.withClassDropdown == true
                                ? dropDownClass != null
                                : true
                            : groupDoc != null) &&
                        userDoc != null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 40,
                              width: 90,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade700)),
                              child: const Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            )),
                        const SizedBox(
                          width: 30,
                        ),
                        GestureDetector(
                            onTap: () async {
                              createLoadingOverlay(context);
                              await widget.function!
                                      (userDoc!, groupDoc, dropDownClass)
                                  .then((success) {
                                removeOverlayEntry(context);
                                if (success) {
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg: widget.withClassDropdown
                                          ? "User successfully demoted"
                                          : "User successfully promoted");
                                }
                              });
                            },
                            child: Container(
                              height: 40,
                              width: 90,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).colorScheme.surface),
                              child: Center(
                                child: Text(
                                  (widget.withClassDropdown
                                      ? "Demote"
                                      : "Assign"),
                                  style: const TextStyle(
                                      fontSize: 17, color: Colors.white),
                                ),
                              ),
                            )),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onGroupTapped(DocumentSnapshot doc) {
    setState(() {
      groupDoc = doc;
    });

    // remove the groups shown
    groupSearchStream.sink.add(null);

    // remove the query text
    groupTextController.clear();
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

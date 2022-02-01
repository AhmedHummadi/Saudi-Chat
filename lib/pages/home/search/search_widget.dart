import 'dart:async';

import 'package:saudi_chat/models/location.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/chat/chat_page.dart';
import 'package:saudi_chat/services/chat.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:saudi_chat/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Map filters = {};
MyLocation? deviceLocation;

class SearchNadis extends StatefulWidget {
  const SearchNadis({Key? key}) : super(key: key);

  @override
  _SearchNadisState createState() => _SearchNadisState();
}

class _SearchNadisState extends State<SearchNadis> {
  final StreamController<List<DocumentSnapshot>?> _currentQuerySearchResults =
      StreamController();

  bool searching = false;
  List<String> filterCatagories = filters.isNotEmpty
      ? filters.entries
          .firstWhere((element) => element.key == "catagories")
          .value as List<String>
      : [];

  // 0 - Location services are disabled.
  // 1 - Location permissions are denied
  // 2 - Location permissions are permanently denied, we cannot request permissions.
  int? locationErrorType;

  // overlayEntry for requesting permission
  OverlayEntry? _locationPermissionOverlayEntry;

  void findDeviceLocation() async {
    if (deviceLocation == null) {
      var loc = await GeoLocation().getDeviceLocation();
      if (loc is int) {
        locationErrorType = loc;
        _locationPermissionOverlayEntry = OverlayEntry(builder: (context) {
          return Material(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.background),
                margin: const EdgeInsets.all(8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Please enable location services",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.surface)),
                          onPressed: () =>
                              _locationPermissionOverlayEntry!.remove(),
                          child: const Text(
                            "Ok",
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );
        });
        Overlay.of(context)!.insert(_locationPermissionOverlayEntry!);
      } else {
        deviceLocation = loc;
      }
    }
  }

  @override
  void initState() {
    findDeviceLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic streamedUser = Provider.of<UserAuth>(context);
    final controller = FloatingSearchBarController();

    return Theme(
      data: ThemeData(
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.cyan[600])),
      child: Stack(fit: StackFit.expand, children: [
        FloatingSearchBar(
          automaticallyImplyDrawerHamburger: false,
          controller: controller,
          progress: searching,
          queryStyle: const TextStyle(color: Colors.black),
          debounceDelay: const Duration(milliseconds: 200),
          hint: "Search by Nadi name...",
          onQueryChanged: (input) async {
            if (input.length <= 2) {
              _currentQuerySearchResults.sink.add(null);
            } else {
              setState(() {
                searching = true;
              });
              List<DocumentSnapshot>? searchResults = await DataBaseService()
                  .getSearchResultsFromBusinesses(
                      userLocation: deviceLocation, queryText: input);
              _currentQuerySearchResults.sink.add(searchResults!.length > 4
                  ? searchResults.getRange(0, 3).toList()
                  : searchResults);
              setState(() {
                searching = false;
              });
            }
          },
          builder: (context, animation) {
            return buildItem(context, streamedUser, controller);
          },
        ),
      ]),
    );
  }

  Widget buildItem(BuildContext context, dynamic streamedUser,
      FloatingSearchBarController controller) {
    return StreamBuilder<List<DocumentSnapshot>?>(
        stream: _currentQuerySearchResults.stream,
        builder: (context, snapshot) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              type: MaterialType.canvas,
              color: Colors.white,
              elevation: 4.0,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.hasData
                      ? snapshot.data!.isNotEmpty
                          ? snapshot.data!.map((search) {
                              Map data = search.data() as Map;
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      controller.close();
                                      await onItemTap(streamedUser, search);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: ListTile(
                                            title: Text(data["name"]),
                                            subtitle: Text(data["location"]),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  8,
                                              child: const Text(
                                                "Tap to chat",
                                                textAlign: TextAlign.center,
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    height: 0,
                                    thickness:
                                        snapshot.data!.last != search ? 0.5 : 0,
                                    color: Colors.grey,
                                  )
                                ],
                              );
                            }).toList()
                          : [
                              const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    "No results found",
                                    style: TextStyle(fontSize: 24),
                                  ))
                            ]
                      : []),
            ),
          );
        });
  }

  Future<void> onItemTap(streamedUser, DocumentSnapshot search) async {
    DocumentSnapshot userDoc =
        await DataBaseService().authUsersCollection.doc(streamedUser.uid).get();

    if (streamedUser.isAnonymous) {
      Navigator.pushNamed(context, "/login");
    } else {
      // first we check if the selected group is already opened by the user
      bool isChatboxOpen = await MessageDatabase().checkIfChatboxIsOpen(
          groupId: search.id, userGroups: userDoc.get("groups"));
      if (!isChatboxOpen) {
        // if no we add the user to the group
        DocumentReference groupDocument =
            await DataBaseService().addUserToNadiGroup(streamedUser, search.id);
        // then we push the user to the chat screen of the group
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatPage(
              groupDocument: groupDocument, bussinessDoc: search.reference);
        }));
      } else {
        // if yes then we simply push the user to the chat screen of the group
        DocumentReference documentReference =
            MessageDatabase().messagesCollection.doc(search.id);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatPage(
              groupDocument: documentReference, bussinessDoc: search.reference);
        }));
      }
    }
  }
}

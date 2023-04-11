import 'package:line_icons/line_icon.dart';
import 'package:saudi_chat/models/nadi.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/admin/control_panel.dart';
import 'package:saudi_chat/pages/chat/chat_list.dart';
import 'package:saudi_chat/pages/home/profile_page.dart';
import 'package:saudi_chat/pages/home/search/search_widget.dart';
import 'package:saudi_chat/pages/news/news_list.dart';
import 'package:saudi_chat/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/shared/widgets.dart';
import 'package:simple_animations/simple_animations.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // ignore: unused_field, prefer_final_fields
  int _currentIndex = 0;
  // ignore: unused_field, prefer_const_constructors

  List<BottomNavigationBarItem> navigationBaritems = const [
    BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home_filled)),
    // BottomNavigationBarItem(label: "Chat", icon: Icon(Icons.chat)),
    BottomNavigationBarItem(
      label: "Groups",
      icon: Icon(
        Icons.groups_rounded,
      ),
    )
  ];

  bool showSearch = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      HomePage(
        toggleSearch: toggleSearch,
      ),
      // ChatTab(toggleSearch: toggleSearch),
      GroupsPage(toggleSearch: toggleSearch),
    ];

    final dynamic streamUser = Provider.of<UserAuth>(context);

    final UserAuth streamedUser = streamUser;
    final List<Widget> appBarButtons = [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: GestureDetector(
          onTap: () {
            if (mounted) {
              print(Navigator.of(context).context);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ProfilePage(streamedUser: streamedUser);
              }));
              print(Navigator.of(context).context);
            }
          },
          child: Stack(alignment: Alignment.center, children: [
            Container(
              width: 42,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
            Icon(
              Icons.person_rounded,
              size: 32,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ]),
        ),
      )
    ];

    if (streamedUser.groups != null && streamUser.displayName! != null) {
      return Material(
        color: Colors.transparent,
        child: Stack(children: [
          Scaffold(
            bottomNavigationBar: BottomNavigationBar(
                unselectedItemColor: Colors.grey[600],
                selectedItemColor: Theme.of(context).colorScheme.primary,
                type: BottomNavigationBarType.shifting,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: streamedUser.userClass == UserClass.moderator ||
                        streamedUser.userClass == UserClass.admin
                    ? navigationBaritems +
                        [
                          BottomNavigationBarItem(
                              label: "Control Panel",
                              icon: LineIcon.usersCog(
                                size: 26,
                                color:
                                    _currentIndex == navigationBaritems.length
                                        ? Theme.of(context).primaryColorLight
                                        : Colors.grey[700],
                              ))
                        ]
                    : navigationBaritems),
            body: IndexedStack(
              index: _currentIndex,
              children: (streamedUser.userClass == UserClass.moderator
                      ? _pages + [const ModeratorPanelPage()]
                      : streamedUser.userClass == UserClass.admin
                          ? _pages + [const AdminPanelPage()]
                          : streamUser.userClass == UserClass.coAdmin
                              ? _pages + [const CoAdminPanelPage()]
                              : _pages)
                  .map((e) => ScrollConfiguration(
                        behavior: NoGlowScrollBehaviour(),
                        child: RefreshIndicator(
                          edgeOffset: 260,
                          color: Theme.of(context).colorScheme.secondary,
                          onRefresh: () async {
                            setState(() {});
                            await Future.delayed(
                                const Duration(milliseconds: 400));
                          },
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                AppBar(
                                  elevation: 1,
                                  actions: appBarButtons,
                                  shadowColor: Colors.white,
                                  iconTheme: IconThemeData(
                                      size: 30,
                                      color: Theme.of(context).primaryColor),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                e
                              ],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Visibility(
              visible: showSearch,
              child: GestureDetector(
                onTap: () => toggleSearch(),
                child: PlayAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 150),
                  tween: Tween(begin: 0.0, end: 0.4),
                  builder: (context, value, child) => Container(
                    color: Colors.black.withOpacity(value),
                  ),
                ),
              )),
          Offstage(
            offstage: !showSearch,
            child: SearchNadis(
              streamedUser: streamedUser,
              onPop: () => showSearch
                  ? setState(() => showSearch = false)
                  : Future.value(true),
            ),
          )
        ]),
      );
    } else {
      return const Scaffold(
        body: Center(
          child: Text("Loading..."),
        ),
      );
    }
  }

  void toggleSearch() {
    // add the search bar at the top of everything to join the club
    setState(() {
      showSearch = !showSearch;
    });
  }

  // Drawer buildDrawer(UserAuth streamedUser) {
  //   return Drawer(
  //     child: Padding(
  //       padding: EdgeInsets.fromLTRB(
  //           0, MediaQuery.of(context).size.height / 11, 0, 0),
  //       child: SingleChildScrollView(
  //         child: Column(
  //           children: [
  //             CircleAvatar(
  //               radius: 44,
  //               backgroundImage: Image.asset(
  //                 "assets/new_nadi_profile_pic.jpg",
  //               ).image,
  //             ),
  //             const SizedBox(
  //               height: 10,
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Center(
  //                   child: Column(
  //                 children: [
  //                   Text(
  //                     streamedUser.displayName!,
  //                     style: TextStyle(color: Colors.grey[800], fontSize: 20),
  //                   ),
  //                   Text(
  //                     streamedUser.email!,
  //                     style: TextStyle(color: Colors.grey[600], fontSize: 14),
  //                   ),
  //                 ],
  //               )),
  //             ),
  //             const Divider(
  //               color: Colors.grey,
  //               indent: 20,
  //               endIndent: 20,
  //               height: 20,
  //             ),
  //             InkWell(
  //               splashColor: Colors.grey[100],
  //               onTap: () async => await onProfileTapped(),
  //               child: Padding(
  //                 padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
  //                 child: Row(
  //                   children: [
  //                     Icon(Icons.person,
  //                         color: Theme.of(context).colorScheme.onBackground),
  //                     const SizedBox(
  //                       width: 20,
  //                     ),
  //                     Text(
  //                       "Profile",
  //                       style: TextStyle(
  //                           fontSize: 18,
  //                           color: Theme.of(context).colorScheme.onBackground),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             InkWell(
  //               splashColor: Colors.grey[100],
  //               onTap: () async => await onSettingsTapped(),
  //               child: Padding(
  //                 padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
  //                 child: Row(
  //                   children: [
  //                     Icon(Icons.settings_rounded,
  //                         color: Theme.of(context).colorScheme.onBackground),
  //                     const SizedBox(
  //                       width: 20,
  //                     ),
  //                     Text(
  //                       "Settings",
  //                       style: TextStyle(
  //                           fontSize: 18,
  //                           color: Theme.of(context).colorScheme.onBackground),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             InkWell(
  //               splashColor: Colors.grey[100],
  //               onTap: () async => await onSignoutTapped(),
  //               child: Padding(
  //                 padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
  //                 child: Row(
  //                   children: [
  //                     Icon(Icons.logout,
  //                         color: Theme.of(context).colorScheme.onBackground),
  //                     const SizedBox(
  //                       width: 20,
  //                     ),
  //                     Text(
  //                       "Sign Out",
  //                       style: TextStyle(
  //                           fontSize: 18,
  //                           color: Theme.of(context).colorScheme.onBackground),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> onSignoutTapped() async {
    showCustomAlertDialog(
        context, "Are you sure you want to Sign out?", "", "Sign out", null,
        () async {
      Navigator.pop(context);
      await AuthService().signOut();
    });
  }

  Future<void> onSettingsTapped() async {}
  Future<void> onProfileTapped() async {}
}

class GroupsPage extends StatelessWidget {
  final Function? toggleSearch;
  const GroupsPage({Key? key, required this.toggleSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final dynamic streamedUser = Provider.of<UserAuth>(context);
    return ListView.builder(
        itemCount: streamedUser.groups.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          Map groupData = streamedUser.groups[index];
          return ChatList(
              onAddGroupTapped: toggleSearch!,
              isHomeStyle: false,
              groupInfoCardData: groupData);
        });
  }
}

class ChatTab extends StatelessWidget {
  final Function? toggleSearch;
  const ChatTab({Key? key, this.toggleSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).size.height / 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "No Direct Messages",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 22),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            "Direct messages will appear here!",
            style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                fontSize: 16),
          ),
          const SizedBox(
            height: 10,
          ),
          Icon(
            Icons.message_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
          )
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Function? toggleSearch;
  const HomePage({Key? key, this.toggleSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dynamic streamedUser = Provider.of<UserAuth>(context);

    return ScrollConfiguration(
      behavior: NoGlowScrollBehaviour(),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 6,
            ),
            ScrollConfiguration(
              behavior: NoGlowScrollBehaviour(),
              child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ChatList(
                    onAddGroupTapped: toggleSearch!,
                    isHomeStyle: true,
                  ),
                ),
              ),
            ),
            ProfileIconButton(streamedUser: streamedUser),
            const SizedBox(
              height: 4,
            ),
            Divider(
              height: 10,
              indent: 20,
              thickness: 0.5,
              endIndent: 20,
              color: Colors.grey[500],
            ),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: NewsList(
                streamedUser: streamedUser,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileIconButton extends StatelessWidget {
  final UserAuth streamedUser;
  const ProfileIconButton({Key? key, required this.streamedUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ProfilePage(streamedUser: streamedUser);
          }));
        },
        child: Stack(alignment: Alignment.center, children: [
          Container(
            width: 42,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          Icon(
            Icons.person_rounded,
            size: 32,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ]),
      ),
    );
  }
}

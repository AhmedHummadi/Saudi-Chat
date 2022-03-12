import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/admin/control_panel.dart';
import 'package:saudi_chat/pages/chat/chat_list.dart';
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
    BottomNavigationBarItem(label: "Chat", icon: Icon(Icons.chat)),
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
    final List<Widget> _pages = [
      HomePage(
        toggleSearch: toggleSearch,
      ),
      ChatPage(toggleSearch: toggleSearch),
      const GroupsPage(),
    ];

    final dynamic streamUser = Provider.of<UserAuth>(context);

    final UserAuth streamedUser = streamUser;

    if (streamedUser.groups != null && streamUser.displayName! != null) {
      return Material(
        color: Colors.transparent,
        child: Stack(children: [
          Scaffold(
            bottomNavigationBar: BottomNavigationBar(
                unselectedItemColor: Colors.grey[600],
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
                          const BottomNavigationBarItem(
                              label: "Control Panel",
                              icon: Icon(Icons.person_outline))
                        ]
                    : navigationBaritems),
            drawer: buildDrawer(streamedUser),
            body: IndexedStack(
              index: _currentIndex,
              children: (streamedUser.userClass == UserClass.moderator
                      ? _pages + [const ModeratorPanelPage()]
                      : streamedUser.userClass == UserClass.admin
                          ? _pages + [const AdminPanelPage()]
                          : _pages)
                  .map((e) => SingleChildScrollView(
                        child: Column(
                          children: [AppBar(), e],
                        ),
                      ))
                  .toList(),
            ),
          ),
          Visibility(
              visible: showSearch,
              child: GestureDetector(
                onTap: () => toggleSearch(),
                child: PlayAnimation<double>(
                  duration: const Duration(milliseconds: 150),
                  tween: Tween(begin: 0.0, end: 0.4),
                  builder: (context, child, value) => Container(
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

  Drawer buildDrawer(UserAuth streamedUser) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            0, MediaQuery.of(context).size.height / 11, 0, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundImage: Image.asset(
                  "assets/new_nadi_profile_pic.jpg",
                ).image,
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Column(
                  children: [
                    Text(
                      streamedUser.displayName!,
                      style: TextStyle(color: Colors.grey[800], fontSize: 20),
                    ),
                    Text(
                      streamedUser.email!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                )),
              ),
              const Divider(
                color: Colors.grey,
                indent: 20,
                endIndent: 20,
                height: 20,
              ),
              InkWell(
                splashColor: Colors.grey[100],
                onTap: () async => await onProfileTapped(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: Row(
                    children: [
                      Icon(Icons.person,
                          color: Theme.of(context).colorScheme.onBackground),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Profile",
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                splashColor: Colors.grey[100],
                onTap: () async => await onSettingsTapped(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: Row(
                    children: [
                      Icon(Icons.settings_rounded,
                          color: Theme.of(context).colorScheme.onBackground),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Settings",
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                splashColor: Colors.grey[100],
                onTap: () async => await onSignoutTapped(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: Row(
                    children: [
                      Icon(Icons.logout,
                          color: Theme.of(context).colorScheme.onBackground),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Sign Out",
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSignoutTapped() async {
    Navigator.pop(context);
    await AuthService().signOut();
  }

  Future<void> onSettingsTapped() async {}
  Future<void> onProfileTapped() async {}
}

class GroupsPage extends StatelessWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final dynamic streamedUser = Provider.of<UserAuth>(context);
    return Container();
  }
}

class ChatPage extends StatelessWidget {
  final Function? toggleSearch;
  const ChatPage({Key? key, this.toggleSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatList(
      onAddGroupTapped: toggleSearch!,
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

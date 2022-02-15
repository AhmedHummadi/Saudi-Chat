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
  final List<Widget> _pages = const [
    HomePage(),
    ChatPage(),
    GroupsPage(),
  ];

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
            drawer: buildDrawer(),
            floatingActionButton: _currentIndex == 0
                ?
                // is on home page
                // show add chat group button
                FloatingActionButton.extended(
                    onPressed: () => toggleSearch(),
                    label: const Text("Join a Club"),
                    icon: const Icon(
                      Icons.add,
                      size: 28,
                    ),
                  )
                : null,
            appBar: AppBar(
              title: Text(_currentIndex == 0
                  ? "Home"
                  : _currentIndex == 1
                      ? "Chat"
                      : _currentIndex == 2
                          ? "Groups"
                          : "Control Panel"),
              centerTitle: true,
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: streamedUser.userClass == UserClass.moderator
                  ? _pages + [const ControlPanelPage()]
                  : streamedUser.userClass == UserClass.admin
                      ? _pages + [const AdminPanelPage()]
                      : _pages,
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
    print(showSearch);
  }

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
              child: Text(
            "Settings",
          )),
          ListTile(
            onTap: () async {
              Navigator.pop(context);
              await AuthService().signOut();
            },
            tileColor: Theme.of(context).colorScheme.surface,
            title: const Text(
              "Sign Out",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
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
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ChatList();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
              child: const SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: ChatList(
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

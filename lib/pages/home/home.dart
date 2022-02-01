import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/admin/control_panel.dart';
import 'package:saudi_chat/pages/chat/chat_list.dart';
import 'package:saudi_chat/pages/home/search/search_widget.dart';
import 'package:saudi_chat/pages/news/post_news_page.dart';
import 'package:saudi_chat/pages/news/news_list.dart';
import 'package:saudi_chat/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/shared/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    final dynamic streamUser = Provider.of<UserAuth>(context);
    final UserAuth streamedUser = streamUser;
    if (streamedUser.groups != null && streamUser.displayName! != null) {
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            unselectedItemColor: Colors.grey[600],
            type: BottomNavigationBarType.shifting,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: streamedUser.userClass == UserClass.moderator
                ? navigationBaritems +
                    [
                      const BottomNavigationBarItem(
                          label: "Control Panel",
                          icon: Icon(Icons.person_outline))
                    ]
                : navigationBaritems),
        drawer: buildDrawer(),
        floatingActionButton: _currentIndex == 2
            ?
            // is on news page
            // see if he is an Admin/Co-Admin to show the post news page
            streamedUser.groupsAdmin!.isNotEmpty
                ?
                // he is admin/co-admin
                FloatingActionButton(
                    tooltip: "Post a story",
                    child: Icon(
                      Icons.post_add_rounded,
                      color: Theme.of(context).colorScheme.surface,
                      size: 30,
                    ),
                    backgroundColor: Colors.white,
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                AddNewsPage(streamedUser: streamedUser))),
                  )
                // he is not admin
                : null
            // is on home page
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
              : _pages,
        ),
      );
    } else {
      return const Scaffold(
        body: Center(
          child: Text("Loading..."),
        ),
      );
    }
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
    final dynamic streamedUser = Provider.of<UserAuth>(context);
    return streamedUser.groups == null
        ? Container()
        : NewsList(streamedUser: streamedUser);
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

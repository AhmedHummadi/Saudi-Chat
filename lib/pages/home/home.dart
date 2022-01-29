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
    NewsPage(),
  ];

  List<BottomNavigationBarItem> navigationBaritems = const [
    BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home_filled)),
    BottomNavigationBarItem(label: "Chat", icon: Icon(Icons.chat)),
    BottomNavigationBarItem(
      label: "News",
      icon: Icon(
        Icons.article_outlined,
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
                      ? "News"
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

class NewsPage extends StatelessWidget {
  const NewsPage({Key? key}) : super(key: key);

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

    return Stack(fit: StackFit.loose, children: [
      SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(
              height: 69,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Material(
                borderRadius: BorderRadius.circular(20),
                elevation: 2,
                child: Container(
                  constraints: BoxConstraints.loose(const Size.fromHeight(150)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ScrollConfiguration(
                    behavior: NoGlowScrollBehaviour(),
                    child: const SingleChildScrollView(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: ChatList(
                          isHomeStyle: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  constraints: BoxConstraints.loose(const Size.fromHeight(360)),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: NewsList(
                      streamedUser: streamedUser,
                      isHomeStyle: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(child: SearchNadis()),
    ]);
  }
}

import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/chat/chat_list.dart';
import 'package:saudi_chat/pages/home/search/search_widget.dart';
import 'package:saudi_chat/pages/news/post_news_page.dart';
import 'package:saudi_chat/pages/news/news_list.dart';
import 'package:saudi_chat/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // ignore: unused_field, prefer_final_fields
  int _currentIndex = 0;
  // ignore: unused_field, prefer_const_constructors
  final List<Widget> _pages = [const HomePage(), NewsPage()];

  @override
  Widget build(BuildContext context) {
    final dynamic streamUser = Provider.of<UserAuth>(context);
    final UserAuth streamedUser = streamUser;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                label: "Home", icon: Icon(Icons.home_filled)),
            BottomNavigationBarItem(
              label: "News",
              icon: Icon(
                Icons.article_outlined,
              ),
            )
          ]),
      drawer: buildDrawer(),
      floatingActionButton: _currentIndex == 1
          ?
          // is on news page
          // see if he is an Admin to show the post news page
          streamedUser.nadiAdminDoc != null
              ?
              // he is admin
              FloatingActionButton(
                  tooltip: "Post a story",
                  child: Icon(
                    Icons.post_add_rounded,
                    color: Theme.of(context).colorScheme.surface,
                    size: 30,
                  ),
                  backgroundColor: Colors.white,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AddNewsPage(streamedUser: streamedUser))),
                )
              // he is not admin
              : null
          // is on home page
          : null,
      appBar: AppBar(
        title: Text(_currentIndex == 1 ? "News" : "Home"),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    );
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

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    final dynamic streamedUser = Provider.of<UserAuth>(context);
    return streamedUser.groups == null
        ? Container()
        : NewsList(streamedUser: streamedUser);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final dynamic streamedUser = Provider.of<UserAuth?>(context);

    return Stack(fit: StackFit.loose, children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 70,
          ),
          const Divider(
            thickness: 1,
            color: Colors.grey,
            height: 0,
          ),
          ChatList(
            streamedUser: streamedUser,
          ),
        ],
      ),
      const SizedBox(child: SearchNadis()),
    ]);
  }
}

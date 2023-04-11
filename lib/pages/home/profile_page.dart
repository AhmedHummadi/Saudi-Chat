import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/home/settings_page.dart';
import 'package:saudi_chat/services/auth.dart';

class _ButtonClass {
  late IconData icon;
  late String title;
  late Function onTap;

  _ButtonClass(this.icon, this.title, this.onTap);
}

List<_ButtonClass> _buttonlist = [
  _ButtonClass(Icons.settings, "Settings", (BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingsPage();
    }));
  }),
  _ButtonClass(Icons.logout, "Log out", () {
    AuthService().signOut();
  })
];

class ProfilePage extends StatelessWidget {
  final UserAuth streamedUser;
  const ProfilePage({Key? key, required this.streamedUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size pageSize = MediaQuery.of(context).size;

    final double dividerIndentSize = pageSize.width / 9;
    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              iconTheme: IconThemeData(size: 30),
              toolbarHeight: pageSize.height / 12,
            ),
            CircleAvatar(
              radius: 64,
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
                      style: TextStyle(color: Colors.grey[800], fontSize: 26),
                    ),
                    Text(
                      streamedUser.email!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 18),
                    ),
                  ],
                ))),
            Divider(
              indent: dividerIndentSize,
              endIndent: dividerIndentSize,
              color: Colors.grey,
              thickness: 1,
              height: pageSize.height / 12,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SettingsPage();
                  }));
                },
                child: SizedBox(
                    child: Row(children: [
                  Icon(
                    _buttonlist[0].icon,
                    size: 34,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    _buttonlist[0].title,
                    style: TextStyle(fontSize: 20),
                  )
                ]))),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  AuthService().signOut();
                },
                child: SizedBox(
                    child: Row(children: [
                  Icon(
                    _buttonlist[1].icon,
                    size: 34,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    _buttonlist[1].title,
                    style: TextStyle(fontSize: 20),
                  )
                ]))),
          ],
        ),
      ),
    );
    // return Scaffold(
    //     appBar: AppBar(
    //       backgroundColor: Colors.transparent,
    //       shadowColor: Colors.transparent,
    //       iconTheme: IconThemeData(size: 30),
    //       toolbarHeight: pageSize.height / 12,
    //     ),
    //     body: Column(children: [
    //       CircleAvatar(
    //         radius: 64,
    //         backgroundImage: Image.asset(
    //           "assets/new_nadi_profile_pic.jpg",
    //         ).image,
    //       ),
    //       const SizedBox(
    //         height: 10,
    //       ),
    //       Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Center(
    //               child: Column(
    //             children: [
    //               Text(
    //                 streamedUser.displayName!,
    //                 style: TextStyle(color: Colors.grey[800], fontSize: 26),
    //               ),
    //               Text(
    //                 streamedUser.email!,
    //                 style: TextStyle(color: Colors.grey[600], fontSize: 18),
    //               ),
    //             ],
    //           ))),
    //       Divider(
    //         indent: dividerIndentSize,
    //         endIndent: dividerIndentSize,
    //         color: Colors.grey,
    //         thickness: 1,
    //         height: pageSize.height / 12,
    //       ),
    //       const _ButtonsList()
    //     ]));
  }
}

class _ButtonsList extends StatelessWidget {
  const _ButtonsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buttonlist
          .map((buttonData) => _Button(buttonData: buttonData))
          .toList(),
    );
  }
}

class _Button extends StatelessWidget {
  final _ButtonClass buttonData;
  const _Button({Key? key, required this.buttonData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: buttonData.onTap(),
        child: SizedBox(
            child: Row(
                children: [Icon(buttonData.icon), Text(buttonData.title)])));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/admin/assign_admin.dart';
import 'package:saudi_chat/pages/admin/assign_mod.dart';
import 'package:saudi_chat/pages/admin/demote_user.dart';
import 'package:saudi_chat/pages/news/post_news_page.dart';
import 'package:saudi_chat/shared/widgets.dart';

class _MainControlPanel extends StatelessWidget {
  final bool assignAdmin;
  final bool assignModerator;
  final bool postNews;
  final bool demoteUser;
  const _MainControlPanel(
      {Key? key,
      required this.demoteUser,
      required this.assignAdmin,
      required this.assignModerator,
      required this.postNews})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserAuth streamedUser = Provider.of<UserAuth>(context);
    return Column(
      children: [
        Visibility(
          visible: assignAdmin,
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
                    color: Colors.grey[700],
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  Text(
                    "Assign admin to group",
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 20, color: Colors.grey[700]),
                  )
                ],
              )),
        ),
        Visibility(
          visible: assignModerator,
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
                    color: Colors.grey[700],
                  ),
                  const SizedBox(
                    width: 42,
                  ),
                  Text(
                    "Assign moderator",
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 20, color: Colors.grey[700]),
                  )
                ],
              )),
        ),
        Visibility(
          visible: demoteUser,
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
                    color: Colors.grey[700],
                  ),
                  const SizedBox(
                    width: 42,
                  ),
                  Text(
                    "Demote User",
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 20, color: Colors.grey[700]),
                  )
                ],
              )),
        ),
        Visibility(
          visible: postNews,
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
                    color: Colors.grey[700],
                  ),
                  const SizedBox(
                    width: 42,
                  ),
                  Text(
                    "Post news",
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 20, color: Colors.grey[700]),
                  )
                ],
              )),
        ),
      ],
    );
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
        postNews: true);
  }
}

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _MainControlPanel(
        demoteUser: false,
        assignAdmin: true,
        assignModerator: false,
        postNews: true);
  }
}

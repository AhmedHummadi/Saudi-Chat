import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/admin/assign.dart';
import 'package:saudi_chat/pages/admin/assign_admin.dart';
import 'package:saudi_chat/pages/admin/assign_mod.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:saudi_chat/shared/widgets.dart';

class ControlPanelPage extends StatelessWidget {
  const ControlPanelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserAuth streamedUser = Provider.of<UserAuth>(context);
    return Column(
      children: [
        ScreenWidthCard(
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
                const Icon(
                  Icons.person_add_alt_1,
                  size: 38,
                ),
                const SizedBox(
                  width: 60,
                ),
                Text(
                  "Assign admin to group",
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 21),
                )
              ],
            )),
        ScreenWidthCard(
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
                const Icon(
                  Icons.add_moderator,
                  size: 36,
                ),
                const SizedBox(
                  width: 74,
                ),
                Text(
                  "Assign moderator",
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 21),
                )
              ],
            )),
      ],
    );
  }
}

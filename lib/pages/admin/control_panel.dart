import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/admin/assign_admin.dart';
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
                return AssignAdminPage(streamedUser: streamedUser);
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
                  size: 40,
                ),
                const SizedBox(
                  width: 34,
                ),
                Text(
                  "Assign admin to group",
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 26),
                )
              ],
            ))
      ],
    );
  }
}

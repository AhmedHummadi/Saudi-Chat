import 'package:flutter/material.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/admin/assign.dart';
import 'package:saudi_chat/services/controls.dart';

class DemoteUser extends StatelessWidget {
  final UserAuth streamedUser;
  const DemoteUser({Key? key, required this.streamedUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AssignPage(
        streamedUser: streamedUser,
        withGroup: false,
        withClassDropdown: true,
        appBarTitle: "Demote User",
        function: (userDoc, groupDoc, userClass) async =>
            await ControlsService()
                .demoteUser(userDoc, userClass!, streamedUser));
  }
}

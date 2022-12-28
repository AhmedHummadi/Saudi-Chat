import 'package:flutter/material.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/admin/assign.dart';
import 'package:saudi_chat/services/controls.dart';

class AssignCoAdmin extends StatelessWidget {
  final UserAuth streamedUser;
  const AssignCoAdmin({Key? key, required this.streamedUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AssignPage(
      streamedUser: streamedUser,
      withGroup: true,
      withClassDropdown: false,
      appBarTitle: "Assign Co-Admin",
      function: (userDoc, groupDoc, userCLass) async =>
          await ControlsService().assignCoAdmin(userDoc, groupDoc!),
    );
  }
}

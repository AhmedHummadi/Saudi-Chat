import 'package:flutter/material.dart';
import 'package:saudi_chat/pages/admin/assign.dart';
import 'package:saudi_chat/services/controls.dart';

class AssignMod extends StatefulWidget {
  final dynamic streamedUser;
  const AssignMod({Key? key, this.streamedUser}) : super(key: key);

  @override
  _AssignModState createState() => _AssignModState();
}

class _AssignModState extends State<AssignMod> {
  @override
  Widget build(BuildContext context) {
    return AssignPage(
      streamedUser: widget.streamedUser,
      withGroup: false,
      function: (userDoc, groupDoc, userClass) async =>
          await ControlsService().assignModerator(userDoc),
      appBarTitle: "Assign Moderator",
      withClassDropdown: false,
    );
  }
}

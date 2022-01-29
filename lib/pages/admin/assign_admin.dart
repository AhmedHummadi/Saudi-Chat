import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/admin/assign.dart';
import 'package:saudi_chat/services/database.dart';

class AssignAdmin extends StatelessWidget {
  final UserAuth streamedUser;
  const AssignAdmin({Key? key, required this.streamedUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AssignPage(
      streamedUser: streamedUser,
      withGroup: true,
      assignFunction: (userDoc, groupDoc) async =>
          await DataBaseService().assignAdmin(userDoc, groupDoc!),
    );
  }
}

import 'package:saudi_chat/models/user.dart';
import 'package:flutter/material.dart';
import 'package:saudi_chat/pages/home/home.dart';
import 'package:saudi_chat/pages/auth/authenticate.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/services/auth.dart';
import 'package:saudi_chat/services/database.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic streamedUser = Provider.of<UserAuth?>(context);
    // return either home or authenticate widget
    if (streamedUser == null) {
      // ignore: prefer_const_constructors
      return Authenticate();
    } else {
      // ignore: prefer_const_constructors
      return StreamProvider<UserAuth>.value(
          value: DataBaseService(
                  uid: streamedUser.uid ?? AuthService().auth.currentUser!.uid)
              .userAuthStream,
          initialData: streamedUser,
          catchError: (context, error) {
            print(error);
            return streamedUser;
          },
          child: const Home());
    }
  }
}

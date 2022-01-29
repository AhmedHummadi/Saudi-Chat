import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/wrapper.dart';
import 'package:saudi_chat/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.~
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserAuth?>.value(
      value: AuthService().authStream,
      initialData: null,
      catchError: (_, error) {
        print(error);
        return null;
      },
      child: MaterialApp(
          title: 'Saudi Chat',
          themeMode: ThemeMode.system,
          theme: ThemeData(
              fontFamily: "Roboto",
              primaryColor: const Color(0xff009688),
              backgroundColor: Colors.white.withOpacity(0.7),
              primaryColorDark: const Color(0xff004d40),
              primaryColorLight: const Color(0xffB2DFDB),
              popupMenuTheme: PopupMenuThemeData(
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
              ),
              colorScheme: const ColorScheme(
                  primary: Color(0xff009688),
                  primaryVariant: Color(0xff00695C),
                  secondary: Color(0xff00BCD4),
                  secondaryVariant: Color(0xff45B4B2),
                  surface: Color(0xff26A69A),
                  background: Color(0xffF5F5F5),
                  error: Color(0xffEF5350),
                  onPrimary: Color(0xffffffff),
                  onSecondary: Color(0xffffffff),
                  onSurface: Color(0xffffffff),
                  onBackground: Color(0xff424242),
                  onError: Color(0xffffffff),
                  brightness: Brightness.light),
              textTheme: TextTheme(
                  headline1: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade900),
                  caption: TextStyle(color: Colors.grey[700]),
                  bodyText1: const TextStyle(fontSize: 26),
                  bodyText2: TextStyle(
                      color: Colors
                          .grey.shade800), // for text message names and time
                  headline2: TextStyle(color: Colors.teal.shade700),
                  headline3: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w500), // for chat list text
                  button: const TextStyle(color: Color(0xff0A6F65))),
              textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Colors.grey,
                  selectionColor: Colors.white.withOpacity(0.4),
                  selectionHandleColor: Colors.teal.shade200)),
          home: const Wrapper()),
    );
  }
}

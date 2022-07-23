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
              appBarTheme: const AppBarTheme(
                elevation: 0,
                titleTextStyle: TextStyle(fontSize: 18),
                backgroundColor: Colors.teal,
              ),
              fontFamily: "Roboto",
              primaryColor: const Color(0xff009688),
              backgroundColor: Colors.white.withOpacity(0.7),
              primaryColorDark: const Color(0xFF004D40),
              primaryColorLight: const Color(0xffB2DFDB),
              popupMenuTheme: PopupMenuThemeData(
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                  backgroundColor: const Color(0xff26A69A),
                  extendedTextStyle:
                      const TextStyle(fontSize: 17, letterSpacing: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              colorScheme: const ColorScheme(
                  primary: Color(0xff009688),
                  primaryContainer: Color(0xff00695C),
                  secondary: Color(0xff00BCD4),
                  secondaryContainer: Color(0xffE2FEC6),
                  surface: Color(0xff26A69A),
                  surfaceVariant: Color.fromARGB(255, 207, 230, 228),
                  background: Color(0xffFBFBFB),
                  onSurfaceVariant: Color.fromARGB(255, 231, 231, 231),
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
                      color: Colors.grey.shade800), // for text message names
                  headline5: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic), // for text message time,
                  headline6: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 16), // for text messages
                  headline2: TextStyle(color: Colors.teal.shade700),
                  headline3: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w500), // for chat list text
                  button: const TextStyle(color: Color(0xff0A6F65))),
              textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Colors.white,
                  selectionColor: Colors.white.withOpacity(0.4),
                  selectionHandleColor: Colors.teal.shade200)),
          home: const Wrapper()),
    );
  }
}

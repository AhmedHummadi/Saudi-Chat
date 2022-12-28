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
          debugShowCheckedModeBanner: false,
          title: 'Saudi Chat',
          themeMode: ThemeMode.system,
          theme: ThemeData(
              appBarTheme: AppBarTheme(
                  elevation: 2,
                  shadowColor: Colors.white,
                  titleTextStyle:
                      TextStyle(fontSize: 18, color: Colors.grey[800]),
                  backgroundColor: Color.fromARGB(255, 229, 228, 224),
                  foregroundColor: Colors.grey[800],
                  iconTheme: IconThemeData(color: Colors.grey[800])),
              fontFamily: "Ubuntu",
              primaryColor: const Color(0xff305A73),
              backgroundColor: const Color(0xffF5F1E0),
              primaryColorDark: const Color(0xff2D4C5E),
              primaryColorLight: const Color(0xff427C9E),
              popupMenuTheme: PopupMenuThemeData(
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                  backgroundColor: Color.fromARGB(255, 143, 87, 180),
                  extendedTextStyle:
                      const TextStyle(fontSize: 17, letterSpacing: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              colorScheme: const ColorScheme(
                  secondary: Color(0xff836699),
                  secondaryContainer: Color(0xff5C4969),
                  primary: Color(0xff305A73),
                  primaryContainer: Color(0xff12374C),
                  tertiary: Color(0xffE1D7B7),
                  tertiaryContainer: Color(0xffAA975A),
                  surface: Color(0xffF5F1E0),
                  surfaceTint: Color.fromARGB(255, 235, 234, 232),
                  surfaceVariant: Color(0xffB58AD1),
                  background: Color.fromARGB(255, 251, 251, 251),
                  onSurfaceVariant: Color.fromARGB(255, 231, 231, 231),
                  error: Color.fromARGB(255, 223, 184, 75),
                  onPrimary: Color.fromARGB(255, 236, 236, 236),
                  onSecondary: Color(0xffffffff),
                  onSurface: Color.fromARGB(255, 62, 62, 62),
                  onBackground: Color.fromARGB(255, 120, 122, 122),
                  onError: Color(0xffffffff),
                  brightness: Brightness.light),
              textTheme: TextTheme(
                  headline1: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey
                          .shade900), // Main headear e.g."Home" text for home page
                  caption: TextStyle(color: Colors.grey[700]),
                  bodyText1: const TextStyle(fontSize: 26),
                  bodyText2: TextStyle(
                      fontFamily: "Roboto",
                      color: Colors.grey.shade800), // for text message names
                  headline4: TextStyle(
                      fontSize: 10,
                      fontFamily: "Roboto",
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic), // for text message time,
                  headline5: TextStyle(
                      fontFamily: "Roboto",
                      color: Colors.grey[900],
                      fontSize: 16), // for text messages (Other Users)
                  headline6: TextStyle(
                      fontFamily: "Roboto",
                      color: Colors.grey[100],
                      fontSize: 16), // for text messages (Users message)
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

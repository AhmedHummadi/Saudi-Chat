import 'package:saudi_chat/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:saudi_chat/services/auth.dart';
import 'package:saudi_chat/shared/loadingWidget.dart';

// ignore: must_be_immutable
class SignIn extends StatefulWidget {
  late Function? toggle;
  SignIn({Key? key, this.toggle}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  String? signinPassword;
  String? signinEmail;
  bool obscureText = true;
  IconData eyeIcon = Icons.visibility_off;
  String errorMessage = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryVariant,
        elevation: 0.7,
        title: const Text("Sign In"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).primaryColor),
              width: MediaQuery.of(context).size.width / 1.8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Center(
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                errorMessage,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            emailField(),
                            const SizedBox(height: 20),
                            passwordStack(),
                            const SizedBox(
                              height: 30,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      createLoadingOverlay(context);
                                    });
                                    dynamic signEPUser =
                                        await _auth.signInWithEmailAndPassword(
                                            email: signinEmail!.trim(),
                                            password: signinPassword!);
                                    if (signEPUser == null) {
                                      setState(() {
                                        errorMessage =
                                            "Couldn't sign in with these credentials";
                                      });
                                    }
                                    removeOverlayEntry(context);
                                  }
                                },
                                child: Text(
                                  "Sign In",
                                  style: Theme.of(context).textTheme.button,
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.grey[100]),
                                )),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ))),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an Account?",
                  style: TextStyle(inherit: false, color: Colors.black),
                ),
                SizedBox(
                  height: 20,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () => widget.toggle!(),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xff1796F6),
                              fontWeight: FontWeight.w500),
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  MyTextField emailField() {
    return MyTextField(
      formKey: _formKey,
      labelText: "Email",
      validatorText: "Enter an email",
      border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white)),
      onChangedVal: (val) {
        setState(() {
          signinEmail = val!;
        });
      },
      validateCondition: (val, errorText) =>
          val!.contains("@") && val.contains(".") && val.isNotEmpty
              ? null
              : errorText,
    );
  }

  MyTextField passwordField() {
    return MyTextField(
        formKey: _formKey,
        obscureText: obscureText,
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        validatorText: "Enter a Password 5+ characters",
        labelText: "Password",
        validateCondition: (val, errorText) =>
            val!.length > 5 ? null : errorText,
        onChangedVal: (val) {
          setState(() {
            signinPassword = val!;
          });
        });
  }

  Stack passwordStack() {
    return Stack(
      children: <Widget>[
        passwordField(),
        IconButton(
            color: Colors.white,
            alignment: Alignment.centerLeft,
            onPressed: () {
              setState(() {
                obscureText = !obscureText;
                eyeIcon = eyeIcon == Icons.visibility
                    ? Icons.visibility_off
                    : Icons.visibility;
              });
            },
            icon: Icon(eyeIcon))
      ],
      alignment: Alignment.centerRight,
    );
  }
}

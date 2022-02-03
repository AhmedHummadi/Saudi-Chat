import 'package:saudi_chat/services/auth.dart';
import 'package:saudi_chat/shared/constants.dart';
import 'package:saudi_chat/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:saudi_chat/shared/loadingWidget.dart';

// ignore: must_be_immutable
class Register extends StatefulWidget {
  late Function? toggle;
  Register({Key? key, this.toggle}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  String? registerPassword;
  String? registerEmail;
  String? registerName;
  String? registerPhoneNum;
  List<String> registerCities = [];
  bool obscureText = true;
  IconData eyeIcon = Icons.visibility_off;
  String errorMessage = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryVariant,
          elevation: 0.7,
          title: const Text("Register"),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryVariant,
                                        fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                nameField(),
                                const SizedBox(height: 10),
                                emailField(),
                                const SizedBox(height: 10),
                                passwordStack(),
                                const SizedBox(
                                  height: 10,
                                ),
                                cityDropDown(),
                                const SizedBox(height: 10),
                                phoneNumberField(),
                                const SizedBox(
                                  height: 30,
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          createLoadingOverlay(context);
                                        });
                                        dynamic registerEPresult = await _auth
                                            .registerWithEmailAndPassword(
                                                email: registerEmail!.trim(),
                                                password: registerPassword!,
                                                name: registerName!,
                                                city: registerCities,
                                                phoneNum: registerPhoneNum!);
                                        if (registerEPresult == null) {
                                          setState(() {
                                            errorMessage =
                                                "Please supply valid credintals";
                                          });
                                        }
                                        removeOverlayEntry(context);
                                      }
                                    },
                                    child: Text(
                                      "Register",
                                      style: Theme.of(context).textTheme.button,
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
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
                      "Already have an account?",
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
                              "Sign In",
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
        ),
      ),
    );
  }

  MyTextField nameField() {
    return MyTextField(
      formKey: _formKey,
      border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white)),
      labelText: "Name",
      validatorText: "Enter a name",
      validateCondition: (val, errorText) =>
          val!.isEmpty || val.length <= 1 ? errorText : null,
      onChangedVal: (val) {
        setState(() => registerName = val!);
      },
    );
  }

  MyTextField emailField() {
    return MyTextField(
      formKey: _formKey,
      labelText: "Email",
      border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white)),
      validatorText: "Enter an email",
      onChangedVal: (val) {
        setState(() {
          registerEmail = val!;
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
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        formKey: _formKey,
        obscureText: obscureText,
        validatorText: "Enter a Password 5+ characters",
        labelText: "Password",
        validateCondition: (val, errorText) =>
            val!.length > 5 && val.isNotEmpty ? null : errorText,
        onChangedVal: (val) {
          setState(() {
            registerPassword = val!;
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

  Widget cityDropDown() {
    return Column(
      children: [
        MyDropdownField(
            validatorText: "Please choose a city",
            itemsList: cities,
            fillColor: Colors.white.withOpacity(0.8),
            border: const OutlineInputBorder(borderSide: BorderSide.none),
            onChanged: (catagory) {
              if (!registerCities.contains(catagory.toString())) {
                setState(() {
                  registerCities.add(catagory.toString());
                });
              }
            },
            labelText: "Cities"),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: registerCities.map((e) {
                return InkWell(
                  splashColor: Colors.white.withOpacity(0),
                  onTap: () {
                    setState(() {
                      registerCities.remove(e);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 2.5, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                              child: Icon(
                                Icons.remove_circle,
                                color: Theme.of(context).primaryColor,
                                size: 18,
                              ),
                            ),
                            Text(e,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor))
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ))
      ],
    );
  }

  MyTextField phoneNumberField() {
    return MyTextField(
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        formKey: _formKey,
        validatorText: "Enter a Phone number with your country code",
        labelText: "Phone Number",
        validateCondition: (val, errorText) =>
            val!.startsWith("+") && val.isNotEmpty ? null : errorText,
        onChangedVal: (val) {
          setState(() {
            registerPhoneNum = val!;
          });
        });
  }
}

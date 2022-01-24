import 'dart:async';

import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  UserAuth _authUserFromFirebaseUser(User? user) {
    return UserAuth(
        uid: user!.uid,
        creationTime: user.metadata.creationTime,
        lastSignInTime: user.metadata.lastSignInTime,
        isAnonymous: user.isAnonymous,
        userClass: UserClass.user,
        displayName: user.displayName,
        email: user.email);
  }

  Stream<UserAuth> get streamedUser {
    return auth.currentUser != null
        ? DataBaseService(uid: auth.currentUser!.uid).userAuthStream
        : auth.authStateChanges().map(_authUserFromFirebaseUser);
  }

  Stream<UserAuth?> get authStream {
    return auth.authStateChanges().map(_authUserFromFirebaseUser);
  }

  // sign in anon
  Future signinAnon() async {
    try {
      UserCredential _anonResult = await auth.signInAnonymously();
      User? anonymousUser = _anonResult.user;
      return _authUserFromFirebaseUser(anonymousUser);
    } catch (e) {
      print(e.toString()); // TODO: Test
      return null;
    }
  }

  // change user display name
  void changeUserDisplayName({required String name, required User user}) async {
    try {
      await user.updateDisplayName(name);
    } catch (e) {
      print(e.toString()); // TODO: Test
    }
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(
      {required String email, required String password, S}) async {
    try {
      UserCredential _registerEPResult = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? signedInUserEP = _registerEPResult.user;

      return signedInUserEP;
    } catch (e) {
      print(e.toString()); // TODO: Test
      return null;
    }
  }

  // register with email and password

  Future registerWithEmailAndPassword(
      {required String email,
      required String password,
      required String name,
      required List<String> city,
      required String phoneNum}) async {
    try {
      UserCredential _registerEPResult = await auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? createdUserEP = _registerEPResult.user;
      createdUserEP!.updateDisplayName(name);
      // create new document for the user
      DataBaseService(uid: createdUserEP.uid).createUserAuthData(
          userAuth: UserAuth(
        uid: createdUserEP.uid,
        cities: city,
        isAnonymous: false,
        creationTime: createdUserEP.metadata.creationTime,
        lastSignInTime: createdUserEP.metadata.lastSignInTime,
        displayName: name,
        email: createdUserEP.email,
        phoneNum: phoneNum,
      ));

      return _authUserFromFirebaseUser(createdUserEP);
    } catch (e) {
      print(e.toString()); // TODO: Test
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await auth.signOut();
    } catch (e) {
      print(e.toString()); // TODO: Test
      return null;
    }
  }

  // delete user
  Future deleteAccount() async {
    try {
      await DataBaseService(uid: auth.currentUser!.uid).deleteUserDocument();
      return await auth.currentUser!.delete();
    } catch (e) {
      print(e.toString()); // TODO: Test
      return null;
    }
  }
}

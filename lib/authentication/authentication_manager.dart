import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:adoptandlove/preferences/app_preferences.dart';

class AuthenticationManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final AuthenticationManager _singleton =
      new AuthenticationManager._internal();

  factory AuthenticationManager() {
    return _singleton;
  }

  AuthenticationManager._internal();

  final _appPreferences = AppPreferences();

  Future<bool> isLoggedIn() async {
    return (await getCurrentUser()) != null;
  }

  Future<User> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<String> getIdToken() async {
    final currentUser = await getCurrentUser();
    final idTokenResult = await currentUser?.getIdToken(true);

    return idTokenResult;
  }

  StreamSubscription<User> listenForUser(void onData(User firebaseUser),
      {Function onError, void onDone(), bool cancelOnError}) {
    return _auth.authStateChanges().listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  Future logout() async {
    await FirebaseAuth.instance.signOut();
    await _appPreferences.removeApiToken();
  }
}

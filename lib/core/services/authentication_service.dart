import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/enums/user_type.dart';
import 'package:shram/core/models/user.dart';
import 'package:shram/core/services/services.dart';
import 'package:http/http.dart' as http;

class AuthenticationService extends Services {
  bool isLoggedIn = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserType userType;
  StreamController<Auth.User> fireBaseUserStream =
      StreamController<Auth.User>();
  StreamController<bool> isUserLoggedInStream = StreamController<bool>();
  StreamController<UserType> userTypeStream = StreamController<UserType>();

  AuthenticationService() {
    // firestore.clearPersistence();
    _isLoggedInUser().then((value) => isLoggedIn = value);
    _userType().then((value) => userType = value);
  }

  Future signInWithGoogle() async {
    sharedPreferencesHelper.clearAllData();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final Auth.AuthCredential credential = Auth.GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final Auth.UserCredential authResult =
        await auth.signInWithCredential(credential);
    final Auth.User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      firebaseUser = auth.currentUser;
      assert(user.uid == firebaseUser.uid);

      _saveLogin(user);

      // print('signInWithGoogle succeeded: $user');
    }
  }

  void _saveLogin(Auth.User user) {
    isLoggedIn = true;
    fireBaseUserStream.sink.add(firebaseUser);
    isUserLoggedInStream.add(isLoggedIn);
    sharedPreferencesHelper.setLoggedInUserId(user.uid);
  }

  Future registerUser(User user) async {
    firestore.runTransaction((tx) async {
      final counterResponse = await userCounterRef.get().catchError((err) {
        print('LOL');
      });
      user.id = 'U${counterResponse.data()['count']}';
      await userCollectionRef.doc(firebaseUser.uid).set(user.toMap());
      await userCounterRef.update({'count': FieldValue.increment(1)});
    }).catchError((err) {
      throw err;
    });
    _saveRegisteredUser(user);
  }

  void _saveRegisteredUser(User user) {
    sharedPreferencesHelper.setUserDetails(json.encode(user.toMap()));
  }

  Future<bool> checkIsRegisteredFromCache() async {
    String userData = await sharedPreferencesHelper.getUserDetails();
    if (userData.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<ResultType> isRegistered() async {
    // await sharedPreferencesHelper.setUserDetails('');
    String userData = await sharedPreferencesHelper.getUserDetails();
    if (userData.isEmpty && firebaseUser != null) {
      // check if user is registered in firebase
      try {
        var doc = await userCollectionRef
            .doc(firebaseUser.uid)
            .get()
            .timeout(Duration(seconds: integer.fetch_timeout));
        if (!doc.exists) {
          return ResultType.UNSUCCESSFUL;
        }
        _saveRegisteredUser(User.fromMap(doc.data()));
        return ResultType.SUCCESSFUL;
      } catch (err) {
        print(err);
      }
      // save registered user
    }
    return ResultType.SUCCESSFUL;
  }

  Future<bool> _isLoggedInUser() async {
    await getFirebaseUser();
    fireBaseUserStream.add(firebaseUser);
    isLoggedIn = firebaseUser == null ? false : true;
    isUserLoggedInStream.add(isLoggedIn);
    return isLoggedIn;
  }

  Future<UserType> _userType() async {
    userType = await sharedPreferencesHelper.getUserType();
    userTypeStream.add(userType);
    return userType;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    isLoggedIn = false;
    isUserLoggedInStream.add(false);
    fireBaseUserStream.add(null);
    userTypeStream.add(UserType.UNKNOWN);
    await sharedPreferencesHelper.clearAllData();
    print("User Signed Out");
  }
}

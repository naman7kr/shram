import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/enums/user_type.dart';
import 'package:shram/core/models/user.dart';
import 'package:shram/core/services/services.dart';

class AuthenticationService extends Services {
  bool isLoggedIn = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserType _userType;
  User user;
  StreamController<Auth.User> fireBaseUserStream =
      StreamController<Auth.User>();
  StreamController<bool> isUserLoggedInStream = StreamController<bool>();
  StreamController<UserType> userTypeStream = StreamController<UserType>();

  AuthenticationService() {
    // firestore.clearPersistence();
    try {
      isLoggedInUser().then((value) => isLoggedIn = value);
      userType().then((value) => _userType = value);
      getUser().then((value) => this.user = value);
    } catch (err) {
      print('LOL');
    }
  }

  User get userInfo {
    return this.user;
  }

  UserType get getUserType {
    return _userType;
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

  Future<bool> checkIfMobileAlreadyExists(String phone) async {
    var result = await userCollectionRef.where('phone', isEqualTo: phone).get();
    if (result.size != 0) return true;
    return false;
  }

  void _saveLogin(Auth.User user) {
    isLoggedIn = true;
    fireBaseUserStream.sink.add(firebaseUser);
    isUserLoggedInStream.add(isLoggedIn);
    sharedPreferencesHelper.setLoggedInUserId(user.uid);
  }

  Future registerUser(User user) async {
    firestore.runTransaction((tx) async {
      final counterResponse = await userCounterRef.get();
      if (counterResponse.exists) {
        user.id = 'U${counterResponse.data()['count']}';
      } else {
        await userCounterRef.set({'count': 1});
        user.id = 'U1';
      }
      await userCounterRef.update({'count': FieldValue.increment(1)});
      await userCollectionRef.doc(firebaseUser.uid).set(user.toMap());
    }).catchError((err) {
      throw err;
    });
    _saveRegisteredUser(user);
  }

  void _saveRegisteredUser(User user) {
    sharedPreferencesHelper.setUserDetails(json.encode(user.toMap()));
    sharedPreferencesHelper
        .setUserType(user.isAdmin ? UserType.ADMIN : UserType.USER);
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
    // String userData = await sharedPreferencesHelper.getUserDetails();

    // check if user is registered in firebase
    try {
      var doc = await userCollectionRef
          .doc(Auth.FirebaseAuth.instance.currentUser.uid)
          .get()
          .timeout(Duration(seconds: integer.fetch_timeout));
      if (!doc.exists) {
        return ResultType.UNSUCCESSFUL;
      }
      _saveRegisteredUser(User.fromMap(doc.data()));
      // print(doc.data());
      return ResultType.SUCCESSFUL;
    } catch (err) {
      print(err);
    }
    // save registered user
    return ResultType.SUCCESSFUL;
  }

  Future<bool> isLoggedInUser() async {
    await getFirebaseUser();
    fireBaseUserStream.add(firebaseUser);
    isLoggedIn = firebaseUser == null ? false : true;
    isUserLoggedInStream.add(isLoggedIn);
    return isLoggedIn;
  }

  Future<UserType> userType() async {
    _userType = await sharedPreferencesHelper.getUserType();
    if (_userType == UserType.UNKNOWN) {
      String details = await sharedPreferencesHelper.getUserDetails();
      if (details != null && details.isNotEmpty) {
        // print(details);
        User user = User.fromMap(json.decode(details));
        _userType = UserTypeHelper.getEnum(user.isAdmin ? 'ADMIN' : 'USER');
        await sharedPreferencesHelper.setUserType(_userType);
      }
    }
    userTypeStream.add(_userType);
    return _userType;
  }

  Future<User> getUser() async {
    String details = await sharedPreferencesHelper.getUserDetails();
    if (details.isEmpty) {
      return null;
    }
    return User.fromMap(json.decode(details));
  }

  Future signOutGoogle() async {
    await googleSignIn.signOut();
    await Auth.FirebaseAuth.instance.signOut();

    isLoggedIn = false;
    isUserLoggedInStream.add(false);
    fireBaseUserStream.add(null);
    userTypeStream.add(UserType.UNKNOWN);
    await sharedPreferencesHelper.clearAllData();
    print("User Signed Out");
  }
}

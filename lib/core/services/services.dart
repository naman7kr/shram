import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:flutter/services.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/helpers/sharedpreference_helper.dart';
import 'package:shram/core/services/server.dart';
import 'package:shram/locator.dart';
import 'package:shram/core/models/user.dart';

class Services {
  SharedPreferenceHelper _sharedPreferenceHelper =
      locator<SharedPreferenceHelper>();

  static Auth.FirebaseAuth _auth = Auth.FirebaseAuth.instance;

  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Auth.User firebaseUser;
  User _user;

  CollectionReference _userCollectionRef = _firestore.collection('Users');
  CollectionReference _workersRef = _firestore.collection('Workers');
  CollectionReference _categoriesRef = _firestore.collection('Categories');
  CollectionReference _deletedWorkerRef = _firestore.collection('Deleted');

  DocumentReference _workerCounterRef =
      _firestore.collection('Counters').doc('workerCounter');
  DocumentReference _userCounterRef =
      _firestore.collection('Counters').doc('userCounter');

  final String userCounterUrl = Server.server_url + 'Counters/userCounter';
  final String userCollectionUrl = Server.server_url + 'Users';

  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    HttpHeaders.authorizationHeader: Server.apiKey
  };

  FirebaseFirestore get firestore => _firestore;
  Auth.FirebaseAuth get auth => _auth;
  User get loggedInUser => _user;

  SharedPreferenceHelper get sharedPreferencesHelper {
    return _sharedPreferenceHelper;
  }

  CollectionReference get userCollectionRef => _userCollectionRef;
  CollectionReference get workersRef => _workersRef;
  CollectionReference get categoriesRef => _categoriesRef;
  CollectionReference get deletedRef => _deletedWorkerRef;
  DocumentReference get workersCounterRef => _workerCounterRef;
  DocumentReference get userCounterRef => _userCounterRef;
  getFirebaseUser() {
    firebaseUser = _auth.currentUser;
  }

  Future<bool> checkInternetConnection() async {
    try {
      await firestore
          .runTransaction((tx) {})
          .timeout(Duration(seconds: integer.internet_timeout));
      return true;
    } on PlatformException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }
}

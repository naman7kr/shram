import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String userName;
  String email;
  String address;
  String phoneNumber;
  bool isAdmin;

  User(
      {this.id,
      this.userName,
      this.email,
      this.address,
      this.phoneNumber,
      this.isAdmin});
  static User fromMap(Map<String, dynamic> data) {
    return User(
        id: data['id'],
        userName: data['name'],
        email: data['email'],
        address: data['address'],
        phoneNumber: data['phone'],
        isAdmin: data['isAdmin']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': userName,
      'email': email,
      'address': address,
      'phone': phoneNumber,
      'isAdmin': isAdmin
    };
  }
}

class Interests {
  String workerDocRef;
  Timestamp addedOn;
  Interests({
    this.workerDocRef,
    this.addedOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'workerDocRef': workerDocRef,
      'addedOn': addedOn,
    };
  }

  factory Interests.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Interests(
      workerDocRef: map['workerDocRef'],
      addedOn: map['addedOn'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Interests.fromJson(String source) =>
      Interests.fromMap(json.decode(source));
}

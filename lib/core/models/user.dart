import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String userName;
  String email;
  String address;
  String phoneNumber;
  bool isAdmin;
  List<PersonOfInterest> personOfInterests = [];

  User(
      {this.id,
      this.userName,
      this.email,
      this.address,
      this.phoneNumber,
      this.personOfInterests,
      this.isAdmin});
  static User fromMap(Map<String, dynamic> data) {
    return User(
        id: data['id'],
        userName: data['name'],
        email: data['email'],
        address: data['address'],
        phoneNumber: data['phone'],
        personOfInterests: (data['personOfInterest'] as List)
            .map((e) => PersonOfInterest.fromJson(e))
            .toList(),
        isAdmin: data['isAdmin']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': userName,
      'email': email,
      'address': address,
      'phone': phoneNumber,
      'personOfInterest': personOfInterests.map((e) => e.toMap()).toList(),
      'isAdmin': isAdmin
    };
  }
}

class PersonOfInterest {
  String workerId;
  Timestamp addTime;
  PersonOfInterest({
    this.workerId,
    this.addTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'workerId': workerId,
      'addTime': addTime,
    };
  }

  factory PersonOfInterest.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return PersonOfInterest(
      workerId: map['workerId'],
      addTime: map['addTime'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PersonOfInterest.fromJson(String source) =>
      PersonOfInterest.fromMap(json.decode(source));
}

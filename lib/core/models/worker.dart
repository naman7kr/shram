import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Worker {
  String id;
  String name;
  String phoneNumber;
  String aadhar;
  String address;
  bool isSkilled;
  String skillType;
  List<String> searchName = [];
  List<String> searchPhone = [];
  List<String> searchAadhar = [];
  List<String> usersInterested = [];

  Worker(
      {this.id,
      this.name,
      this.phoneNumber,
      this.aadhar,
      this.address,
      this.isSkilled,
      this.skillType,
      this.searchName,
      this.searchPhone,
      this.searchAadhar,
      this.usersInterested});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'aadhar': aadhar,
      'address': address,
      'isSkilled': isSkilled,
      'skillType': skillType,
      'searchName': searchName,
      'searchPhone': searchPhone,
      'searchAadhar': searchAadhar,
      'usersInterested': usersInterested?.map((x) => {'uid': x})?.toList(),
    };
  }

  static Worker fromJson(Map<String, dynamic> data) {
    return Worker(
        id: data['id'],
        name: data['name'],
        phoneNumber: data['phoneNumber'],
        aadhar: data['aadhar'],
        address: data['address'],
        isSkilled: data['isSkilled'],
        skillType: data['skillType'],
        usersInterested: (data['usersInterested'] as List<dynamic>)
            ?.map((e) => e.toString())
            ?.toList());
  }

  @override
  String toString() {
    return 'Worker(id: $id, name: $name, phoneNumber: $phoneNumber, aadhar: $aadhar, address: $address, isSkilled: $isSkilled, skillType: $skillType, searchName: $searchName, searchPhone: $searchPhone, searchAadhar: $searchAadhar, usersInterested: $usersInterested)';
  }
}

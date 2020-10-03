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
  List<Timestamp> popularity = [];

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
      this.popularity});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'phoneNumber': this.phoneNumber,
      'aadhar': this.aadhar,
      'address': this.address,
      'isSkilled': this.isSkilled,
      'skillType': this.skillType,
      'searchName': this.searchName,
      'searchPhone': this.searchPhone,
      'searchAadhar': this.searchAadhar,
      'popularity': this.popularity.map((e) => {'visitedOn': e}).toList()
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
        popularity:
            (data['popularity'] as List).map((e) => e['visitedOn']).toList());
  }
}

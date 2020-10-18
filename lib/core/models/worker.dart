import 'package:shram/core/enums/gender.dart';

class Worker {
  String id;
  String name;
  String phoneNumber;
  String district;
  String block;
  String panchayat;
  String village;
  String address;
  String gender;
  bool isSkilled;
  String skillType;
  String img;

  bool isOther;
  List<String> searchName = [];
  List<String> searchPhone = [];

  List<String> usersInterested = [];

  Worker(
      {this.id,
      this.name,
      this.phoneNumber,
      this.district,
      this.block,
      this.panchayat,
      this.village,
      this.address,
      this.gender,
      this.isOther,
      this.isSkilled,
      this.skillType,
      this.img,
      this.searchName,
      this.searchPhone,
      this.usersInterested});
  Worker.clone(Worker w)
      : this(
            id: w.id,
            name: w.name,
            phoneNumber: w.phoneNumber,
            district: w.district,
            block: w.block,
            panchayat: w.panchayat,
            village: w.village,
            address: w.address,
            gender: w.gender,
            isOther: w.isOther,
            isSkilled: w.isSkilled,
            skillType: w.skillType,
            img: w.img,
            searchName: w.searchName,
            searchPhone: w.searchPhone,
            usersInterested: w.usersInterested);

  bool isEqualTo(Worker worker) {
    if (worker.id.compareTo(this.id) == 0 &&
        worker.name.compareTo(this.name) == 0 &&
        worker.phoneNumber.compareTo(this.phoneNumber) == 0 &&
        worker.district.compareTo(this.district) == 0 &&
        worker.block.compareTo(this.block) == 0 &&
        worker.panchayat.compareTo(this.panchayat) == 0 &&
        worker.village.compareTo(this.village) == 0 &&
        worker.address.compareTo(this.address) == 0 &&
        worker.gender == this.gender &&
        worker.skillType.compareTo(this.skillType) == 0 &&
        worker.img.compareTo(this.img) == 0 &&
        worker.isOther == this.isOther &&
        worker.isSkilled == this.isSkilled) {
      return true;
    } else {
      return false;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'district': district,
      'block': block,
      'panchayat': panchayat,
      'village': village,
      'address': address,
      'gender': gender,
      'isOther': isOther,
      'isSkilled': isSkilled,
      'skillType': skillType,
      'img': img,
      'searchName': searchName,
      'searchPhone': searchPhone,
      'usersInterested': usersInterested?.map((x) => {'uid': x})?.toList(),
    };
  }

  static Worker fromJson(Map<String, dynamic> data) {
    return Worker(
        id: data['id'],
        name: data['name'],
        phoneNumber: data['phoneNumber'],
        district: data['district'],
        block: data['block'],
        panchayat: data['panchayat'],
        village: data['village'],
        address: data['address'],
        gender: data['gender'],
        isOther: data['isOther'],
        isSkilled: data['isSkilled'],
        skillType: data['skillType'],
        img: data['img'],
        searchName: (data['searchName'] as List<dynamic>)
            ?.map((e) => e.toString())
            ?.toList(),
        searchPhone: (data['searchPhone'] as List<dynamic>)
            ?.map((e) => e.toString())
            ?.toList(),
        usersInterested: (data['usersInterested'] as List<dynamic>)
            ?.map((e) => e.toString())
            ?.toList());
  }

  @override
  String toString() {
    return 'Worker(id: $id, name: $name, phoneNumber: $phoneNumber, district: $district, block: $block, panchayat: $panchayat, village: $village, address: $address, gender: $gender, isSkilled: $isSkilled, skillType: $skillType, image: $img, isOther: $isOther, searchName: $searchName, searchPhone: $searchPhone, usersInterested: $usersInterested)';
  }
}

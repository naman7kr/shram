
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
  Worker.clone(Worker w)
      : this(
            id: w.id,
            name: w.name,
            phoneNumber: w.phoneNumber,
            aadhar: w.aadhar,
            address: w.address,
            isSkilled: w.isSkilled,
            skillType: w.skillType,
            searchName: w.searchName,
            searchPhone: w.searchPhone,
            searchAadhar: w.searchAadhar,
            usersInterested: w.usersInterested);

  bool isEqualTo(Worker worker) {
    if (worker.id.compareTo(this.id) == 0 &&
        worker.name.compareTo(this.name) == 0 &&
        worker.phoneNumber.compareTo(this.phoneNumber) == 0 &&
        worker.aadhar.compareTo(this.aadhar) == 0 &&
        worker.address.compareTo(this.address) == 0 &&
        worker.skillType.compareTo(this.skillType) == 0 &&
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
        searchName: (data['searchName'] as List<dynamic>)
            ?.map((e) => e.toString())
            ?.toList(),
        searchPhone: (data['searchPhone'] as List<dynamic>)
            ?.map((e) => e.toString())
            ?.toList(),
        searchAadhar: (data['searchAadhar'] as List<dynamic>)
            ?.map((e) => e.toString())
            ?.toList(),
        usersInterested: (data['usersInterested'] as List<dynamic>)
            ?.map((e) => e.toString())
            ?.toList());
  }

  @override
  String toString() {
    return 'Worker(id: $id, name: $name, phoneNumber: $phoneNumber, aadhar: $aadhar, address: $address, isSkilled: $isSkilled, skillType: $skillType, searchName: $searchName, searchPhone: $searchPhone, searchAadhar: $searchAadhar, usersInterested: $usersInterested)';
  }
}

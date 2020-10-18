import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/services/services.dart';

class SearchService extends Services {
  List<DocumentSnapshot> _searchNameList = [];
  List<DocumentSnapshot> _searchPhoneList = [];

  List<DocumentSnapshot> _searchAddressList = [];
  void dispose() {
    // _searchAadharController.close();
    // _searchNameController.close();
    // _searchPhoneController.close();
  }

  SearchService() {}
  List<DocumentSnapshot> get searchNameList {
    // print('GETTING STREAM');
    return _searchNameList;
  }

  List<DocumentSnapshot> get searchPhoneList => _searchPhoneList;

  Future<List<DocumentSnapshot>> fetchFirstSearchName(
      String query, Categories cat) async {
    query = query.toLowerCase();
    bool isOther = false;
    if (cat.name.compareTo('Others') == 0) isOther = true;

    QuerySnapshot result;
    if (isOther) {
      result = await workersRef
          .orderBy('name')
          .where('isOther', isEqualTo: true)
          .where('searchName', arrayContains: query)
          .limit(integer.fetch_size)
          .get();
    } else {
      result = await workersRef
          .orderBy('name')
          .where('skillType', isEqualTo: cat.name.toLowerCase())
          .where('searchName', arrayContains: query)
          .limit(integer.fetch_size)
          .get();
    }
    // print(result.docs[0].data());
    _searchNameList = result.docs;
    return _searchNameList;
  }

  Future<List<DocumentSnapshot>> fetchNextSearchName(
    String query,
    Categories cat,
  ) async {
    query = query.toLowerCase();
    bool isOther = false;
    if (cat.name.compareTo('Others') == 0) isOther = true;
    QuerySnapshot result;
    if (isOther) {
      result = await workersRef
          .orderBy('name')
          .where('isOther', isEqualTo: true)
          .where('searchName', arrayContains: query)
          .startAfterDocument(_searchNameList[_searchNameList.length - 1])
          .limit(integer.fetch_size)
          .get();
    } else {
      result = await workersRef
          .orderBy('name')
          .where('skillType', isEqualTo: cat.name.toLowerCase())
          .where('searchName', arrayContains: query)
          .startAfterDocument(_searchNameList[_searchNameList.length - 1])
          .limit(integer.fetch_size)
          .get();
    }
    _searchNameList.addAll(result.docs);
    return _searchNameList;
  }

  Future<List<DocumentSnapshot>> fetchFirstSearchPhone(
    String query,
    Categories cat,
  ) async {
    query = query.toLowerCase();
    bool isOther = false;
    if (cat.name.compareTo('Others') == 0) isOther = true;
    QuerySnapshot result;
    if (isOther) {
      result = await workersRef
          .orderBy('name')
          .where('isOther', isEqualTo: true)
          .where('searchPhone', arrayContains: query)
          .limit(integer.fetch_size)
          .get();
    } else {
      result = await workersRef
          .orderBy('phoneNumber')
          .where('skillType', isEqualTo: cat.name.toLowerCase())
          .where('searchPhone', arrayContains: query)
          .limit(integer.fetch_size)
          .get();
    }
    _searchPhoneList = result.docs;
    return _searchPhoneList;
  }

  Future<List<DocumentSnapshot>> fetchNextSearchPhone(
    String query,
    Categories cat,
  ) async {
    query = query.toLowerCase();
    bool isOther = false;
    if (cat.name.compareTo('Others') == 0) isOther = true;
    QuerySnapshot result;
    if (isOther) {
      result = await workersRef
          .orderBy('name')
          .where('isOther', isEqualTo: true)
          .where('searchPhone', arrayContains: query)
          .startAfterDocument(_searchPhoneList[_searchPhoneList.length - 1])
          .limit(integer.fetch_size)
          .get();
    } else {
      result = await workersRef
          .orderBy('phoneNumber')
          .where('skillType', isEqualTo: cat.name.toLowerCase())
          .where('searchPhone', arrayContains: query)
          .startAfterDocument(_searchPhoneList[_searchPhoneList.length - 1])
          .limit(integer.fetch_size)
          .get();
    }
    _searchPhoneList.addAll(result.docs);
    return _searchPhoneList;
  }

  Future<List<DocumentSnapshot>> fetchFirstSearchAddress(
      Map<String, String> queryData, Categories cat) async {
    String block = queryData['block'];
    String panchayat = queryData['panchayat'];
    String village = queryData['village'];
    _searchAddressList.clear();
    bool isOther = false;
    if (cat.name.compareTo('Others') == 0) isOther = true;
    QuerySnapshot result;
    if (isOther) {
      result = await getQuery(workersRef, block, panchayat, village)
          .where('isOther', isEqualTo: true)
          .limit(integer.fetch_size)
          .get();
    } else {
      result = await getQuery(workersRef, block, panchayat, village)
          .where('skillType', isEqualTo: cat.name.toLowerCase())
          .limit(integer.fetch_size)
          .get();
    }
    _searchAddressList.addAll(result.docs);
    return _searchAddressList;
  }

  Future<List<DocumentSnapshot>> fetchNextSearchAddress(
      Map<String, String> queryData, Categories cat) async {
    String block = queryData['block'];
    String panchayat = queryData['panchayat'];
    String village = queryData['village'];
    bool isOther = false;
    if (cat.name.compareTo('Others') == 0) isOther = true;
    QuerySnapshot result;
    if (isOther) {
      result = await getQuery(workersRef, block, panchayat, village)
          .where('isOther', isEqualTo: true)
          .startAfterDocument(_searchAddressList[_searchAddressList.length - 1])
          .limit(integer.fetch_size)
          .get();
    } else {
      result = await getQuery(workersRef, block, panchayat, village)
          .where('skillType', isEqualTo: cat.name.toLowerCase())
          .startAfterDocument(_searchAddressList[_searchAddressList.length - 1])
          .limit(integer.fetch_size)
          .get();
    }
    _searchAddressList.addAll(result.docs);
    return _searchAddressList;
  }

  Query getQuery(CollectionReference workersRef, String block, String panchayat,
      String village) {
    if (village.isEmpty && panchayat.isEmpty) {
      return workersRef
          .orderBy('name')
          .where('block', isEqualTo: block.toLowerCase());
    } else if (village.isEmpty) {
      return workersRef
          .orderBy('name')
          .where('block', isEqualTo: block.toLowerCase())
          .where('panchayat', isEqualTo: panchayat.toLowerCase());
    } else {
      return workersRef
          .orderBy('name')
          .where('block', isEqualTo: block.toLowerCase())
          .where('panchayat', isEqualTo: panchayat.toLowerCase())
          .where('village', isEqualTo: village.toLowerCase());
    }
  }
}

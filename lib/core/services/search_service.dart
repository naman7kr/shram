import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/services/services.dart';

class SearchService extends Services {
  List<DocumentSnapshot> _searchNameList = [];
  List<DocumentSnapshot> _searchPhoneList = [];
  List<DocumentSnapshot> _searchAadharList = [];

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
  List<DocumentSnapshot> get searchAadharList => _searchAadharList;

  Future<List<DocumentSnapshot>> fetchFirstSearchName(
      String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('name')
        .where('skillType', isEqualTo: cat.name)
        .where('searchName', arrayContains: query)
        .limit(integer.fetch_size)
        .get();

    // print(result.docs[0].data());
    _searchNameList = result.docs;
    return _searchNameList;
  }

  Future<List<DocumentSnapshot>> fetchNextSearchName(
      String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('name')
        .where('skillType', isEqualTo: cat.name)
        .where('searchName', arrayContains: query)
        .startAfterDocument(_searchNameList[_searchNameList.length - 1])
        .limit(integer.fetch_size)
        .get();

    _searchNameList.addAll(result.docs);
    return _searchNameList;
  }

  Future<List<DocumentSnapshot>> fetchFirstSearchPhone(
      String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('phoneNumber')
        .where('skillType', isEqualTo: cat.name)
        .where('searchPhone', arrayContains: query)
        .limit(integer.fetch_size)
        .get();

    _searchPhoneList = result.docs;
    return _searchPhoneList;
  }

  Future<List<DocumentSnapshot>> fetchNextSearchPhone(
      String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('phoneNumber')
        .where('skillType', isEqualTo: cat.name)
        .where('searchPhone', arrayContains: query)
        .startAfterDocument(_searchPhoneList[_searchPhoneList.length - 1])
        .limit(integer.fetch_size)
        .get();

    _searchPhoneList.addAll(result.docs);
    return _searchPhoneList;
  }

  Future fetchFirstSearchAadhar(String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('aadhar')
        .where('skillType', isEqualTo: cat.name)
        .where('searchAadhar', arrayContains: query)
        .limit(integer.fetch_size)
        .get();

    _searchAadharList = result.docs;
    return _searchAadharList;
  }

  Future<List<DocumentSnapshot>> fetchNextSearchAadhar(
      String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('aadhar')
        .where('skillType', isEqualTo: cat.name)
        .where('searchAadhar', arrayContains: query)
        .startAfterDocument(_searchAadharList[_searchAadharList.length - 1])
        .limit(integer.fetch_size)
        .get();
    _searchAadharList.addAll(result.docs);
    return _searchAadharList;
  }
}

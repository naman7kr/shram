import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/services/services.dart';

class SearchService extends Services {
  List<DocumentSnapshot> documentList;
  BehaviorSubject<List<DocumentSnapshot>> _searchNameController;
  BehaviorSubject<List<DocumentSnapshot>> _searchPhoneController;
  BehaviorSubject<List<DocumentSnapshot>> _searchAadharController;

  void dispose() {
    // _searchAadharController.close();
    // _searchNameController.close();
    // _searchPhoneController.close();
  }

  SearchService() {
    _searchNameController = BehaviorSubject<List<DocumentSnapshot>>();
    _searchPhoneController = BehaviorSubject<List<DocumentSnapshot>>();
    _searchAadharController = BehaviorSubject<List<DocumentSnapshot>>();
  }
  Stream<List<DocumentSnapshot>> get searchNameStream {
    print('GETTING STREAM');
    return _searchNameController.stream;
  }

  Stream<List<DocumentSnapshot>> get searchPhoneStream =>
      _searchPhoneController.stream;
  Stream<List<DocumentSnapshot>> get searchAadharStream =>
      _searchAadharController.stream;

  Future<void> fetchFirstSearchName(String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('id')
        .where('skillType', isEqualTo: cat.name)
        .where('searchName', arrayContains: query)
        .limit(integer.fetch_size)
        .get();
    documentList = result.docs;
    _searchNameController.sink.add(documentList);
  }

  Future<List<DocumentSnapshot>> fetchNextSearchName(
      String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('id')
        .where('skillType', isEqualTo: cat.name)
        .where('searchName', arrayContains: query)
        .startAfterDocument(documentList[documentList.length - 1])
        .limit(integer.fetch_size)
        .get();
    documentList.addAll(result.docs);
    _searchNameController.sink.add(documentList);
    return documentList;
  }

  Future<void> fetchFirstSearchPhone(String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('id')
        .where('skillType', isEqualTo: cat.name)
        .where('searchPhone', arrayContains: query)
        .limit(integer.fetch_size)
        .get();
    documentList = result.docs;
    _searchPhoneController.sink.add(documentList);
    return documentList;
  }

  Future<List<DocumentSnapshot>> fetchNextSearchPhone(
      String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('id')
        .where('skillType', isEqualTo: cat.name)
        .where('searchPhone', arrayContains: query)
        .startAfterDocument(documentList[documentList.length - 1])
        .limit(integer.fetch_size)
        .get();
    documentList.addAll(result.docs);
    _searchPhoneController.sink.add(documentList);
    return documentList;
  }

  Future<void> fetchFirstSearchAadhar(String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('id')
        .where('skillType', isEqualTo: cat.name)
        .where('searchAadhar', arrayContains: query)
        .limit(integer.fetch_size)
        .get();
    documentList = result.docs;
    _searchAadharController.sink.add(documentList);
    return documentList;
  }

  Future<List<DocumentSnapshot>> fetchNextSearchAadhar(
      String query, Categories cat) async {
    query = query.toLowerCase();
    var result = await workersRef
        .orderBy('id')
        .where('skillType', isEqualTo: cat.name)
        .where('searchAadhar', arrayContains: query)
        .startAfterDocument(documentList[documentList.length - 1])
        .limit(integer.fetch_size)
        .get();
    documentList.addAll(result.docs);
    _searchAadharController.sink.add(documentList);
    return documentList;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/services/search_service.dart';
import 'package:shram/core/viewmodel/BaseModel.dart';
import 'package:shram/locator.dart';

class SearchPageModel extends BaseModel {
  final SearchService _searchService = locator<SearchService>();

  Future<List<DocumentSnapshot>> fetchFirstNameList(
    String query,
    Categories cat,
  ) {
    return _searchService.fetchFirstSearchName(query, cat);
  }

  Future<List<DocumentSnapshot>> fetchFirstPhoneList(
    String query,
    Categories cat,
  ) {
    return _searchService.fetchFirstSearchPhone(query, cat);
  }

  Future<List<DocumentSnapshot>> fetchNextNameList(
    String query,
    Categories cat,
  ) {
    return _searchService.fetchNextSearchName(query, cat);
  }

  Future<List<DocumentSnapshot>> fetchNextPhoneList(
    String query,
    Categories cat,
  ) {
    return _searchService.fetchNextSearchPhone(query, cat);
  }

  List<DocumentSnapshot> get nameList => _searchService.searchNameList;
  List<DocumentSnapshot> get phoneList => _searchService.searchPhoneList;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/services/search_service.dart';
import 'package:shram/core/viewmodel/BaseModel.dart';
import 'package:shram/locator.dart';

class SearchPageModel extends BaseModel {
  final SearchService _searchService = locator<SearchService>();
  Stream<List<DocumentSnapshot>> get nameStream =>
      _searchService.searchNameStream;
  Stream<List<DocumentSnapshot>> get phoneStream =>
      _searchService.searchPhoneStream;
  Stream<List<DocumentSnapshot>> get aadharStream =>
      _searchService.searchAadharStream;
}

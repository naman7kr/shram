import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/screens/search/suggestions.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/utilities/search.dart';
import 'package:shram/core/enums/list_type.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/search_service.dart';
import 'package:shram/core/viewmodel/search_page_model.dart';
import 'package:shram/locator.dart';

class WorkersSearch extends MySearchDelegate<Worker> {
  final Function _searchResult;
  final Categories cat;
  SearchService _searchService;

  WorkersSearch(this._searchResult, this.cat) {
    _searchService = locator<SearchService>();
  }

  int _selectedOption = 1;

  void _onSuggestionChangeQuery(String newQuery) {
    query = newQuery;
  }

  Stream<List<DocumentSnapshot>> getStreamFromService() {
    switch (_selectedOption) {
      case 1:
        return _searchService.searchNameStream;
      case 2:
        return _searchService.searchPhoneStream;
      case 3:
        return _searchService.searchAadharStream;
      default:
        return null;
    }
  }

  void _onSuggestionTap(String suggestion, BuildContext context) async {
    query = suggestion;
    await getSuggestions();
    _searchResult(
        query, getStreamFromService(), ListTypeHelper.getEnum(_selectedOption));
    // _searchService.dispose();
    close(context, null);
  }

  Future<void> _showDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: AlertDialog(
                actions: [
                  RaisedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('ok'),
                  ),
                ],
                title: Text(string.searchby),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile(
                      value: 1,
                      groupValue: _selectedOption,
                      onChanged: (val) {
                        setState(() {
                          _selectedOption = val;
                        });
                      },
                      title: Text('Name'),
                    ),
                    RadioListTile(
                      value: 2,
                      groupValue: _selectedOption,
                      onChanged: (val) {
                        setState(() {
                          _selectedOption = val;
                        });
                      },
                      title: Text('Phone'),
                    ),
                    RadioListTile(
                      value: 3,
                      groupValue: _selectedOption,
                      onChanged: (val) {
                        setState(() {
                          _selectedOption = val;
                        });
                      },
                      title: Text('Aadhar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      RaisedButton(
        onPressed: () => _showDialog(context),
        child: Text(
            ListTypeHelper.getValue(ListTypeHelper.getEnum(_selectedOption))),
      ),
      if (query.length != 0)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        // _searchService.dispose();
        close(context, null);
      },
    );
  }

  @override
  void buildResults(BuildContext context) {
    _searchResult(
        query, getStreamFromService(), ListTypeHelper.getEnum(_selectedOption));
    // _searchService.dispose();
    close(context, null);
  }

  Future<ResultType> getSuggestions() async {
    try {
      switch (_selectedOption) {
        case 1:
          print('QUERY' + query.toLowerCase());

          await _searchService.fetchFirstSearchName(query.toLowerCase(), cat);
          return ResultType.SUCCESSFUL;
        case 2:
          await _searchService.fetchFirstSearchPhone(query.toLowerCase(), cat);
          return ResultType.SUCCESSFUL;
        case 3:
          await _searchService.fetchFirstSearchAadhar(query.toLowerCase(), cat);
          return ResultType.SUCCESSFUL;
        default:
          return ResultType.UNSUCCESSFUL;
      }
    } catch (err) {
      print(err);
      return ResultType.ERROR;
    }
  }

  Stream<List<DocumentSnapshot>> getStream(SearchPageModel model) {
    switch (_selectedOption) {
      case 1:
        return model.nameStream;
      case 2:
        return model.phoneStream;
      case 3:
        return model.aadharStream;
      default:
        return null;
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    getSuggestions();
    return BaseView<SearchPageModel>(
      onModelReady: (model) {
        return model;
      },
      builder: (context, model, child) {
        return StreamBuilder<List<DocumentSnapshot>>(
            stream: getStream(model),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasData) {
                var suggestions = streamSnapshot.data;
                // print(suggestions);
                suggestions =
                    suggestions.take(integer.suggestions_limit).toList();
                return Suggestions(
                    suggestions,
                    ListTypeHelper.getEnum(_selectedOption),
                    _onSuggestionTap,
                    _onSuggestionChangeQuery,
                    context);
              } else {
                return Center(
                  child: Text('No Suggestions available for the query'),
                );
              }
            });
      },
    );

    // if (_workers.length == 0) {
    //   return Center(child: Text('No Data'));
    // } else {
    //   _resultName = _workers
    //       .where((worker) =>
    //           worker.name.toLowerCase().contains(query.toLowerCase()))
    //       .toList()
    //       .take(integer.suggestions_limit)
    //       .toList();
    //   print(_resultName);
    //   _resultPhone = _workers
    //       .where((worker) =>
    //           worker.phoneNumber.toLowerCase().contains(query.toLowerCase()))
    //       .toList()
    //       .take(integer.suggestions_limit)
    //       .toList();
    //   _resultAadhar = _workers
    //       .where((worker) =>
    //           worker.aadhar.toLowerCase().contains(query.toLowerCase()))
    //       .toList()
    //       .take(integer.suggestions_limit)
    //       .toList();
    //   return Suggestions(_resultName, _resultPhone, _resultAadhar,
    //       _onSuggestionTap, _onSuggestionChangeQuery, context);
    // }
  }
}

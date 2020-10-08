import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_item/multi_select_item.dart';
import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/widgets/multi_select_list.dart';
import 'package:shram/UI/widgets/worker_item.dart';
import 'package:shram/UI/screens/search/WorkersSearch.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/utilities/search.dart';
import 'package:shram/UI/widgets/Background.dart';
import 'package:shram/UI/widgets/connection_error.dart';
import 'package:shram/core/enums/list_type.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/search_service.dart';
import 'package:shram/core/services/workers_service.dart';
import 'package:shram/core/viewmodel/workers_page_model.dart';
import 'package:shram/locator.dart';

class SearchScreen extends StatefulWidget {
  static const String routeName = '/search-screen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  ListType searchType;

  bool _isLoading = false;
  bool _isLoadingNext = false;
  String query = '';
  ScrollController _scrollController = ScrollController();
  WorkersService _workersService;
  SearchService _searchService;
  MultiSelectController _multiSelectController = new MultiSelectController();
  Categories cat;
  List<DocumentSnapshot> displayList = [];
  List<Worker> displayWorkerList = [];
  bool isFirstTime = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _multiSelectController = null;
    _scrollController.dispose();
    // _workersService.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (displayList != null) {
        setState(() {
          _multiSelectController.set(displayList.length);
        });
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isFirstTime) {
      isFirstTime = false;
      _loadInitialData();

      _multiSelectController.disableEditingWhenNoneSelected = true;
    }
    super.didChangeDependencies();
  }

  Future _loadInitialData() async {
    cat = ModalRoute.of(context).settings.arguments as Categories;
    setState(() {
      _isLoading = true;
    });
    _searchService = locator<SearchService>();
    _workersService = locator<WorkersService>();
    try {
      displayList =
          await _workersService.fetchFirstWorkersListBasedOnCategory(cat);
      displayWorkerList =
          displayList.map((doc) => Worker.fromJson(doc.data())).toList();
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scrollListener() async {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // print("at the end of list");
      setState(() {
        _isLoadingNext = true;
      });
      var earlierSize = displayList.length;
      try {
        if (query.isEmpty) {
          displayList = await _workersService.fetchNextWorkersList(cat);
        } else {
          if (searchType == ListType.NAME) {
            displayList = await _searchService.fetchNextSearchName(query, cat);
          } else if (searchType == ListType.PHONE) {
            displayList = await _searchService.fetchNextSearchPhone(query, cat);
          } else {
            displayList =
                await _searchService.fetchNextSearchAadhar(query, cat);
          }
        }
        displayWorkerList =
            displayList.map((doc) => Worker.fromJson(doc.data())).toList();
        var newSize = displayList.length;
        if (newSize != earlierSize) {
          _isLoadingNext = true;
        } else {
          _isLoadingNext = false;
        }
        setState(() {});
      } catch (err) {}
    }
  }

  // Future<void> _refreshWorker(ctx) async {}

  Future<void> _search(BuildContext context) async {
    await MyShowSearch(
        context: context, delegate: WorkersSearch(_searchResult, cat));
  }

  Future _searchResult(String query, ListType type) async {
    this.searchType = type;
    this.query = query;
    displayList = [];
    try {
      setState(() {
        _isLoading = true;
      });
      displayList = await getSearchList(query);
      displayWorkerList =
          displayList.map((doc) => Worker.fromJson(doc.data())).toList();
      setState(() {
        _isLoading = false;
        _isLoadingNext = false;
      });
    } catch (err) {
      setState(() {
        _isLoading = false;
        _isLoadingNext = false;
      });
    }
  }

  Future<List<DocumentSnapshot>> getSearchList(String query) {
    if (searchType == ListType.NAME) {
      return _searchService.fetchFirstSearchName(query, cat);
    } else if (searchType == ListType.PHONE) {
      return _searchService.fetchFirstSearchPhone(query, cat);
    } else {
      return _searchService.fetchFirstSearchAadhar(query, cat);
    }
  }

  void callback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var _workerList = [];
    var _workerDocId = [];
    if (displayList.isNotEmpty) {
      _workerList = displayList.map((e) => Worker.fromJson(e.data())).toList();
      _workerDocId = displayList.map((e) => e.id).toList();
    }
    return BaseView<WorkersPageModel>(
      onModelReady: (model) => model,
      builder: (context, model, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: buildAppBar(context),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Background(
              imageLocation: string.default_background,
              child: Container(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : displayList.length > 0
                        ? SingleChildScrollView(
                            controller: _scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  query.isEmpty
                                      ? Container()
                                      : Container(
                                          alignment: Alignment.topLeft,
                                          margin: EdgeInsets.only(
                                              left: 10, bottom: 20, top: 20),
                                          child: Text(
                                            'Search Result for $query',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3,
                                          ),
                                        ),
                                  MultiSelectList(
                                      _multiSelectController,
                                      _workerList,
                                      _workerDocId,
                                      _scaffoldKey,
                                      callback),
                                  // _buildWorkersListWidget(),
                                  _isLoadingNext
                                      ? Container(
                                          height: 100,
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          )
                        : FutureBuilder(
                            future: model.checkInternetConnection(),
                            builder: (context, connectionSnapshot) {
                              // print(query);
                              if (connectionSnapshot.connectionState ==
                                  ConnectionState.done) {
                                if (connectionSnapshot.data as bool) {
                                  return Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: query.isEmpty
                                            ? Container()
                                            : Container(
                                                alignment: Alignment.topLeft,
                                                margin: EdgeInsets.only(
                                                    left: 10,
                                                    bottom: 20,
                                                    top: 20),
                                                child: Text(
                                                  'Search Result for $query',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline3,
                                                ),
                                              ),
                                      ),
                                      Align(
                                          alignment: Alignment.center,
                                          child: Text('No items')),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: ConnectionError(
                                            onReload: _loadInitialData),
                                      ),
                                    ],
                                  );
                                }
                              } else {
                                // print('Hello');
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: Text('Search'),
        leading: !_multiSelectController.isSelecting
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // print('back');
                  Navigator.of(context).pop();
                },
              )
            : IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  // print('Close');
                  setState(() {
                    _multiSelectController.deselectAll();
                  });
                }),
        actions: _multiSelectController.isSelecting
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.star_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {},
                )
              ]
            : [
                IconButton(
                  onPressed: () => _search(context),
                  icon: Icon(Icons.search),
                ),
              ]);
  }
}

// Widget _buildWorkersListWidget() {
//   // print(displayList[0].data()['name']);
//   return ListView.builder(
//       itemCount: displayList.length,
//       physics: NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemBuilder: (_, i) => MultiSelectItem(
//             isSelecting: _multiSelectController.isSelecting,
//             onSelected: () {
//               setState(() {
//                 _multiSelectController.toggle(i);
//               });
//             },
//             child: Container(
//               decoration: _multiSelectController.isSelected(i)
//                   ? BoxDecoration(color: Colors.grey[300])
//                   : BoxDecoration(),
//               child: WorkerItem(
//                   displayWorkerList[i],
//                   displayList[i].id,
//                   _multiSelectController.isSelecting,
//                   _multiSelectController.isSelected(i),
//                   _scaffoldKey,
//                   addFavourite,
//                   removeFavourite),
//             ),
//           ));
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_item/multi_select_item.dart';
import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/screens/search/worker_item.dart';
import 'package:shram/UI/screens/search/WorkersSearch.dart';
import 'package:shram/UI/utilities/search.dart';
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
  AsyncSnapshot<List<DocumentSnapshot>> snapshot;
  bool isFirstTime = true;
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
      if (snapshot != null) {
        setState(() {
          _multiSelectController.set(snapshot.data.length);
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
      await _workersService.fetchFirstWorkersListBasedOnCategory(cat);
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print('TimedOut');
    }
  }

  Future<void> _scrollListener() async {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      print("at the end of list");
      setState(() {
        _isLoadingNext = true;
      });
      try {
        if (query.isEmpty) {
          await _workersService.fetchNextWorkersList(cat);
        } else {
          if (searchType == ListType.NAME) {
            await _searchService.fetchNextSearchName(query, cat);
          } else if (searchType == ListType.PHONE) {
            await _searchService.fetchNextSearchPhone(query, cat);
          } else {
            await _searchService.fetchNextSearchAadhar(query, cat);
          }
        }
        setState(() {
          _isLoadingNext = false;
        });
      } catch (err) {}
    }
  }

  Future<void> _refreshWorker(ctx) async {}

  Future<void> _search(BuildContext context) async {
    await MyShowSearch(
        context: context, delegate: WorkersSearch(_searchResult, cat));
  }

  void _searchResult(
      String query, Stream<List<DocumentSnapshot>> resultList, ListType type) {
    this.searchType = type;
    this.query = query;

    // searchResultList.listen((event) {
    //   event.forEach((element) {
    _searchService.searchNameStream.listen((event) {
      print("SEARCH LENGTH" + event.length.toString());
    });
    // print("SEARCH LENGTH" + _searchService.searchNameStream.length.toString());
    //   });
    // });
    setState(() {});
  }

  Stream<List<DocumentSnapshot>> getSearchStream() {
    if (searchType == ListType.NAME) {
      return _searchService.searchNameStream;
    } else if (searchType == ListType.PHONE) {
      return _searchService.searchPhoneStream;
    } else {
      return _searchService.searchAadharStream;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<WorkersPageModel>(
      onModelReady: (model) => model,
      builder: (context, model, child) {
        return Scaffold(
          appBar: buildAppBar(context),
          body: Container(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : StreamBuilder<List<DocumentSnapshot>>(
                    stream: query.isEmpty
                        ? model.getWorkersDocumentStream()
                        : getSearchStream(),
                    builder: (context, snapshot) {
                      this.snapshot = snapshot;
                      if (snapshot.hasData && snapshot.data.length != 0) {
                        return SingleChildScrollView(
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
                                _buildWorkersListWidget(model, snapshot),
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
                        );
                      } else {
                        return FutureBuilder(
                          future: model.checkInternetConnection(),
                          builder: (context, connectionSnapshot) {
                            // print(connectionSnapshot.connectionState);
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
                                return Align(
                                    alignment: Alignment.center,
                                    child: ConnectionError(
                                        onReload: _loadInitialData));
                              }
                            } else {
                              print('Hello');
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        );
                      }
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildWorkersListWidget(
      WorkersPageModel model, AsyncSnapshot<dynamic> snapshot) {
    return ListView.builder(
        itemCount: snapshot.data.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, i) => MultiSelectItem(
              isSelecting: _multiSelectController.isSelecting,
              onSelected: () {
                setState(() {
                  _multiSelectController.toggle(i);
                });
              },
              child: Container(
                decoration: _multiSelectController.isSelected(i)
                    ? BoxDecoration(color: Colors.grey[300])
                    : BoxDecoration(),
                child: WorkerItem(
                    snapshot.data[i],
                    _multiSelectController.isSelecting,
                    _multiSelectController.isSelected(i)),
              ),
            ));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: Text('Search'),
        leading: !_multiSelectController.isSelecting
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  print('back');
                  Navigator.of(context).pop();
                },
              )
            : IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  print('Close');
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

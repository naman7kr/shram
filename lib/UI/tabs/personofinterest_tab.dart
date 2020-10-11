import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_item/multi_select_item.dart';
import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/widgets/Background.dart';
import 'package:shram/UI/widgets/connection_error.dart';
import 'package:shram/UI/widgets/multi_select_list.dart';
import 'package:shram/core/enums/user_type.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/workers_service.dart';
import 'package:shram/core/viewmodel/workers_page_model.dart';
import 'package:shram/locator.dart';

class PersonOfInterestTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  PersonOfInterestTab(this._scaffoldKey);
  @override
  _PersonOfInterestTabState createState() => _PersonOfInterestTabState();
}

class _PersonOfInterestTabState extends State<PersonOfInterestTab> {
  bool _isLoading = false;
  bool _isFirstTime = true;
  WorkersService _workersService;
  List<DocumentSnapshot> _displayList = [];
  MultiSelectController _multiSelectController = new MultiSelectController();

  @override
  void dispose() {
    _multiSelectController = null;
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_displayList != null) {
        setState(() {
          _multiSelectController.set(_displayList.length);
        });
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // if (_isFirstTime) {
    loadData();
    //   _isFirstTime = false;
    // }
    super.didChangeDependencies();
  }

  void loadData() {
    setState(() {
      _isLoading = true;
    });

    _workersService = locator<WorkersService>();

    _workersService.fetchFavourites().then((result) {
      if (result != null) {
        // print(result.length);
        _displayList =
            result.map<DocumentSnapshot>((e) => e['workerDoc']).toList();
        // print('Length:' + _displayList.length.toString());
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = true;
        });
      }
    }).catchError((err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    });
  }

  void callback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var _workerList = [];
    var _workerDocId = [];
    if (_displayList.isNotEmpty) {
      // print('Yo');
      _workerList = _displayList.map((e) => Worker.fromJson(e.data())).toList();
      _workerDocId = _displayList.map((e) => e.id).toList();
    }
    return BaseView<WorkersPageModel>(
      onModelReady: (model) => model,
      builder: (context, model, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Background(
            imageLocation: string.default_background,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _displayList.length > 0
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: MultiSelectList(
                            _multiSelectController,
                            _workerList,
                            _workerDocId,
                            UserType.USER,
                            widget._scaffoldKey,
                            callback,
                            isFavouriteList: true,
                          ),
                        ),
                      )
                    : FutureBuilder(
                        future: model.checkInternetConnection(),
                        builder: (context, connectionSnapshot) {
                          if (connectionSnapshot.connectionState ==
                              ConnectionState.done) {
                            if (connectionSnapshot.data as bool) {
                              return Stack(
                                children: [
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
                                        onReload: loadData,
                                      )),
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
        );
      },
    );
  }
}

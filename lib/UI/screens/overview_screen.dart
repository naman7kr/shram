import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shram/UI/utilities/constants.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/widgets/Background.dart';
import 'package:shram/UI/widgets/MyPieChart.dart';
import 'package:shram/UI/widgets/connection_error.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/services/workers_service.dart';
import 'package:shram/locator.dart';

class OverviewScreen extends StatefulWidget {
  static const routeName = '/overview';

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  WorkersService _workersService;
  bool _isFirstTime = true;
  bool _isLoading = false;
  bool _noInternet = false;
  bool _isExpanded = false;
  Map<String, int> catData = {};
  Map<String, int> catSkilled = {};
  Map<String, int> catUnSkilled = {};
  int totalSkilled = 0;
  int totalUnskilled = 0;
  Map<String, Object> _data;
  int touchedIndex;
  @override
  void initState() {
    _workersService = locator<WorkersService>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isFirstTime) {
      _loadData();
    }
    super.didChangeDependencies();
  }

  Future _loadData() async {
    setState(() {
      _isLoading = true;
      _noInternet = false;
    });
    if (await _workersService.checkInternetConnection()) {
      try {
        _data = await _workersService.getOverviewData();
        // extract category data
        getCategoryData();
      } catch (err) {
        print(err);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _noInternet = true;
      });
    }
  }

  void getCategoryData() {
    if (_data != null) {
      List<QueryDocumentSnapshot> catDocs = _data['category'];
      for (var doc in catDocs) {
        catData.putIfAbsent(doc.id, () => doc.data()['count']);

        // Categories cat = Constants.skilledCategories
        //     .firstWhere((cat) => cat.name.compareTo(doc.id) == 0);
        // if (cat != null) {
        //   catSkilled.putIfAbsent(doc.id, () => doc.data()['count']);
        // } else {
        //   catUnSkilled.putIfAbsent(doc.id, () => doc.data()['count']);
        // }
      }

      if (catData.isNotEmpty) {
        catData.forEach((key, value) {
          if (Constants.skilledCategories
              .where((cat) => cat.name.compareTo(key) == 0)
              .isNotEmpty) {
            catSkilled.putIfAbsent(key, () => value);
            totalSkilled += value;
          } else {
            catUnSkilled.putIfAbsent(key, () => value);
            totalUnskilled += value;
          }
        });
      }
    }
  }

  List<Widget> getListItems() {
    return [
      ...catData.entries.map((e) => Text('${e.key}: ${e.value}')).toList()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Overview')),
      body: Background(
        imageLocation: string.default_background,
        child: Container(
          padding: EdgeInsets.all(10),
          child: _isLoading
              ? Container(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ))
              : Container(
                  child: _noInternet
                      ? Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ConnectionError(onReload: _loadData),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Users: ${(_data['user'] as int) - 1}",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Workers: ${_data['worker']}",
                                              style: TextStyle(fontSize: 16)),
                                          IconButton(
                                              icon: Icon(_isExpanded
                                                  ? Icons.arrow_drop_up
                                                  : Icons.arrow_drop_down),
                                              onPressed: () {
                                                setState(() {
                                                  _isExpanded = !_isExpanded;
                                                });
                                              })
                                        ],
                                      ),
                                      _isExpanded
                                          ? Container(
                                              height: 220,
                                              child: Scrollbar(
                                                child: ListView(
                                                  children: getListItems(),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                              // skilled-unskilled chart
                              MyPieChart(data: {
                                'Skilled': totalSkilled,
                                'Unskilled': totalUnskilled
                              }),
                            ],
                          ),
                        ),
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/tabs/categories/categories_grid.dart';
import 'package:shram/UI/utilities/constants.dart';
import 'package:shram/UI/widgets/connection_error.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/categories_service.dart';
import 'package:shram/core/services/workers_service.dart';
import 'package:shram/core/viewmodel/categories_modal.dart';
import 'package:shram/locator.dart';

class CategoriesTab extends StatefulWidget {
  @override
  _CategoriesTabState createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  bool _isLoading = false;
  bool isFirstTime = true;
  bool _isConnectionError = false;
  @override
  void initState() {
    // final _workersService = locator<WorkersService>();
    // List<Worker> workers =
    //     Constants.getWorkers(Categories(name: 'Carpenter', isSkilled: true));
    // _workersService.addMultipleWorkers(workers);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isFirstTime) {
      isFirstTime = false;
      _loadCategories();
    }
    super.didChangeDependencies();
  }

  void _loadCategories() {
    final _categoriesService = locator<CategoriesService>();

    setState(() {
      _isLoading = true;
      _isConnectionError = false;
    });
    // _categoriesService.addAllCategories();

    _categoriesService.getAllCategories().then((res) {
      //   if (res == ResultType.SUCCESSFUL) {
      // _categoriesService.categories.forEach((cat) async {

      // print(workers.toString());
      if (_categoriesService.categories.length != 0) {
        setState(() {
          _isLoading = false;
        });
      } else {
        print('No Categories Found');
      }
      // });
      //   } else {
      //     // error display snack bar
      //     print('ERROR');
      //   }
    }).catchError((err) {
      setState(() {
        _isConnectionError = true;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // return ConnectionError(
    //   onReload: () {},
    // );
    if (_isConnectionError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConnectionError(onReload: _loadCategories),
        ],
      );
    } else {
      return _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : BaseView<CategoriesModal>(
              onModelReady: (model) => model,
              builder: (ctx, model, child) => CategoriesGrid(model));
    }
  }
}

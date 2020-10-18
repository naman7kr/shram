import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/tabs/categories/categories_grid.dart';
import 'package:shram/UI/utilities/constants.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/widgets/Background.dart';
import 'package:shram/UI/widgets/connection_error.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/authentication_service.dart';
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

  Future _loadCategories() async {
    final _categoriesService = locator<CategoriesService>();

    setState(() {
      _isLoading = true;
      _isConnectionError = false;
    });
    // _categoriesService.addAllCategories();
    if (await _categoriesService.checkInternetConnection()) {
      try {
        await _categoriesService.getAllCategories();

        if (_categoriesService.categories.length != 0) {
          setState(() {
            _isLoading = false;
          });
        } else {
          print('No Categories Found');
        }
      } catch (err) {
        if (this.mounted) {
          setState(() {
            _isLoading = false;
          });
          Fluttertoast.showToast(
              msg: 'Server Error. Please Try again later',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } else {
      setState(() {
        _isConnectionError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return ConnectionError(
    //   onReload: () {},
    // );
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Background(
        imageLocation: string.default_background,
        child: _isConnectionError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConnectionError(onReload: _loadCategories),
                ],
              )
            : _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : BaseView<CategoriesModal>(
                    onModelReady: (model) => model,
                    builder: (ctx, model, child) => CategoriesGrid(model)),
      ),
    );
  }
}

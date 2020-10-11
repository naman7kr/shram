import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shram/UI/screens/login_screen.dart';
import 'package:shram/UI/tabs/categories/categories_tab.dart';
import 'package:shram/UI/tabs/personofinterest_tab.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/enums/popup_menu.dart';
import 'package:shram/core/viewmodel/login_page_model.dart';
import '../widgets/app_drawer.dart';
import '../BaseView.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;
  GlobalKey<ScaffoldState> _scaffoldKey;
  bool isExitTimeout = true;
  @override
  void initState() {
    _pages = [
      {'page': CategoriesTab(), 'title': 'Categories'},
      {'page': PersonOfInterestTab(_scaffoldKey), 'title': 'Interests'}
    ];

    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    print(_selectedPageIndex);
  }

  void onPopupSelect(PopUpOptions options, LoginPageModel model) {
    switch (options) {
      case PopUpOptions.SUPPORT:
        break;
      case PopUpOptions.ABOUT:
        break;
      case PopUpOptions.LOGOUT:
        model.signOut();
        Navigator.of(context)
            .pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
        break;
    }
  }

  Future<bool> _onWillPop() async {
    // print(_selectedPageIndex);
    if (_selectedPageIndex == 1) {
      _selectPage(0);
    } else {
      if (!isExitTimeout) {
        return true;
      } else {
        // print('LOL');
        isExitTimeout = false;
        Fluttertoast.showToast(
            msg: "Press back again to exit",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0);
        Timer(Duration(seconds: 3), () {
          isExitTimeout = true;
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BaseView<LoginPageModel>(
        onModelReady: (model) => model,
        builder: (context, model, child) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(
                'Shram',
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            drawer: AppDrawer(),
            body: _pages[_selectedPageIndex]['page'],
            bottomNavigationBar: BottomNavigationBar(
              onTap: _selectPage,
              backgroundColor: Theme.of(context).primaryColor,
              unselectedItemColor: Theme.of(context).accentColor,
              selectedItemColor: Colors.white,
              currentIndex: _selectedPageIndex,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.category), label: 'Categories'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.star), label: 'Favourites'),
              ],
            ),
          );
        },
      ),
    );
  }
}

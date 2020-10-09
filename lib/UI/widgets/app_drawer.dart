import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shram/UI/screens/add_worker/select_add_screen.dart';
import 'package:shram/core/enums/user_type.dart';
import 'package:shram/core/models/user.dart';
import 'package:shram/core/services/authentication_service.dart';
import 'package:shram/locator.dart';
import '../screens/support_screen.dart';
import '../screens/about_screen.dart';
import '../screens/login_screen.dart';
import '../BaseView.dart';
import '../../core/viewmodel/login_page_model.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isFirstTime = true;
  AuthenticationService _authenticationService;
  User user;
  bool isAdmin = false;

  @override
  void didChangeDependencies() {
    if (_isFirstTime) {
      _isFirstTime = false;
      _authenticationService = locator<AuthenticationService>();
      init();
    }
    super.didChangeDependencies();
  }

  void init() {
    _authenticationService.getUser().then((value) {
      this.user = value;
      this.isAdmin = user.isAdmin;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // init();
    // UserType type = Provider.of<UserType>(context);
    return BaseView<LoginPageModel>(
      onModelReady: (model) => model,
      builder: (context, model, child) {
        return Drawer(
          child: Column(
            children: [
              AppBar(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(user == null
                      ? 'Welcome'
                      : 'Welcome, ${user.userName.split(' ')[0]}'),
                ),
                automaticallyImplyLeading: false,
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.shop),
                title: Text(
                  'Home',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  // do nothing
                  Navigator.pop(context);
                },
              ),
              Divider(),
              if (isAdmin) ...[
                ListTile(
                  leading: Icon(Icons.shop),
                  title: Text(
                    'Add Worker',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    // do nothing
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(SelectAddScreen.routeName);
                  },
                ),
                Divider(),
              ],
              ListTile(
                leading: Icon(Icons.shop),
                title: Text(
                  'Support',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(SupportScreen.routeName);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text(
                  'About',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(AboutScreen.routeName);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text(
                  'Log Out',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  model.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginScreen.routeName, (route) => false);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

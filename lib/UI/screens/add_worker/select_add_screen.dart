import 'package:flutter/material.dart';

import 'package:shram/UI/screens/add_worker/add_single_screen.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/widgets/Background.dart';

import 'add_multiple_worker_screen.dart';

class SelectAddScreen extends StatelessWidget {
  static const String routeName = '/select-add';
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Add Type')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Background(
          imageLocation: string.default_background,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              padding: EdgeInsets.all(5),
              children: [
                InkWell(
                  onTap: () async {
                    var result = await Navigator.of(context)
                        .pushNamed(AddSingle.routeName);
                    if (result != null) {
                      // print(result);
                      // show a success snackbar
                      try {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text('Successfully Added'),
                          duration:
                              Duration(seconds: integer.snackbar_duration),
                        ));
                      } catch (err) {
                        print(err);
                      }
                    }
                  },
                  child: ListTile(
                    title: Text('Add Single Worker'),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(AddMultipleScreen.routeName);
                  },
                  child: ListTile(
                    title: Text('Add Multiple Worker'),
                  ),
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

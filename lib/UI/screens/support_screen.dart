import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  static const String routeName = '/support';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
      ),
      body: Center(
        child: Text('Support'),
      ),
    );
  }
}

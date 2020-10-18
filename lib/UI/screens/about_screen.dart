import 'package:flutter/material.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/widgets/Background.dart';

class AboutScreen extends StatelessWidget {
  static const String routeName = '/about';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Background(
        imageLocation: string.default_background,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'श्रम',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        string.about,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

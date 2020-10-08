import 'package:flutter/material.dart';
import 'package:shram/UI/BaseView.dart';
import 'package:shram/core/viewmodel/workers_page_model.dart';

class AddMultipleScreen extends StatelessWidget {
  static const String routeName = '/add-multiple-workers';
  @override
  Widget build(BuildContext context) {
    return BaseView<WorkersPageModel>(
      onModelReady: (model) => model,
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Add Multiple Workers'),
          ),
          body: Container(),
        );
      },
    );
  }
}

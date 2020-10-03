import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shram/UI/screens/search/search_screen.dart';
import 'package:shram/UI/utilities/constants.dart';
import 'package:shram/core/models/categories.dart';

class CategoryItem extends StatelessWidget {
  Categories _categories;
  CategoryItem(this._categories);
  Color getRandomColor() {
    var random = Random();
    return Constants
        .categoryColors[random.nextInt(Constants.categoryColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(SearchScreen.routeName, arguments: _categories);
      },
      child: Card(
        color: getRandomColor(),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        elevation: 5,
        child: Center(
          child: Text(
            _categories.name,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      ),
    );
  }
}

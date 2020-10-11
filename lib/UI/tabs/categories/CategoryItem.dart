import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shram/UI/screens/search/search_screen.dart';
import 'package:shram/UI/utilities/constants.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/models/categories.dart';

class CategoryItem extends StatelessWidget {
  final Categories _categories;
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
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              child: _categories.img != null && _categories.img.isNotEmpty
                  ? Center(
                      child: FadeInImage(
                      image: NetworkImage(_categories.img),
                      fit: BoxFit.cover,
                      placeholder: AssetImage(string.image_placeholder),
                    ))
                  : Center(
                      child: FadeInImage(
                      image: AssetImage(string.image_placeholder),
                      fit: BoxFit.cover,
                      placeholder: AssetImage(string.image_placeholder),
                    )),
            ),
            Container(
              color: Color.fromARGB(120, 0, 0, 0),
              width: double.infinity,
              height: double.infinity,
            ),
            Center(
              child: Text(
                _categories.name,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

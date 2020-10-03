import 'package:flutter/material.dart';
import 'package:shram/UI/tabs/categories/CategoryItem.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/viewmodel/categories_modal.dart';

class CategoriesGrid extends StatelessWidget {
  final CategoriesModal model;
  CategoriesGrid(this.model);

  Widget buildGrids(List<Categories> data) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: data.length,
      itemBuilder: (ctx, index) => CategoryItem(data[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // get the data

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 10, bottom: 20, top: 20),
              child: Text(
                string.unskilled,
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            //grid unskilled
            buildGrids(model.getUnSkilledCategories()),

            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 10, bottom: 20, top: 20),
              child: Text(
                string.skilled,
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            //grid skilled
            buildGrids(model.getSkilledCategories()),
          ],
        ),
      ),
    );
  }
}

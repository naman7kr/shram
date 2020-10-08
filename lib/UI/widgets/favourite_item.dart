import 'package:flutter/material.dart';
import 'package:shram/core/models/worker.dart';

class FavouriteItem extends StatefulWidget {
  final Worker worker;
  final String workerDocId;
  final bool isSelecting;
  final bool isSelected;
  final Function _removeFavourite;

  FavouriteItem(this.worker, this.workerDocId, this.isSelecting,
      this.isSelected, this._removeFavourite);

  @override
  _FavouriteItemState createState() => _FavouriteItemState();
}

class _FavouriteItemState extends State<FavouriteItem> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

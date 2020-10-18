import 'package:flutter/material.dart';
import 'package:shram/UI/utilities/utils.dart';

class DropDownList extends StatefulWidget {
  final String title;
  final String selectedValue;
  final List<String> data;
  final Function onSelect;
  bool isEnabled;
  DropDownList(
      {@required this.title,
      @required this.selectedValue,
      @required this.data,
      @required this.onSelect,
      this.isEnabled = true});
  @override
  _DropDownListState createState() => _DropDownListState();
}

class _DropDownListState extends State<DropDownList> {
  @override
  Widget build(BuildContext context) {
    // print(widget.title);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Text(widget.title),
            ),
          ),
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: widget.isEnabled
                  ? () {
                      Utils.createListDialog(
                          context, widget.title, widget.data, widget.onSelect);
                    }
                  : null,
              child: Container(
                color: widget.isEnabled ? Colors.white : Colors.black26,
                child: Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(widget.selectedValue)),
                      ),
                      widget.isEnabled
                          ? Container(
                              alignment: Alignment.bottomRight,
                              margin: EdgeInsets.only(top: 5),
                              child: Icon(Icons.arrow_drop_down),
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

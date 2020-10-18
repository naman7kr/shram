import 'dart:math';

import 'package:flutter/material.dart';

class Utils {
  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static double doubleWithPrecision(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  static Color getColor({var i = 0}) {
    switch (i) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.yellow;
      case 5:
        return Colors.orange;
      case 6:
        return Colors.grey;
      case 7:
        return Colors.purple;
      case 8:
        return Colors.brown;
      case 9:
        return Colors.lime;
      default:
        return Colors.white;
    }
  }

  static Future createListDialog(BuildContext context, String title,
      List<String> data, Function _onSelect) async {
    return showDialog(
      context: context,
      // barrierDismissible: false,

      builder: (context) {
        return AlertDialog(
          title: Text('Select $title'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _onSelect(index);
                      },
                      child: Container(
                          padding: EdgeInsets.all(8),
                          alignment: Alignment.center,
                          child: Text(data[index])),
                    ),
                    Divider()
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/models/categories.dart';

class Constants {
  static final List<Color> categoryColors = [
    Color(0xFFFF5722),
    Color(0xFFFF9800),
    Color(0xFF00BCD4),
    Color(0xFF039BE5),
    Color(0xFF9C27B0),
    Color(0xFF607D8B),
  ];
  static Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static List<Worker> getWorkers(Categories cat) {
    List<Worker> workers = [];
    for (int i = 0; i < 30; i++) {
      workers.add(Worker(
          id: DateTime.now().toString(),
          name: 'Worker${cat.name} $i',
          aadhar: '1231241231242',
          address: 'pandit jee road Hazaribag, Jharkhand',
          isSkilled: cat.isSkilled,
          phoneNumber: '0011223344',
          skillType: cat.name,
          searchName: [],
          searchAadhar: [],
          searchPhone: []));
    }
    workers.forEach((worker) {
      for (int i = 1; i < worker.name.length + 1; i++) {
        worker.searchName.add(worker.name.substring(0, i).toLowerCase());
      }
      for (int i = 1; i < worker.phoneNumber.length + 1; i++) {
        worker.searchPhone
            .add(worker.phoneNumber.substring(0, i).toLowerCase());
      }
      for (int i = 1; i < worker.aadhar.length + 1; i++) {
        worker.searchAadhar.add(worker.aadhar.substring(0, i).toLowerCase());
      }
    });
    return workers;
  }
}

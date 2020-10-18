import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shram/UI/utilities/utils.dart';

class MyPieChart extends StatefulWidget {
  final Map<String, int> data;
  MyPieChart({@required this.data});
  @override
  _MyPieChartState createState() => _MyPieChartState();
}

class _MyPieChartState extends State<MyPieChart> {
  int touchedIndex;
  int total = 0;
  void calTotal() {
    total = 0;
    widget.data.forEach((key, value) {
      total += value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // process data
    calTotal();
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.white,
        child: AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
                pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                  setState(() {
                    if (pieTouchResponse.touchInput is FlLongPressEnd ||
                        pieTouchResponse.touchInput is FlPanEnd) {
                      touchedIndex = -1;
                    } else {
                      touchedIndex = pieTouchResponse.touchedSectionIndex;
                    }
                  });
                }),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: showingSections()),
          ),
        ),
      ),
    );
  }

  double getPercentage(int val) {
    return ((val * 100) / total * 1.0);
  }

  List<PieChartSectionData> showingSections() {
    int i = 0;

    return widget.data.entries.map((e) {
      print(e);
      final isTouched = i == touchedIndex;
      i += 1;
      final double fontSize = isTouched ? 20 : 16;
      final double radius = isTouched ? 110 : 100;
      var percent = getPercentage(e.value);
      print(percent);
      return PieChartSectionData(
        color: Utils.getColor(i: i - 1),
        value: percent,
        title: '${percent.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
      );
    }).toList();
  }
}

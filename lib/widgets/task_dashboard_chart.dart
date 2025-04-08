import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskDashboardChart extends StatelessWidget {
  final int done;
  final int todo;
  final int inProgress;
  final int terminated;

  TaskDashboardChart({
    required this.done,
    required this.todo,
    required this.inProgress,
    required this.terminated,
  });

  @override
  Widget build(BuildContext context) {
    int total = done + todo + inProgress + terminated;

    double percent(int value) => total == 0 ? 0 : (value / total) * 100;

    final chartData = [
      {'label': 'Completed Tasks', 'value': done, 'color': Colors.green},
      {'label': 'Terminated Tasks', 'value': terminated, 'color': Colors.red},
      {'label': 'In Progress', 'value': inProgress, 'color': Colors.blue},
      {'label': 'To Do', 'value': todo, 'color': Colors.yellow},
    ];

    chartData.sort((a, b) =>
        percent(b['value'] as int).compareTo(percent(a['value'] as int)));

    return Column(
      children: [
        SizedBox(height: 20),
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              sections: [
                PieChartSectionData(
                  value: done.toDouble(),
                  color: Colors.green,
                  title: ' ',
                  radius: 80,
                  titleStyle: TextStyle(color: Colors.white),
                ),
                PieChartSectionData(
                  value: terminated.toDouble(),
                  color: Colors.red,
                  title: '',
                  radius: 80,
                  titleStyle: TextStyle(color: Colors.white),
                ),
                PieChartSectionData(
                  value: inProgress.toDouble(),
                  color: Colors.blue,
                  title: ' ',
                  radius: 80,
                  titleStyle: TextStyle(color: Colors.white),
                ),
                PieChartSectionData(
                  value: todo.toDouble(),
                  color: Colors.yellow,
                  title: ' ',
                  radius: 80,
                  titleStyle: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        ...chartData.map((data) {
          int value = data['value'] as int;
          Color color = data['color'] as Color;
          String label = data['label'] as String;
          double pct = percent(value);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct / 100,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Text("${pct.toInt()}/100%"),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

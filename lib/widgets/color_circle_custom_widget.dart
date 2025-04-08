import 'package:flutter/material.dart';

class TaskStatusLegend extends StatelessWidget {
  const TaskStatusLegend({Key? key}) : super(key: key);

  Widget _coloredDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      alignment: WrapAlignment.start, // important: align start
      children: [
        Container(
          width: 150,
          child: Row(
            children: [
              _coloredDot(Colors.green),
              Text('Completed Task'),
            ],
          ),
        ),
        Container(
          width: 150,
          child: Row(
            children: [
              _coloredDot(Colors.red),
              Text('Terminated Task'),
            ],
          ),
        ),
        Container(
          width: 150,
          child: Row(
            children: [
              _coloredDot(Colors.blue),
              Text('In Progress'),
            ],
          ),
        ),
        Container(
          width: 150,
          child: Row(
            children: [
              _coloredDot(Colors.yellow),
              Text('To Do'),
            ],
          ),
        ),
      ],
    );
  }
}

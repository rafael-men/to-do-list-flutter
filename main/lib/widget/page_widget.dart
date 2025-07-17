import 'package:flutter/material.dart';
import 'package:main/models/task.dart';
import 'package:main/widget/list_item.dart';

List<Task> taskList = [
  Task.create('task', 'details'),
  Task.create('task', 'details'),
  Task.create('task', 'details'),
  Task.create('task', 'details'),
  Task.create('task', 'details'),
];

class PageWidget extends StatelessWidget {
  const PageWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        return ListItem(task: taskList[index]);  
      },
    );
  }
}
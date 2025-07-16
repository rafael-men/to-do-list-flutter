import 'package:flutter/material.dart';
import 'package:main/models/task.dart';

class ListItem extends StatefulWidget {
  const ListItem({super.key, required this.task});

  final Task task;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {

  late TextEditingController taskController;

  @override
  void InitState() {
    taskController = TextEditingController(text: widget.task.taskName );

  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
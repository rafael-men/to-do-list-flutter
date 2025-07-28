import 'package:flutter/material.dart';
import 'package:main/models/task.dart';
import 'package:main/services/service_locator.dart';
import 'package:main/utils/task_list_controller.dart';
import 'package:main/widget/list_item.dart';

class PageWidget extends StatefulWidget {
  const PageWidget({super.key});

  @override
  State<PageWidget> createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  final controller = getIt<TaskListController>();

  @override
  void initState() {
    super.initState();
    controller.loadTasks();  
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Task>>(
      valueListenable: controller.taskListNotifier,
      builder: (context, taskList, _) => ListView.builder(
        shrinkWrap: true,
        itemCount: taskList.length,
        itemBuilder: (context, index) => ListItem(task: taskList[index]),
      ),
    );
  }
}

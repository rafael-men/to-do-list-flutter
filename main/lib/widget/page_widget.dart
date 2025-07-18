import 'package:flutter/material.dart';
import 'package:main/services/service_locator.dart';
import 'package:main/utils/task_list_controller.dart';
import 'package:main/widget/list_item.dart';

class PageWidget extends StatelessWidget {
  PageWidget({super.key});

  final controller = getIt<TaskListController>();
  

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.taskListNotifier,
      builder: (context, taskList, child) {
        return ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: taskList.length,
          itemBuilder: (context, index) {
            return ListItem(task: taskList[index]);
          },
        );
      },
    );
  }
}
import 'package:main/models/task.dart';
import 'package:main/utils/task_list_notifier.dart';

class TaskListController {
  final taskListNotifier = TaskListNotifier();

  void addTask(Task task) {
    print('Adicionando Tarefa');
    final currentList = taskListNotifier.value;
    taskListNotifier.value = [...currentList,task];
  }

  void update(String id, String taskName, {String? taskDetails, bool? completed}) {
  taskListNotifier.update(id, taskName, taskDetails: taskDetails, completed: completed);
  }


  void removeTask(String id) {
  taskListNotifier.removeTask(id);
  }

}

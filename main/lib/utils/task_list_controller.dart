import 'package:main/models/task.dart';
import 'package:main/utils/task_list_notifier.dart';

class TaskListController {
  final taskListNotifier = TaskListNotifier();

  void addTask(Task task) {
    taskListNotifier.addTask(task);
    
  }

  void update(String id, String taskName, {String? taskDetails, bool? completed}) {
    taskListNotifier.update(id, taskName, taskDetails: taskDetails, completed: completed);
  }

  void removeTask(String id) {
    taskListNotifier.removeTask(id);
  }

  void toggleTaskCompletion(String id) {
    taskListNotifier.toggleTaskCompletion(id);
  }


  List<Task> get tasks => taskListNotifier.value;
  

  List<Task> get completedTasks => taskListNotifier.value.where((task) => task.completed).toList();
  List<Task> get pendingTasks => taskListNotifier.value.where((task) => !task.completed).toList();

  int get taskCount => taskListNotifier.value.length;
  int get completedCount => completedTasks.length;
  int get pendingCount => pendingTasks.length;
}
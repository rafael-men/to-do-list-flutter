import 'package:main/models/task.dart';
import 'package:main/services/database_helper.dart';
import 'package:main/utils/task_list_notifier.dart';
import 'dart:async';

class TaskListController {
  final taskListNotifier = TaskListNotifier();
  final DatabaseHelper dbHelper;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TaskListController(this.dbHelper);

  Future<void> loadTasks() async {
    if (_isLoading) return;

    _isLoading = true;
    try {


      final isDatabaseReady = await dbHelper.isDatabaseReady();
      if (!isDatabaseReady) {
        throw Exception('Nenhum sistema de armazenamento disponível');
      }

      final tasks = await dbHelper.getTasks();
      print('Tarefas carregadas: ${tasks.length}');
      taskListNotifier.setTasks(tasks);
    } catch (e) {
      taskListNotifier.setTasks([]);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await dbHelper.insertTask(task);
      taskListNotifier.addTask(task);
      print('Tarefa adicionada com sucesso');
    } catch (e) {
      print('Erro ao adicionar tarefa: $e');
      rethrow;
    }
  }

  Future<void> updateTask(String id, String taskName, {String? taskDetails, bool? completed}) async {
    try {
      final existingTaskIndex = taskListNotifier.value.indexWhere((task) => task.id == id);
      if (existingTaskIndex == -1) throw Exception('Tarefa com ID $id não encontrada');

      final existingTask = taskListNotifier.value[existingTaskIndex];
      final updatedTask = existingTask.copyWith(
        taskName: taskName,
        taskDetails: taskDetails ?? existingTask.taskDetails,
        completed: completed ?? existingTask.completed,
      );

      await dbHelper.updateTask(updatedTask);
      taskListNotifier.updateTask(updatedTask);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeTask(String id) async {
    try {
      final taskExists = taskListNotifier.value.any((task) => task.id == id);
      if (!taskExists) throw Exception('Tarefa com ID $id não encontrada');

      await dbHelper.deleteTask(id);
      taskListNotifier.removeTask(id);
    } catch (e) {
      print('Erro ao remover tarefa: $e');
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    try {
      final taskIndex = taskListNotifier.value.indexWhere((task) => task.id == id);
      if (taskIndex == -1) throw Exception('Tarefa com ID $id não encontrada');

      final task = taskListNotifier.value[taskIndex];
      final toggledTask = task.copyWith(completed: !task.completed);

      await dbHelper.updateTask(toggledTask);
      taskListNotifier.toggleTaskCompletion(id);
      print('Status da tarefa alterado: ${toggledTask.taskName} - ${toggledTask.completed ? "Concluída" : "Pendente"}');
    } catch (e) {
      print('Erro ao alternar conclusão da tarefa: $e');
      rethrow;
    }
  }

  Future<void> clearCompletedTasks() async {
    try {
      final completedTaskIds = completedTasks.map((task) => task.id).toList();
      for (final id in completedTaskIds) {
        await removeTask(id);
      }
      print('${completedTaskIds.length} tarefas concluídas removidas');
    } catch (e) {
      print('Erro ao limpar tarefas concluídas: $e');
      rethrow;
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      final tasksData = data['tasks'] as List<dynamic>;
      final importedTasks = tasksData.map((taskMap) => Task.fromMap(taskMap)).toList();

      await dbHelper.deleteAllTasks();
      taskListNotifier.clear();

      for (final task in importedTasks) {
        await dbHelper.insertTask(task);
        taskListNotifier.addTask(task);
      }

      print('${importedTasks.length} tarefas importadas com sucesso');
    } catch (e) {
      print('Erro ao importar dados: $e');
      rethrow;
    }
  }

  Map<String, dynamic> exportData() {
    return {
      'tasks': tasks.map((task) => task.toMap()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  Task? getTaskById(String id) {
    try {
      return taskListNotifier.value.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Task> searchTasks(String query) {
    if (query.isEmpty) return tasks;
    final lowercaseQuery = query.toLowerCase();
    return taskListNotifier.value.where((task) {
      return task.taskName.toLowerCase().contains(lowercaseQuery) ||
          (task.taskDetails?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    try {
      taskListNotifier.reorderTasks(oldIndex, newIndex);
      print('Tarefas reordenadas');
    } catch (e) {
      print('Erro ao reordenar tarefas: $e');
      rethrow;
    }
  }

  List<Task> get tasks => taskListNotifier.value;
  List<Task> get completedTasks => taskListNotifier.value.where((task) => task.completed).toList();
  List<Task> get pendingTasks => taskListNotifier.value.where((task) => !task.completed).toList();

  int get taskCount => taskListNotifier.value.length;
  int get completedCount => completedTasks.length;
  int get pendingCount => pendingTasks.length;

  bool get hasTasks => taskCount > 0;
  bool get hasCompletedTasks => completedCount > 0;
  bool get hasPendingTasks => pendingCount > 0;

  double get completionPercentage {
    if (taskCount == 0) return 0.0;
    return (completedCount / taskCount) * 100;
  }

  Map<String, dynamic> getSystemInfo() {
    return {
      'taskCount': taskCount,
      'completedCount': completedCount,
      'pendingCount': pendingCount,
      'completionPercentage': completionPercentage,
      'isLoading': isLoading,
    };
  }

  void dispose() {
    taskListNotifier.dispose();
  }
}

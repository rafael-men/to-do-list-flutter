import 'package:flutter/material.dart';
import 'package:main/models/task.dart';

class TaskListNotifier extends ValueNotifier<List<Task>> {
  TaskListNotifier() : super([]);

  void addTask(Task task) {
    final index = value.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      debugPrint('🔁 Tarefa com ID ${task.id} já existe. Atualizando.');
      updateTask(task);
      return;
    }
    value = [...value, task];
    debugPrint('➕ Tarefa adicionada: ${task.taskName} (Total: ${value.length})');
  }

  void addTasks(List<Task> tasks) {
    if (tasks.isEmpty) return;
    final currentIds = value.map((task) => task.id).toSet();
    final newTasks = tasks.where((task) => !currentIds.contains(task.id)).toList();
    if (newTasks.isNotEmpty) {
      value = [...value, ...newTasks];
      debugPrint('➕ ${newTasks.length} novas tarefas adicionadas');
    }
  }

  void updateTask(Task updatedTask) {
    final index = value.indexWhere((t) => t.id == updatedTask.id);
    if (index == -1) {
      debugPrint('⚠️ Tarefa com ID ${updatedTask.id} não encontrada para atualização');
      return;
    }
    final updated = [...value];
    updated[index] = updatedTask;
    value = updated;
    debugPrint('🔄 Tarefa atualizada: ${updatedTask.taskName}');
  }

  void removeTask(String id) {
    final updated = value.where((t) => t.id != id).toList();
    if (updated.length != value.length) {
      value = updated;
      debugPrint('🗑️ Tarefa removida: $id (Total: ${value.length})');
    } else {
      debugPrint('⚠️ Tarefa com ID $id não encontrada para remoção');
    }
  }

  void removeTasks(List<String> ids) {
    if (ids.isEmpty) return;
    final initial = value.length;
    final idsSet = ids.toSet();
    value = value.where((task) => !idsSet.contains(task.id)).toList();
    debugPrint('🗑️ ${initial - value.length} tarefas removidas');
  }

  void removeCompletedTasks() {
    final initial = value.length;
    value = value.where((task) => !task.completed).toList();
    debugPrint('🗑️ ${initial - value.length} tarefas concluídas removidas');
  }

  void setTasks(List<Task> tasks) {
    value = [...tasks];
    debugPrint('📋 Lista de tarefas definida: ${value.length}');
  }

  void toggleTaskCompletion(String id) {
    final index = value.indexWhere((task) => task.id == id);
    if (index == -1) {
      debugPrint('⚠️ Tarefa $id não encontrada para alternar status');
      return;
    }
    final updatedTask = value[index].copyWith(completed: !value[index].completed);
    final updated = [...value];
    updated[index] = updatedTask;
    value = updated;
    debugPrint('✅ Status alterado: ${updatedTask.taskName} - ${updatedTask.completed ? "Concluída" : "Pendente"}');
  }

  void completeTask(String id) {
    final index = value.indexWhere((task) => task.id == id);
    if (index != -1 && !value[index].completed) {
      final updatedTask = value[index].copyWith(completed: true);
      final updated = [...value];
      updated[index] = updatedTask;
      value = updated;
      debugPrint('✅ Tarefa concluída: ${updatedTask.taskName}');
    }
  }

  void uncompleteTask(String id) {
    final index = value.indexWhere((task) => task.id == id);
    if (index != -1 && value[index].completed) {
      final updatedTask = value[index].copyWith(completed: false);
      final updated = [...value];
      updated[index] = updatedTask;
      value = updated;
      debugPrint('↩️ Tarefa marcada como pendente: ${updatedTask.taskName}');
    }
  }

  void completeAllTasks() {
    value = value.map((task) => task.copyWith(completed: true)).toList();
    debugPrint('✅ Todas as tarefas marcadas como concluídas');
  }

  void uncompleteAllTasks() {
    value = value.map((task) => task.copyWith(completed: false)).toList();
    debugPrint('↩️ Todas as tarefas marcadas como pendentes');
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= value.length || newIndex < 0 || newIndex > value.length) {
      debugPrint('⚠️ Índices de reordenação inválidos');
      return;
    }

    final updated = List<Task>.from(value);
    final task = updated.removeAt(oldIndex);
    updated.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, task);
    value = updated;
    debugPrint('🔃 Tarefa movida: $oldIndex → $newIndex');
  }

  void sortByName({bool ascending = true}) {
    value = [...value]..sort((a, b) => ascending
        ? a.taskName.compareTo(b.taskName)
        : b.taskName.compareTo(a.taskName));
    debugPrint('↕️ Tarefas ordenadas por nome (${ascending ? "A-Z" : "Z-A"})');
  }

  void sortByStatus({bool completedFirst = false}) {
    value = [...value]..sort((a, b) {
      return completedFirst
          ? (b.completed ? 1 : 0) - (a.completed ? 1 : 0)
          : (a.completed ? 1 : 0) - (b.completed ? 1 : 0);
    });
    debugPrint('↕️ Tarefas ordenadas por status (${completedFirst ? "Concluídas primeiro" : "Pendentes primeiro"})');
  }

  void clear() {
    if (value.isNotEmpty) {
      value = [];
      debugPrint('🗑️ Todas as tarefas foram removidas');
    }
  }

  List<Task> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return value;
    return value.where((task) =>
        task.taskName.toLowerCase().contains(q) ||
        (task.taskDetails?.toLowerCase().contains(q) ?? false)).toList();
  }

  List<Task> get completedTasks => value.where((task) => task.completed).toList();
  List<Task> get pendingTasks => value.where((task) => !task.completed).toList();
  int get taskCount => value.length;
  int get completedCount => completedTasks.length;
  int get pendingCount => pendingTasks.length;

  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;
  bool get hasCompletedTasks => completedCount > 0;
  bool get hasPendingTasks => pendingCount > 0;
  bool get allTasksCompleted => isNotEmpty && completedCount == taskCount;

  double get completionPercentage => taskCount == 0 ? 0.0 : (completedCount / taskCount);

  bool hasTask(String id) => value.any((task) => task.id == id);

  Task? getTaskById(String id) {
    try {
      return value.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }

  int getTaskIndex(String id) => value.indexWhere((task) => task.id == id);
}

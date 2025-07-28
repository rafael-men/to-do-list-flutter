import 'package:flutter/material.dart';
import 'package:main/models/task.dart';

class TaskListNotifier extends ValueNotifier<List<Task>> {
  TaskListNotifier() : super(_initialValue);
  
  static final List<Task> _initialValue = <Task>[];
  

  void addTask(Task task) {
    if (value.any((existingTask) => existingTask.id == task.id)) {
      debugPrint('Tarefa com ID ${task.id} já existe. Atualizando ao invés de adicionar.');
      updateTask(task);
      return;
    }
    
    value = [...value, task];
    debugPrint('Tarefa adicionada: ${task.taskName} (Total: ${value.length})');
  }
  

  void addTasks(List<Task> tasks) {
    if (tasks.isEmpty) return;
    
    final currentIds = value.map((task) => task.id).toSet();
    final newTasks = tasks.where((task) => !currentIds.contains(task.id)).toList();
    
    if (newTasks.isNotEmpty) {
      value = [...value, ...newTasks];
      debugPrint('${newTasks.length} tarefas adicionadas (Total: ${value.length})');
    }
  }
  

  void updateTask(Task updatedTask) {
    final index = value.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) {
      debugPrint('Tarefa com ID ${updatedTask.id} não encontrada para atualização');
      return;
    }
    
    value = [
      for (int i = 0; i < value.length; i++)
        if (i != index)
          value[i]
        else
          updatedTask,
    ];
    debugPrint('Tarefa atualizada: ${updatedTask.taskName}');
  }
  

  void removeTask(String id) {
    final initialLength = value.length;
    value = value.where((task) => task.id != id).toList();
    
    if (value.length < initialLength) {
      debugPrint('Tarefa removida: $id (Total: ${value.length})');
    } else {
      debugPrint('Tarefa com ID $id não encontrada para remoção');
    }
  }
  

  void removeTasks(List<String> ids) {
    if (ids.isEmpty) return;
    
    final initialLength = value.length;
    final idsSet = ids.toSet();
    value = value.where((task) => !idsSet.contains(task.id)).toList();
    
    final removedCount = initialLength - value.length;
    debugPrint('$removedCount tarefas removidas (Total: ${value.length})');
  }
  

  void removeCompletedTasks() {
    final initialLength = value.length;
    value = value.where((task) => !task.completed).toList();
    
    final removedCount = initialLength - value.length;
    debugPrint('$removedCount tarefas concluídas removidas (Total: ${value.length})');
  }
  
 
  void setTasks(List<Task> tasks) {
    value = List<Task>.from(tasks); 
    debugPrint('Lista de tarefas definida: ${value.length} tarefas');
  }
  
  
  void toggleTaskCompletion(String id) {
    final index = value.indexWhere((task) => task.id == id);
    if (index == -1) {
      debugPrint('Tarefa com ID $id não encontrada para alternar status');
      return;
    }
    
    final task = value[index];
    final updatedTask = task.copyWith(completed: !task.completed);
    
    value = [
      for (int i = 0; i < value.length; i++)
        if (i != index)
          value[i]
        else
          updatedTask,
    ];
    
    debugPrint('Status alterado: ${updatedTask.taskName} - ${updatedTask.completed ? "Concluída" : "Pendente"}');
  }
  

  void completeTask(String id) {
    final index = value.indexWhere((task) => task.id == id);
    if (index == -1) {
      debugPrint('Tarefa com ID $id não encontrada para marcar como concluída');
      return;
    }
    
    final task = value[index];
    if (!task.completed) {
      final updatedTask = task.copyWith(completed: true);
      value = [
        for (int i = 0; i < value.length; i++)
          if (i != index)
            value[i]
          else
            updatedTask,
      ];
      debugPrint('Tarefa marcada como concluída: ${updatedTask.taskName}');
    }
  }
  
  
  void uncompleteTask(String id) {
    final index = value.indexWhere((task) => task.id == id);
    if (index == -1) {
      debugPrint('Tarefa com ID $id não encontrada para marcar como pendente');
      return;
    }
    
    final task = value[index];
    if (task.completed) {
      final updatedTask = task.copyWith(completed: false);
      value = [
        for (int i = 0; i < value.length; i++)
          if (i != index)
            value[i]
          else
            updatedTask,
      ];
      debugPrint('Tarefa marcada como pendente: ${updatedTask.taskName}');
    }
  }
  

  void completeAllTasks() {
    value = value.map((task) => task.copyWith(completed: true)).toList();
    debugPrint('Todas as tarefas marcadas como concluídas');
  }
  
  
  void uncompleteAllTasks() {
    value = value.map((task) => task.copyWith(completed: false)).toList();
    debugPrint('Todas as tarefas marcadas como pendentes');
  }
  

  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex == newIndex || 
        oldIndex < 0 || oldIndex >= value.length ||
        newIndex < 0 || newIndex >= value.length) {
      return;
    }
    
    final newList = List<Task>.from(value);
    final task = newList.removeAt(oldIndex);
    newList.insert(newIndex, task);
    
    value = newList;
    debugPrint('Tarefas reordenadas: posição $oldIndex -> $newIndex');
  }
  
 
  void sortByName({bool ascending = true}) {
    value = List<Task>.from(value)
      ..sort((a, b) => ascending 
          ? a.taskName.compareTo(b.taskName)
          : b.taskName.compareTo(a.taskName));
    debugPrint('Tarefas ordenadas por nome (${ascending ? "A-Z" : "Z-A"})');
  }
  

  void sortByStatus({bool completedFirst = false}) {
    value = List<Task>.from(value)
      ..sort((a, b) {
        if (completedFirst) {
          return b.completed.toString().compareTo(a.completed.toString());
        } else {
          return a.completed.toString().compareTo(b.completed.toString());
        }
      });
    debugPrint('Tarefas ordenadas por status (${completedFirst ? "concluídas primeiro" : "pendentes primeiro"})');
  }
  

  void clear() {
    if (value.isNotEmpty) {
      value = <Task>[];
      debugPrint('Todas as tarefas removidas');
    }
  }
  

  List<Task> search(String query) {
    if (query.trim().isEmpty) return value;
    
    final lowercaseQuery = query.toLowerCase().trim();
    return value.where((task) {
      return task.taskName.toLowerCase().contains(lowercaseQuery) ||
             (task.taskDetails?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
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
    } catch (e) {
      return null;
    }
  }

  int getTaskIndex(String id) => value.indexWhere((task) => task.id == id);
}
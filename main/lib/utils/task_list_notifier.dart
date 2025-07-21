
import 'package:flutter/material.dart';
import 'package:main/models/task.dart';

class TaskListNotifier extends ValueNotifier<List<Task>> {
  TaskListNotifier() : super(_initialValue);
  
  static final List<Task> _initialValue = <Task>[];


  void addTask(Task task) {  
    value = [...value, task];
  }

  void update(String id, String taskName, {String? taskDetails, bool? completed}) {
    
    value = [
      for (final task in value)
        if (task.id != id) 
          task 
        else 
          task.copyWith(
            taskName: taskName,
            taskDetails: taskDetails,
            completed: completed ?? task.completed,
          )
    ];
    
 
  }

  void removeTask(String id) {
    value = value.where((task) => task.id != id).toList();
  }


  void toggleTaskCompletion(String id) {
    
    value = [
      for (final task in value)
        if (task.id != id) 
          task 
        else 
          task.copyWith(completed: !task.completed)
    ];
  }
}
import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String taskName;
  final String taskDetails;
  final bool completed;
  final String? seriesId; 

  Task({
    required this.id,
    required this.taskName,
    required this.taskDetails,
    required this.completed,
    this.seriesId,
  });


  factory Task.create(String task, String details, {String? seriesId}) {
    final uuid = Uuid().v4();
    return Task(
      id: uuid,
      taskName: task,
      taskDetails: details,
      completed: false,
      seriesId: seriesId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskName': taskName,
      'taskDetails': taskDetails,
      'completed': completed ? 1 : 0,
      'seriesId': seriesId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      taskName: map['taskName'],
      taskDetails: map['taskDetails'],
      completed: map['completed'] == 1,
      seriesId: map['seriesId'],
    );
  }

  Task copyWith({
    String? taskName,
    String? taskDetails,
    bool? completed,
    String? seriesId,
  }) {
    return Task(
      id: id,
      taskName: taskName ?? this.taskName,
      taskDetails: taskDetails ?? this.taskDetails,
      completed: completed ?? this.completed,
      seriesId: seriesId ?? this.seriesId,
    );
  }
}

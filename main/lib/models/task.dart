import 'package:uuid/uuid.dart';

class Task {

  final String id;
  final String taskName;
  final String taskDetails;
  final bool completed;

  Task( {required this.id,required this.taskName, required this.taskDetails, required this.completed});

  factory Task.create(String task,String details) {
    final uuid = Uuid().v4();
    return Task(id:uuid,taskName: task,taskDetails: details,completed: false);
  }

   Task copyWith({
    String? taskName,
    String? taskDetails,
    bool? completed,
  }) {
    return Task(
      id: id,
      taskName: taskName ?? this.taskName,
      taskDetails: taskDetails ?? this.taskDetails,
      completed: completed ?? this.completed,
    );
  }
}
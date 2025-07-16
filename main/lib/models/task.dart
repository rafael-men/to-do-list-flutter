class Task {

  final String taskName;
  final String taskDetails;
  final bool completed;

  Task({required this.taskName, required this.taskDetails, required this.completed});

  factory Task.create(String task,String details) {
    return Task(taskName: task,taskDetails: details,completed: false);
  }

}
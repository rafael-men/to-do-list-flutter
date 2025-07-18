import 'package:flutter/material.dart';
import 'package:main/models/task.dart';
import 'package:main/services/service_locator.dart';
import 'package:main/utils/task_list_controller.dart';

class ListItem extends StatefulWidget {
  const ListItem({super.key, required this.task});
  
  final Task task;
  
  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  late TextEditingController taskController;
  late TextEditingController descriptionController;
  final controller = getIt<TaskListController>();
  
  @override
  void initState() {  
    super.initState();
    taskController = TextEditingController(text: widget.task.taskName);
    descriptionController = TextEditingController(text: widget.task.taskDetails);
  }
  
  @override
  void dispose() { 
    taskController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(value: widget.task.completed, onChanged:onToggled),
              Expanded(child: TextField(
                controller: taskController,
                decoration: InputDecoration(hintText: 'Nome da Tarefa'),
                onChanged:onTaskNameChanged ,
              )),
              IconButton(onPressed: onDeleted, icon: Icon(Icons.delete)
              )
            ],
          ),
          TextField (
            controller: descriptionController,
            decoration: InputDecoration(hintText: 'Digite a descrição da tarefa'),
            maxLines: 2,
            onChanged: onDescriptionChanged 
          )
        ],
      ),
    );
  }
  
 void onToggled(bool? value) {
    if (value != null) {
      controller.update(
        widget.task.id,
        widget.task.taskName,
        taskDetails: widget.task.taskDetails,
        completed: value,
      );
    }
  }

  void onDeleted() {
    controller.removeTask(widget.task.id);
  }

  void onDescriptionChanged(String description) {
    controller.update(
      widget.task.id,
      widget.task.taskName,
      taskDetails: description,
    );
  }

  void onTaskNameChanged(String taskName) {
    controller.update(
      widget.task.id,
      taskName,
      taskDetails: widget.task.taskDetails,
    );
  }
}
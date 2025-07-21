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
      color: const Color.fromARGB(255, 232, 232, 232),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: Offset(2, 2),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: widget.task.completed,
              onChanged: onToggled,
            ),
            Expanded(
              child: TextField(
                controller: taskController,
                onChanged: onTaskNameChanged,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)
                  ),
                  hintText: 'Título da tarefa',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                ),
                style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),
                
              ),
            ),
            IconButton(
              onPressed: onDeleted,
              icon: Icon(Icons.delete),
              tooltip: 'Excluir',
            ),
          ],
        ),
        SizedBox(height: 6),
        TextField(
          controller: descriptionController,
          onChanged: onDescriptionChanged,
          decoration: const InputDecoration(
            hintText: 'Digite a descrição da tarefa',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
          ),
          style: TextStyle(fontSize: 14, color: Colors.black87),
          maxLines: 2,
        ),
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
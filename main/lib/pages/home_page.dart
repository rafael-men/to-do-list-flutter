import 'package:flutter/material.dart';
import 'package:main/models/task.dart';
import 'package:main/utils/task_list_controller.dart';
import 'package:main/widget/page_widget.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<HomePage> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _taskController = TaskListController();


    void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nova Tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  hintText: 'Digite o título da tarefa',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _detailsController,
                decoration: InputDecoration(
                  labelText: 'Detalhes',
                  hintText: 'Digite os detalhes da tarefa',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  _taskController.addTask(
                    Task.create(
                      _titleController.text,
                      _detailsController.text,
                    ),
                  );
                  _titleController.clear();
                  _detailsController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Lista de Tarefas'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PageWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddTaskDialog, tooltip: 'Adicionar Tarefa',child: Icon(Icons.add),),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:main/models/task.dart';
import 'package:main/services/service_locator.dart';
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
  final _taskController = getIt<TaskListController>();

  @override
  void initState() {
    super.initState();
    _loadInitialTasks();
  }


  Future<void> _loadInitialTasks() async {
    await _taskController.loadTasks();
 
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Digite o título da tarefa',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Detalhes',
                  hintText: 'Digite os detalhes da tarefa',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  final newTask = Task.create(
                    _titleController.text,
                    _detailsController.text,
                  );

                  _taskController.addTask(newTask);

                  _titleController.clear();
                  _detailsController.clear();

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Por favor, digite o título da tarefa'),
                      backgroundColor: Colors.red[400],
                    ),
                  );
                }
              },
              child: const Text('Adicionar'),
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
        backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
        title: const Text('Lista de Tarefas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Teste Debug',
            onPressed: () {
              final testTask = Task.create(
                "Teste Debug ${DateTime.now().millisecond}",
                "Tarefa criada pelo botão de debug",
              );

              _taskController.addTask(testTask);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Tarefa de teste adicionada!'),
                  backgroundColor: Colors.green[400],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          PageWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Adicionar Tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:main/models/task.dart';
import 'package:main/services/service_locator.dart';
import 'package:main/utils/task_list_controller.dart';
import 'package:main/utils/task_series_controller.dart';
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
  final _seriesNameController = TextEditingController();
  final _seriesTasksController = TextEditingController();
  final _seriesController = getIt<TaskSeriesController>();


  @override
  void initState() {
    super.initState();
    _loadInitialTasks();
  }


  Future<void> _loadInitialTasks() async {
    await _taskController.loadTasks();
 
  }

  void _showCreateSeriesDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Criar Série de Tarefas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _seriesNameController,
              decoration: const InputDecoration(labelText: 'Nome da Série'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _seriesTasksController,
              decoration: const InputDecoration(
                labelText: 'Tarefas (uma por linha)',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _seriesNameController.text.trim();
              final tarefas = _seriesTasksController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              if (name.isEmpty || tarefas.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha o nome e pelo menos uma tarefa')),
                );
                return;
              }

              final tasks = tarefas
                  .map((desc) => Task.create(desc, "", seriesId: null))
                  .toList();

              await _seriesController.createSeries(name, tasks);
              await _taskController.loadTasks();

              _seriesNameController.clear();
              _seriesTasksController.clear();
              Navigator.pop(context);
            },
            child: const Text('Criar Série'),
          ),
        ],
      );
    },
  );
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
        ],
      ),
      body: ListView(
        children: [
          PageWidget(),
        ],
      ),
      floatingActionButton: Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    FloatingActionButton(
      heroTag: 'fab_series',
      onPressed: _showCreateSeriesDialog,
      tooltip: 'Criar Série de Tarefas',
      mini: true,
      child: const Icon(Icons.playlist_add),
    ),
    const SizedBox(height: 12),
    FloatingActionButton(
      heroTag: 'fab_task',
      onPressed: _showAddTaskDialog,
      tooltip: 'Adicionar Tarefa',
      child: const Icon(Icons.add),
    ),
  ],
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

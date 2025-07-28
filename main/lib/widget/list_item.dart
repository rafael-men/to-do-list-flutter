import 'dart:async';

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

class _ListItemState extends State<ListItem> with TickerProviderStateMixin {
  late TextEditingController taskController;
  late TextEditingController descriptionController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  final controller = getIt<TaskListController>();

  static const Duration _debounceDuration = Duration(milliseconds: 500);
  Timer? _debounceTimer;
  
  bool _isEditing = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
  }
  
  void _initControllers() {
    taskController = TextEditingController(text: widget.task.taskName);
    descriptionController = TextEditingController(text: widget.task.taskDetails ?? '');
  }
  
  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant ListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task != widget.task) {
      _updateControllers();
    }
  }
  
  void _updateControllers() {
    if (taskController.text != widget.task.taskName) {
      taskController.text = widget.task.taskName;
    }
    if (descriptionController.text != (widget.task.taskDetails ?? '')) {
      descriptionController.text = widget.task.taskDetails ?? '';
    }
    _hasUnsavedChanges = false;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _animationController.dispose();
    taskController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: _buildDecoration(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _toggleEditing,
            onLongPress: _showOptionsDialog,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  if (_isEditing || widget.task.taskDetails?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _buildDescription(),
                  ],
                  if (_hasUnsavedChanges) ...[
                    const SizedBox(height: 8),
                    _buildUnsavedIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  BoxDecoration _buildDecoration() {
    final isCompleted = widget.task.completed;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isCompleted
            ? [
                Colors.green.shade50,
                Colors.green.shade100.withOpacity(0.8),
              ]
            : [
                Colors.white,
                const Color(0xFFF8F9FA),
              ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isCompleted 
            ? Colors.green.shade200 
            : Colors.grey.shade200,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildCheckbox(),
        const SizedBox(width: 12),
        Expanded(child: _buildTaskNameField()),
        _buildActionsMenu(),
      ],
    );
  }
  
  Widget _buildCheckbox() {
    return Transform.scale(
      scale: 1.2,
      child: Checkbox(
        value: widget.task.completed,
        onChanged: _onToggled,
        activeColor: Colors.green.shade600,
        checkColor: Colors.white,
        side: BorderSide(
          color: widget.task.completed 
              ? Colors.green.shade600 
              : Colors.grey.shade400,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
  
  Widget _buildTaskNameField() {
    return TextField(
      controller: taskController,
      onChanged: _onTaskNameChanged,
      onTap: () => _setEditing(true),
      decoration: InputDecoration(
        hintText: 'Digite o nome da tarefa',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: _isEditing ? UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ) : InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: widget.task.completed 
            ? Colors.grey.shade600 
            : Colors.black87,
        decoration: widget.task.completed 
            ? TextDecoration.lineThrough 
            : TextDecoration.none,
      ),
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
    );
  }
  
  Widget _buildActionsMenu() {
    return PopupMenuButton<String>(
      onSelected: _onMenuSelected,
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey.shade600,
        size: 20,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy, size: 18),
              SizedBox(width: 8),
              Text('Duplicar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Excluir', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDescription() {
    return TextField(
      controller: descriptionController,
      onChanged: _onDescriptionChanged,
      onTap: () => _setEditing(true),
      decoration: InputDecoration(
        hintText: 'Adicione uma descrição...',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: _isEditing ? UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ) : InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        prefixIcon: Icon(
          Icons.notes,
          size: 16,
          color: Colors.grey.shade500,
        ),
      ),
      style: TextStyle(
        fontSize: 14,
        color: widget.task.completed 
            ? Colors.grey.shade500 
            : Colors.black54,
        decoration: widget.task.completed 
            ? TextDecoration.lineThrough 
            : TextDecoration.none,
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }
  
  Widget _buildUnsavedIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit,
            size: 14,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            'Alterações não salvas',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  void _setEditing(bool editing) {
    if (_isEditing != editing) {
      setState(() {
        _isEditing = editing;
      });
    }
  }
  
  void _toggleEditing() {
    _setEditing(!_isEditing);
  }
  
  void _onToggled(bool? value) async {
    if (value == null) return;
    
    try {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      await controller.updateTask(
        widget.task.id,
        widget.task.taskName,
        taskDetails: widget.task.taskDetails,
        completed: value,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'Tarefa concluída!' : 'Tarefa reaberta',
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar tarefa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _onDeleted() async {
    final shouldDelete = await _showDeleteConfirmation();
    if (shouldDelete == true) {
      try {
        await controller.removeTask(widget.task.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarefa excluída'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir tarefa: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  void _onDuplicated() async {
    try {
      final newTask = Task(
        taskName: '${widget.task.taskName} (Cópia)',
        taskDetails: widget.task.taskDetails,
        completed: false, id: '',
      );
      
      await controller.addTask(newTask);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa duplicada'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao duplicar tarefa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _onMenuSelected(String value) {
    switch (value) {
      case 'edit':
        _setEditing(true);
        break;
      case 'duplicate':
        _onDuplicated();
        break;
      case 'delete':
        _onDeleted();
        break;
    }
  }
  
  void _onDescriptionChanged(String description) {
    _hasUnsavedChanges = true;
    _debouncedUpdate(() {
      controller.updateTask(
        widget.task.id,
        widget.task.taskName,
        taskDetails: description.isEmpty ? null : description,
      );
      _hasUnsavedChanges = false;
    });
  }
  
  void _onTaskNameChanged(String taskName) {
    if (taskName.trim().isEmpty) return;
    
    _hasUnsavedChanges = true;
    _debouncedUpdate(() {
      controller.updateTask(
        widget.task.id,
        taskName.trim(),
        taskDetails: widget.task.taskDetails,
      );
      _hasUnsavedChanges = false;
    });
  }
  
  void _debouncedUpdate(VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      callback();
      if (mounted) setState(() {});
    });
  }
  
  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tarefa'),
        content: Text(
          'Tem certeza de que deseja excluir a tarefa "${widget.task.taskName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showOptionsDialog() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                _setEditing(true);
              },
            ),
            ListTile(
              leading: Icon(
                widget.task.completed ? Icons.undo : Icons.check,
              ),
              title: Text(
                widget.task.completed ? 'Marcar como pendente' : 'Marcar como concluída',
              ),
              onTap: () {
                Navigator.pop(context);
                _onToggled(!widget.task.completed);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicar'),
              onTap: () {
                Navigator.pop(context);
                _onDuplicated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _onDeleted();
              },
            ),
          ],
        ),
      ),
    );
  }
}
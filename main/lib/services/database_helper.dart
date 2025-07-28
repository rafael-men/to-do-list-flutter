import 'package:main/models/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';


import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' 
    if (dart.library.io) 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  DatabaseHelper._init();
  
  static Database? _database;
  static bool _isWebFallback = false;
  static Map<String, dynamic> _webStorage = {};
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    try {
      _database = await _initDB('tasks.db');
      return _database!;
    } catch (e) {
      print('Erro ao inicializar SQLite: $e');
      print('Usando armazenamento em memória como fallback');
      _isWebFallback = true;
      _initWebFallback();
      // Retorna um database mock que nunca será usado
      throw Exception('SQLite indisponível, usando fallback');
    }
  }
  
  void _initWebFallback() {
    // Inicializa o armazenamento em memória se não existir
    if (_webStorage['tasks'] == null) {
      _webStorage['tasks'] = <Map<String, dynamic>>[];
    }
  }
  
  Future<Database> _initDB(String fileName) async {
    if (kIsWeb) {
      try {
        // Tenta configurar o SQLite para web
        databaseFactory = databaseFactoryFfiWeb;
        
        return await openDatabase(
          fileName,
          version: 1,
          onCreate: _createDB,
        );
      } catch (e) {
        print('Falha ao configurar SQLite web: $e');
        rethrow;
      }
    } else {
      // Para plataformas nativas
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, fileName);
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }
  }
  
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        taskName TEXT NOT NULL,
        taskDetails TEXT,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
  
  Future close() async {
    if (!_isWebFallback && _database != null) {
      final db = _database!;
      await db.close();
      _database = null;
    }
  }
  
  Future<int> insertTask(Task task) async {
    try {
      if (_isWebFallback) {
        return _insertTaskWeb(task);
      }
      
      final db = await database;
      return await db.insert('tasks', task.toMap());
    } catch (e) {
      print('Erro ao inserir tarefa, usando fallback: $e');
      _isWebFallback = true;
      _initWebFallback();
      return _insertTaskWeb(task);
    }
  }
  
  int _insertTaskWeb(Task task) {
    _initWebFallback();
    final tasks = List<Map<String, dynamic>>.from(_webStorage['tasks']);
    
    // Verifica se já existe
    if (tasks.any((t) => t['id'] == task.id)) {
      throw Exception('Tarefa com ID ${task.id} já existe');
    }
    
    tasks.add(task.toMap());
    _webStorage['tasks'] = tasks;
    print('Tarefa inserida no fallback: ${task.taskName}');
    return 1; // Simula sucesso
  }
  
  Future<List<Task>> getTasks() async {
    try {
      if (_isWebFallback) {
        return _getTasksWeb();
      }
      
      final db = await database;
      final result = await db.query('tasks', orderBy: 'taskName ASC');
      return result.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      print('Erro ao carregar tarefas, usando fallback: $e');
      _isWebFallback = true;
      _initWebFallback();
      return _getTasksWeb();
    }
  }
  
  List<Task> _getTasksWeb() {
    _initWebFallback();
    final tasks = List<Map<String, dynamic>>.from(_webStorage['tasks']);
    return tasks.map((map) => Task.fromMap(map)).toList();
  }
  
  Future<int> updateTask(Task task) async {
    try {
      if (_isWebFallback) {
        return _updateTaskWeb(task);
      }
      
      final db = await database;
      return await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      print('Erro ao atualizar tarefa, usando fallback: $e');
      _isWebFallback = true;
      _initWebFallback();
      return _updateTaskWeb(task);
    }
  }
  
  int _updateTaskWeb(Task task) {
    _initWebFallback();
    final tasks = List<Map<String, dynamic>>.from(_webStorage['tasks']);
    final index = tasks.indexWhere((t) => t['id'] == task.id);
    
    if (index == -1) {
      throw Exception('Tarefa não encontrada para atualização');
    }
    
    tasks[index] = task.toMap();
    _webStorage['tasks'] = tasks;
    print('Tarefa atualizada no fallback: ${task.taskName}');
    return 1;
  }
  
  Future<int> deleteTask(String id) async {
    try {
      if (_isWebFallback) {
        return _deleteTaskWeb(id);
      }
      
      final db = await database;
      return await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao deletar tarefa, usando fallback: $e');
      _isWebFallback = true;
      _initWebFallback();
      return _deleteTaskWeb(id);
    }
  }
  
  int _deleteTaskWeb(String id) {
    _initWebFallback();
    final tasks = List<Map<String, dynamic>>.from(_webStorage['tasks']);
    final initialLength = tasks.length;
    
    tasks.removeWhere((t) => t['id'] == id);
    _webStorage['tasks'] = tasks;
    
    final deletedCount = initialLength - tasks.length;
    print('Tarefa deletada no fallback: $id');
    return deletedCount;
  }
  
  Future<int> deleteAllTasks() async {
    try {
      if (_isWebFallback) {
        return _deleteAllTasksWeb();
      }
      
      final db = await database;
      return await db.delete('tasks');
    } catch (e) {
      print('Erro ao limpar tarefas, usando fallback: $e');
      _isWebFallback = true;
      _initWebFallback();
      return _deleteAllTasksWeb();
    }
  }
  
  int _deleteAllTasksWeb() {
    _initWebFallback();
    final tasks = List<Map<String, dynamic>>.from(_webStorage['tasks']);
    final count = tasks.length;
    _webStorage['tasks'] = <Map<String, dynamic>>[];
    print('Todas as tarefas removidas do fallback');
    return count;
  }
  
  Future<bool> isDatabaseReady() async {
    try {
      if (_isWebFallback) {
        return true; // Fallback sempre está "pronto"
      }
      
      final db = await database;
      await db.rawQuery('SELECT 1');
      return true;
    } catch (e) {
      print('Database não está pronto, ativando fallback: $e');
      _isWebFallback = true;
      _initWebFallback();
      return true; // Fallback ativo
    }
  }
  
  // Método para verificar se está usando fallback
  bool get isUsingFallback => _isWebFallback;
  
  // Método para forçar fallback (útil para testes)
  void forceFallback() {
    _isWebFallback = true;
    _initWebFallback();
  }
  
  // Método para tentar reconectar ao SQLite
  Future<bool> tryReconnectSQLite() async {
    if (!kIsWeb) return false;
    
    try {
      _isWebFallback = false;
      _database = null;
      
      final db = await database;
      await db.rawQuery('SELECT 1');
      
      // Se chegou até aqui, SQLite está funcionando
      print('Reconexão com SQLite bem-sucedida');
      return true;
    } catch (e) {
      print('Falha na reconexão com SQLite: $e');
      _isWebFallback = true;
      _initWebFallback();
      return false;
    }
  }
  
  // Método para exportar dados do fallback (útil para debug)
  Map<String, dynamic> exportFallbackData() {
    return Map<String, dynamic>.from(_webStorage);
  }
  
  // Método para importar dados para o fallback
  void importFallbackData(Map<String, dynamic> data) {
    _webStorage = data;
  }
  
  // Método para migrar dados do fallback para SQLite
  Future<bool> migrateFallbackToSQLite() async {
    if (!_isWebFallback || !kIsWeb) return false;
    
    try {
      // Salva os dados do fallback
      final fallbackTasks = _getTasksWeb();
      
      // Tenta reconectar ao SQLite
      final connected = await tryReconnectSQLite();
      if (!connected) return false;
      
      // Migra os dados
      final db = await database;
      for (final task in fallbackTasks) {
        await db.insert('tasks', task.toMap());
      }
      
      print('${fallbackTasks.length} tarefas migradas do fallback para SQLite');
      return true;
    } catch (e) {
      print('Erro na migração: $e');
      _isWebFallback = true;
      return false;
    }
  }
}
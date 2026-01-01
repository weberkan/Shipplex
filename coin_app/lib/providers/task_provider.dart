import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/tasks');
      _tasks = (response['data'] as List)
          .map((json) => Task.fromJson(json))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/tasks/all');
      _tasks = (response['data'] as List)
          .map((json) => Task.fromJson(json))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> completeTask(int taskId) async {
    final response = await ApiService.post('/tasks/$taskId/complete', {});
    return response;
  }

  Future<void> createTask(Task task) async {
    final response = await ApiService.post('/tasks', task.toJson());
    _tasks.insert(0, Task.fromJson(response));
    notifyListeners();
  }

  Future<void> updateTask(int id, Task task) async {
    final response = await ApiService.put('/tasks/$id', task.toJson());
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = Task.fromJson(response);
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    await ApiService.delete('/tasks/$id');
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}

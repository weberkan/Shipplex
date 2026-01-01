import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../utils/icon_helper.dart';
import 'task_form_dialog.dart';

class AdminTasksTab extends StatefulWidget {
  const AdminTasksTab({super.key});

  @override
  State<AdminTasksTab> createState() => _AdminTasksTabState();
}

class _AdminTasksTabState extends State<AdminTasksTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskProvider.tasks.isEmpty
              ? const Center(child: Text('Henüz görev yok'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    return _TaskCard(task: task);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Görev Ekle'),
      ),
    );
  }

  void _showTaskForm(BuildContext context, [Task? task]) {
    showDialog(
      context: context,
      builder: (_) => TaskFormDialog(task: task),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: task.isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            IconHelper.getIcon(task.icon),
            color: task.isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: task.isActive ? null : Colors.grey,
                ),
              ),
            ),
            if (!task.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Pasif',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        subtitle: Text('+${task.coinReward} coin'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(task.isActive ? Icons.visibility_off : Icons.visibility),
                  const SizedBox(width: 8),
                  Text(task.isActive ? 'Pasif Yap' : 'Aktif Yap'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleAction(context, value),
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action) async {
    final taskProvider = context.read<TaskProvider>();

    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (_) => TaskFormDialog(task: task),
        );
        break;
      case 'toggle':
        final updatedTask = Task(
          id: task.id,
          title: task.title,
          description: task.description,
          coinReward: task.coinReward,
          icon: task.icon,
          isActive: !task.isActive,
        );
        await taskProvider.updateTask(task.id, updatedTask);
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Görevi Sil'),
            content: Text('${task.title} görevini silmek istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Sil'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await taskProvider.deleteTask(task.id);
        }
        break;
    }
  }
}

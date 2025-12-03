import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../../core/providers/folder_provider.dart';
import '../../../../core/models/task.dart';
import '../../../../core/models/folder.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late Priority _selectedPriority;
  Folder? _selectedFolder;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _selectedPriority = widget.task.priority;
    _startDate = widget.task.startDate;
    _endDate = widget.task.dueDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final folderProvider = context.read<FolderProvider>();

      if (folderProvider.allFolders.isEmpty) {
        folderProvider.fetchFolders().then((_) {
          _setInitialFolder();
        });
      } else {
        _setInitialFolder();
      }
    });
  }

  void _setInitialFolder() {
    if (widget.task.folderId != null) {
      final folderProvider = context.read<FolderProvider>();
      try {
        final folder = folderProvider.allFolders.firstWhere(
          (f) => f.id == widget.task.folderId,
        );
        setState(() {
          _selectedFolder = folder;
        });
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8875FF),
              onPrimary: Colors.white,
              surface: Color(0xFF1D1D1D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM, yyyy').format(date);
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.HIGH:
        return Colors.red;
      case Priority.MEDIUM:
        return Colors.orange;
      case Priority.LOW:
        return Colors.green;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.HIGH:
        return 'First Priority';
      case Priority.MEDIUM:
        return 'Second Priority';
      case Priority.LOW:
        return 'Third Priority';
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final taskProvider = context.read<TaskProvider>();

      final success = await taskProvider.updateTask(
        taskId: widget.task.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _selectedPriority,
        startDate: _startDate,
        dueDate: _endDate,
        folderId: _selectedFolder?.id,
        complete: widget.task.complete,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(taskProvider.errorMessage ?? 'Failed to update task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final folderProvider = context.watch<FolderProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final allFolders = folderProvider.allFolders;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Task',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1D1D1D),
                  title: const Text(
                    "Delete Task",
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    "Are you sure?",
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                await taskProvider.deleteTask(widget.task.id);
                if (mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Name
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1D1D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Name',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Do Homework',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter task name'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1D1D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Description',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Priority
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1D1D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 12),
                    ...Priority.values.map((priority) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(priority),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.flag,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _getPriorityText(priority),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Radio<Priority>(
                                value: priority,
                                groupValue: _selectedPriority,
                                onChanged: (val) {
                                  setState(() {
                                    _selectedPriority = val!;
                                  });
                                },
                                activeColor: const Color(0xFF8BE4A9),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1D1D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Folder',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 12),
                    if (allFolders.isEmpty)
                      Text(
                        'No folders available',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      )
                    else
                      ...allFolders.map((folder) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedFolder = folder;
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.folder,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    folder.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Radio<int>(
                                  value: folder.id,
                                  groupValue: _selectedFolder?.id,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedFolder = folder;
                                    });
                                  },
                                  activeColor: const Color(0xFF8BE4A9),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Date Selectors
              InkWell(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1D1D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                            Text(
                              _formatDate(_startDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1D1D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                            Text(
                              _formatDate(_endDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: taskProvider.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BE4A9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: taskProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Task',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

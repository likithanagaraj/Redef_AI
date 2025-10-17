import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redef_ai_main/models/task.dart';
import 'package:redef_ai_main/providers/tasks_provider.dart';
import '../../Theme.dart';

class EditDeleteTaskDialog extends StatefulWidget {
  final Task task;

  const EditDeleteTaskDialog({
    super.key,
    required this.task,
  });

  @override
  State<EditDeleteTaskDialog> createState() => _EditDeleteTaskDialogState();
}

class _EditDeleteTaskDialogState extends State<EditDeleteTaskDialog> {
  late TextEditingController _nameController;
  late TextEditingController _newCategoryController;
  String? _selectedCategory;
  bool _isCreatingNewCategory = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
    _newCategoryController = TextEditingController();
    _selectedCategory = widget.task.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter task name');
      return;
    }

    String? categoryToUse;
    if (_isCreatingNewCategory) {
      if (_newCategoryController.text.trim().isEmpty) {
        _showError('Please enter category name');
        return;
      }
      categoryToUse = _newCategoryController.text.trim();
    } else {
      categoryToUse = _selectedCategory;
    }

    final provider = context.read<TaskProvider>();
    final success = await provider.updateTask(
      taskId: widget.task.id,
      name: _nameController.text.trim(),
      category: categoryToUse,
    );

    if (success) {
      Navigator.pop(context);
      _showSuccess('Task updated successfully');
    } else {
      _showError('Failed to update task. Please try again.');
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = context.read<TaskProvider>();
      final success = await provider.deleteTask(widget.task.id);

      if (success) {
        Navigator.pop(context);
        _showSuccess('Task deleted successfully');
      } else {
        _showError('Failed to delete task. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTaskNameField(),
                  const SizedBox(height: 24),
                  _buildCategorySection(provider.categories),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Edit Task',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'SourceSerif4',
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: _handleDelete,
              child: Icon(Icons.delete_outline, size: 24, color: Colors.red.shade600),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, size: 24),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskNameField() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        hintText: 'Task name',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildCategorySection(List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isCreatingNewCategory = !_isCreatingNewCategory;
                  if (_isCreatingNewCategory) _selectedCategory = null;
                });
              },
              icon: Icon(
                _isCreatingNewCategory ? Icons.list : Icons.add,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                _isCreatingNewCategory ? 'Select existing' : 'Create new',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isCreatingNewCategory)
          _buildNewCategoryField()
        else if (categories.isEmpty)
          _buildEmptyCategoryState()
        else
          _buildCategoryChips(categories),
      ],
    );
  }

  Widget _buildNewCategoryField() {
    return TextField(
      controller: _newCategoryController,
      decoration: InputDecoration(
        hintText: 'Enter new category name',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildEmptyCategoryState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        'No categories yet. Create one!',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((catName) {
        final isSelected = _selectedCategory == catName;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = isSelected ? null : catName;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : Colors.white,
              border: Border.all(color: AppColors.secondary, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              catName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Update',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
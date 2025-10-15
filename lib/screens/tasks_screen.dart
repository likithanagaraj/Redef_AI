import 'package:flutter/material.dart';
import 'package:redef_ai_main/Theme.dart';
import '../core/supabase_config.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List tasks = [];
  List<String> categories = [];
  bool isLoading = true;
  String selectedCategory = 'all';
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    final authUserId = SupabaseConfig.client.auth.currentUser?.id;
    print("🎁$authUserId");
    if (authUserId == null) {
      print('No auth user found!');
      setState(() => isLoading = false);
      return;
    }

    // Get internal user id
    final userRow = await SupabaseConfig.client
        .from('users')
        .select('id')
        .eq('auth_user_id', authUserId)
        .maybeSingle();

    if (userRow == null) {
      print('No public user found for this auth user!');
      setState(() => isLoading = false);
      return;
    }

    userId = userRow['id']; // This is what we MUST use for tasks.user_id
    print('Internal user ID✅✅⌚: $userId');

    try {
      final response = await SupabaseConfig.client
          .from('tasks')
          .select('*')
          .eq('user_id', userId!) // ✅ use internal user ID here
          .order('created_at', ascending: false);
      print('Fetched tasks:🥇 $response');
      final uniqueCats = <String>{};
      for (var task in response) {
        if (task['category'] != null && task['category'].toString().isNotEmpty) {
          uniqueCats.add(task['category'].toString());
        }
      }

      setState(() {
        tasks = response;
        categories = uniqueCats.toList()..sort();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }


  void toggleTaskCompletionLocally(String taskId) {
    setState(() {
      final idx = tasks.indexWhere((t) => t['id'] == taskId);
      if (idx != -1) {
        tasks[idx]['is_completed'] = !(tasks[idx]['is_completed'] ?? false);
        tasks[idx]['completed_at'] =
        tasks[idx]['is_completed'] ? DateTime.now().toIso8601String() : null;
      }
    });
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    toggleTaskCompletionLocally(taskId);

    try {
      await SupabaseConfig.client
          .from('tasks')
          .update({
        'is_completed': !isCompleted,
        'completed_at': !isCompleted ? DateTime.now().toIso8601String() : null,
      })
          .eq('id', taskId);
    } catch (e) {
      print('Error updating task: $e');
      // If error, revert local change
      toggleTaskCompletionLocally(taskId);
    }
  }

  List getFilteredTasks() {
    if (selectedCategory == 'all') return tasks;
    return tasks.where((task) => task['category'] == selectedCategory).toList();
  }

  List getActiveTasks() {
    return getFilteredTasks().where((task) => task['is_completed'] != true).toList();
  }

  List getCompletedTasks() {
    return getFilteredTasks().where((task) => task['is_completed'] == true).toList();
  }

  void addTaskDialog() {
    final nameController = TextEditingController();
    final newCategoryController = TextEditingController();
    String? selectedCategoryForTask;
    bool isCreatingNewCategory = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Task',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'SourceSerif4',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
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
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setModalState(() {
                            isCreatingNewCategory = !isCreatingNewCategory;
                            if (isCreatingNewCategory) selectedCategoryForTask = null;
                          });
                        },
                        icon: Icon(isCreatingNewCategory ? Icons.list : Icons.add, size: 18, color: Color(0xFF014E3C)),
                        label: Text(
                          isCreatingNewCategory ? 'Select existing' : 'Create new',
                          style: const TextStyle(color: Color(0xFF014E3C), fontWeight: FontWeight.w600),
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
                  if (isCreatingNewCategory)
                    TextField(
                      controller: newCategoryController,
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
                    )
                  else if (categories.isEmpty)
                    Container(
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
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((catName) {
                        final isSelected = selectedCategoryForTask == catName;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedCategoryForTask = isSelected ? null : catName;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ?  AppColors.secondary: Colors.white,
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
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter task name'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        String? categoryToUse;
                        if (isCreatingNewCategory) {
                          if (newCategoryController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter category name'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          categoryToUse = newCategoryController.text.trim();
                        } else {
                          categoryToUse = selectedCategoryForTask ?? 'Uncategorized';
                        }

                        if (userId == null) return;

                        try {
                          await SupabaseConfig.client.from('tasks').insert({
                            'name': nameController.text.trim(),
                            'category': categoryToUse,
                            'is_completed': false,
                            'user_id': userId, // <-- MUST use users.id, not auth_user_id
                          });


                          Navigator.pop(context);
                          fetchData();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task added successfully'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          print('Error adding task: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF014E3C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = getActiveTasks();
    final completedTasks = getCompletedTasks();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 28,
                    color: Color(0xFF014E3C),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Tasks',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'SourceSerif4',
                      color: Color(0xFF014E3C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Category chips
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => selectedCategory = 'all'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: selectedCategory == 'all' ? AppColors.secondary : Colors.transparent,
                            border: Border.all(color: AppColors.secondary, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'All',
                            style: TextStyle(
                              color: selectedCategory == 'all' ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...categories.map((catName) {
                        final isSelected = selectedCategory == catName;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedCategory = catName),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.secondary : Colors.white,
                                border: Border.all(color: AppColors.secondary, width: isSelected ? 2 : 1.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                catName,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Task list
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF014E3C)),
              )
                  : activeTasks.isEmpty && completedTasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      selectedCategory == 'all' ? 'No tasks yet' : 'No tasks in this category',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text('Tap + to add a new task', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                  ],
                ),
              )
                  : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Active tasks
                  if (activeTasks.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: activeTasks.map((task) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: task['is_completed'] ?? false,
                                onChanged: (_) => toggleTaskCompletion(task['id'], task['is_completed'] ?? false),
                                side: const BorderSide(color: Colors.black, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['name'] ?? 'No Name',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                                    ),
                                    // if (task['category'] != null && task['category'].toString().isNotEmpty)
                                    //   Text(
                                    //     task['category'],
                                    //     style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                    //   ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                  // Completed tasks
                  if (completedTasks.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Completed', style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: completedTasks.map((task) {
                          return Row(
                            children: [
                              Checkbox(
                                activeColor: Colors.grey.shade400,
                                value: task['is_completed'] ?? false,
                                onChanged: (_) => toggleTaskCompletion(task['id'], task['is_completed'] ?? false),
                                side: const BorderSide(color: Colors.black, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['name'] ?? 'No Name',
                                      style: TextStyle(
                                        fontSize: 16,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    // if (task['category'] != null && task['category'].toString().isNotEmpty)
                                    //   Text(
                                    //     task['category'],
                                    //     style: TextStyle(fontSize: 12, color: Colors.grey.shade500, decoration: TextDecoration.lineThrough),
                                    //   ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        onPressed: addTaskDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}

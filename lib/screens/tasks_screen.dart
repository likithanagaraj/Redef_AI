import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../design_tokens.dart';
import 'package:redef_ai_main/services/sync_manager.dart';
import '../models/task.dart';
import '../constants.dart';
import '../widgets/dashed_border.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedCategory = "All";
  
  List<Task> tasks = [];
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final isar = Isar.getInstance()!;
    final loadedTasks = await isar.tasks.where().filter().isDeletedEqualTo(false).findAll();
    
    final Set<String> uniqueCats = {};
    for (var t in loadedTasks) {
      if (t.category != null && t.category!.isNotEmpty) {
        uniqueCats.add(t.category!);
      }
    }
    
    setState(() {
      tasks = loadedTasks;
      _categories = uniqueCats.toList();
      tasks.sort((a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0));
    });
  }

  List<Task> get _filteredTasks {
    if (_selectedCategory == "All") return tasks;
    return tasks.where((t) => t.category == _selectedCategory).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "today";
    }
    return DateFormat('dd-MM-yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.lg,
),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TASKS",
                    style: TextStyle(
                      fontFamily: "ndot",
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddTaskBottomSheet(context),
                    child: DashedBorder(
                      color: textColor,
                      isCircle: true,
                      radius: 20,
                      dashWidth: 2,
                      dashSpace: 3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: textColor, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            // Categories Horizontal Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
              child: Row(
                children: [
                  _buildCategoryBadge("All", _selectedCategory, (v) => setState(() => _selectedCategory = v)),
                  ..._categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _buildCategoryBadge(cat, _selectedCategory, (v) => setState(() => _selectedCategory = v)),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xxl),

            // Task List
            Expanded(
              child: _filteredTasks.isEmpty 
               ? Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       SvgPicture.asset(
                         "assets/icons/solid-task.svg",
                         width: 64,
                         height: 64,
                         colorFilter: ColorFilter.mode(textColor.withValues(alpha: 0.3), BlendMode.srcIn),
                       ),
                       const SizedBox(height: 16),
                       Text(
                         "No task yet. Create one!",
                         style: TextStyle(
                           fontFamily: "TTNormsPro",
                           fontSize: 16,
                           color: textColor.withValues(alpha:  0.5),
                         ),
                       ),
                     ],
                   ),
                 )
               : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                itemCount: _filteredTasks.length,
                itemBuilder: (context, index) {
                  return _buildTaskCard(_filteredTasks[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String text, String selected, Function(String) onTap) {
    bool isSelected = text == selected;
    Widget child = Container(
      padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.sm,
),
      decoration: BoxDecoration(
        color: isSelected ? textColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "TTNormsPro",
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? scaffoldBg : textColor.withValues(alpha: 0.5),
        ),
      ),
    );

    return GestureDetector(
      onTap: () => onTap(text),
      child: isSelected
          ? child
          : DashedBorder(
              color: textColor.withValues(alpha: 0.3),
              radius: 20,
              dashSpace: 4,
              dashWidth: 4,
              child: child,
            ),
    );
  }

  Widget _buildTaskCard(Task task, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.lg),
      child: Dismissible(
        key: Key("${task.name}_$index"),
        background: _buildEditBackground(),
        secondaryBackground: _buildDeleteBackground(),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            bool? delete = await _showDeleteDialog(context);
            if (delete == true) {
               final isar = Isar.getInstance()!;
               task.markAsDeleted();
               await isar.writeTxn(() async {
                 await isar.tasks.put(task);
               });
               _loadTasks();
               WidgetService.updateWidgetData();
               SyncManager().syncUp();

            }
            return delete;
          }
          if (direction == DismissDirection.startToEnd) {
             _showAddTaskBottomSheet(context, taskToEdit: task);
            return false;
          }
          return false;
        },
        child: GestureDetector(
          onTap: () async {
            final isar = Isar.getInstance()!;
            task.isCompleted = !task.isCompleted;
            task.markAsUpdated();
            await isar.writeTxn(() async {
              await isar.tasks.put(task);
            });
            _loadTasks();
            WidgetService.updateWidgetData();
            NotificationService().reevaluateNotifications();
            SyncManager().syncUp();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.lg,
),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      style: TextStyle(
                        fontFamily: "ndot",
                        fontSize: 16,
                        color: task.isCompleted ? textColor.withValues(alpha:  0.5) : textColor,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        decorationColor: task.isCompleted ? textColor.withValues(alpha: 0.5) : textColor,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cta,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatDate(task.createdAt),
                        style: const TextStyle(
                          fontFamily: "TTNormsPro",
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.lg),
              GestureDetector(
                onTap: () async {
                  final isar = Isar.getInstance()!;
                  task.isCompleted = !task.isCompleted;
                  task.markAsUpdated();
                  await isar.writeTxn(() async {
                    await isar.tasks.put(task);
                  });
                  _loadTasks();
                  NotificationService().reevaluateNotifications();
                  SyncManager().syncUp();
                },
                child: task.isCompleted
                  ? Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: textColor,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SvgPicture.asset(
                          "assets/icons/checked.svg",
                          colorFilter: const ColorFilter.mode(scaffoldBg, BlendMode.srcIn),
                        ),
                      ),
                    )
                  : DashedBorder(
                      color: textColor.withValues(alpha: 0.5),
                      isCircle: true,
                      dashWidth: 4,
                      dashSpace: 3,
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                      ),
                    ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildEditBackground() {
    return Container(
      decoration: BoxDecoration(
        color: textColor,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Edit",
            style: TextStyle(
              fontFamily: "TTNormsPro",
              fontSize: 12,
              color: scaffoldBg,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          SvgPicture.asset(
            "assets/icons/edit.svg",
            width: 14,
            height: 14,
            colorFilter: const ColorFilter.mode(scaffoldBg, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Delete",
            style: TextStyle(
              fontFamily: "TTNormsPro",
              fontSize: 12,
              color: cta,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          SvgPicture.asset(
            "assets/icons/delete.svg",
            width: 14,
            height: 14,
            colorFilter: const ColorFilter.mode(cta, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.small)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delete Task?",
                  style: TextStyle(
                    fontFamily: "TTNormsPro",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: scaffoldBg,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  "This action cannot be undone and will be removed from your records.",
                  style: TextStyle(
                    fontFamily: "TTNormsPro",
                    fontSize: 14,
                    color: scaffoldBg.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontFamily: "TTNormsPro",
                          fontSize: 14,
                          color: scaffoldBg.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: cta.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            fontFamily: "TTNormsPro",
                            fontSize: 14,
                            color: cta,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTaskBottomSheet(BuildContext context, {Task? taskToEdit}) {
    String selectedCategory = taskToEdit?.category ?? "";
    bool isCreatingNewCategory = false;
    TextEditingController nameController = TextEditingController(text: taskToEdit?.name ?? "");
    TextEditingController categoryController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 32,
              ),
              decoration: const BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.sheet),
                  topRight: Radius.circular(AppRadius.sheet),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add Task",
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: scaffoldBg,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Name",
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 14,
                      color: scaffoldBg,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: scaffoldBg.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: nameController,
                      style: const TextStyle(
                        fontFamily: "TTNormsPro",
                        color: scaffoldBg,
                      ),
                      cursorColor: cta,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "e.g. Submit the report",
                        hintStyle: TextStyle(
                          fontFamily: "TTNormsPro",
                          color: scaffoldBg.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Category",
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 14,
                      color: scaffoldBg,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  if (_categories.isEmpty)
                    const SizedBox.shrink()
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: [
                        ..._categories.map((cat) => _buildAddCategoryBadge(cat, selectedCategory, (v) => setModalState(() => selectedCategory = v))).toList(),
                        _buildAddCategoryBadge("none", selectedCategory, (v) => setModalState(() => selectedCategory = v)),
                      ],
                    ),
                  if (_categories.isNotEmpty) const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      isCreatingNewCategory
                        ? Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: scaffoldBg.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: categoryController,
                                autofocus: true,
                                style: const TextStyle(
                                  fontFamily: "TTNormsPro",
                                  color: scaffoldBg,
                                ),
                                cursorColor: cta,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Category name",
                                  hintStyle: TextStyle(
                                    fontFamily: "TTNormsPro",
                                    color: scaffoldBg.withValues(alpha:  0.3),
                                  ),
                                ),
                                onSubmitted: (val) {
                                  if (val.isNotEmpty) {
                                    setModalState(() {
                                      _categories.add(val);
                                      selectedCategory = val;
                                      isCreatingNewCategory = false;
                                    });
                                  } else {
                                    setModalState(() => isCreatingNewCategory = false);
                                  }
                                },
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                               setModalState(() => isCreatingNewCategory = true);
                            },
                            child: DashedBorder(
                              color: scaffoldBg.withValues(alpha:  0.3),
                              radius: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.sm,
),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _categories.isEmpty ? "No category .Create one" : "Create new",
                                      style: const TextStyle(
                                        fontFamily: "TTNormsPro",
                                        fontSize: 12,
                                        color: scaffoldBg,
                                      ),
                                    ),
                                    const SizedBox(width: Spacing.xs),
                                    const Icon(Icons.add_circle_outline, size: 14, color: scaffoldBg),
                                  ],
                                ),
                              ),
                            ),
                          )
                    ],
                  ),
                  const SizedBox(height: Spacing.xxl),
                  GestureDetector(
                    onTap: () async {
                      if (nameController.text.isNotEmpty) {
                        final isar = Isar.getInstance()!;
                        final t = taskToEdit ?? Task();
                        if (taskToEdit == null) {
                           t.createdAt = DateTime.now();
                           t.ensureRemoteId();
                        } else {
                           t.markAsUpdated();
                        }
                        String? finalCat = selectedCategory;
                        if (isCreatingNewCategory && categoryController.text.isNotEmpty) {
                          finalCat = categoryController.text.trim();
                        }
                        
                        t.name = nameController.text;
                        t.category = (finalCat == "none" || finalCat!.isEmpty) ? null : finalCat;
                        
                        await isar.writeTxn(() async {
                           await isar.tasks.put(t);
                        });
                         _loadTasks();
                         WidgetService.updateWidgetData();
                SyncManager().syncUp();

                      }
                      if (mounted) Navigator.pop(context);
                    },
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cta,
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            taskToEdit != null ? "Save Changes" : "Add New Task",
                            style: TextStyle(
                              fontFamily: "ndot",
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          SvgPicture.asset(
                            "assets/icons/create.svg",
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(textColor, BlendMode.srcIn),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.xxl),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddCategoryBadge(String text, String selected, Function(String) onTap) {
    bool isSelected = text == selected;
    return GestureDetector(
      onTap: () => onTap(text),
      child: isSelected 
        ? Container(
            padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.sm,
),
            decoration: BoxDecoration(
              color: scaffoldBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: "TTNormsPro",
                fontSize: 12,
                color: textColor,
              ),
            ),
          )
        : DashedBorder(
            color: scaffoldBg.withValues(alpha: 0.3),
            radius: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.sm,
),
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 12,
                  color: scaffoldBg,
                ),
              ),
            ),
          ),
    );
  }
}

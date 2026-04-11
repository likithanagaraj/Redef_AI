import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../constants.dart';
import '../design_tokens.dart';
import '../widgets/dashed_border.dart';
import 'main_screen.dart';
import 'package:redef_ai_main/services/sync_manager.dart';
import '../models/habit.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import 'habit_statistics_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  @override
  _HabitsScreenState createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late DateTime today;
  late DateTime selectedDate;
  late List<DateTime> weekDates;
  bool _showNotifPrompt = false;

  List<Habit> habits = [];
  String _selectedCategory = "All";
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    selectedDate = today;
    weekDates = List.generate(7, (i) => today.subtract(Duration(days: 3 - i)));
    _loadHabits();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final isar = Isar.getInstance();
    if (isar == null) return;
    final settings = await isar.notificationSettings.get(1);
    
    if (settings != null && (settings.habitReminders || settings.pendingTasksReminder)) {
       await NotificationService().reevaluateNotifications();
       setState(() => _showNotifPrompt = false);
    } else {
       setState(() => _showNotifPrompt = true);
    }
  }

  Future<void> _loadHabits() async {
    final isar = Isar.getInstance()!;
    final loadedHabits = await isar.habits.where().filter().isDeletedEqualTo(false).findAll();
    
    final Set<String> uniqueCats = {};
    for (var h in loadedHabits) {
      if (h.category != null && h.category!.isNotEmpty) {
        uniqueCats.add(h.category!);
      }
    }
    
    setState(() {
      habits = loadedHabits;
      _categories = uniqueCats.toList();
      habits.sort((a, b) => (a.isCheckedOn(selectedDate) ? 1 : 0).compareTo(b.isCheckedOn(selectedDate) ? 1 : 0));
    });
  }

  List<Habit> _getFilteredHabitsForDate(DateTime date) {
    final selMidnight = DateTime(date.year, date.month, date.day);
    return habits.where((habit) {
      if (_selectedCategory != "All" && habit.category != _selectedCategory) return false;
      final startMidnight = DateTime(habit.startedAt.year, habit.startedAt.month, habit.startedAt.day);
      if (selMidnight.isBefore(startMidnight)) return false;
      if (habit.endDate != null && selMidnight.isAfter(DateTime(habit.endDate!.year, habit.endDate!.month, habit.endDate!.day))) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.lg,
),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "HABITS",
                    style: TextStyle(
                      fontFamily: "ndot",
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddHabitBottomSheet(context),
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
              const SizedBox(height: Spacing.xxl),

              if (_showNotifPrompt)
                _buildNotificationRequestCard(),

              if (_showNotifPrompt)
                const SizedBox(height: Spacing.xl),

              // Horizontal Date Scroll
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekDates.map((date) {
                  return _buildDateWidget(date);
                }).toList(),
              ),
              const SizedBox(height: Spacing.xl),

              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Statistics",
                            style: TextStyle(
                              fontFamily: "TTNormsPro",
                              fontSize: 18,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "See how your habits are shaping your day\nStay consistent with real insights",
                            style: TextStyle(
                              fontFamily: "TTNormsPro",
                              fontSize: 12,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HabitStatisticsScreen()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: cta,
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                              child: const Text(
                                "View Stats",
                                style: TextStyle(
                                  fontFamily: "ndot",
                                  fontSize: 10,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                     const Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.bar_chart_rounded, size: 80, color: textColor),
                      ),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // Categories Horizontal Scroll
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
              const SizedBox(height: Spacing.xl),

              // Habits List
              Builder(
                builder: (context) {
                  final visibleHabits = _getFilteredHabitsForDate(selectedDate);


                  if (visibleHabits.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: Spacing.xxl),
                          SvgPicture.asset(
                            "assets/icons/whiteStreaks.svg",
                            width: 64,
                            height: 64,
                            colorFilter: ColorFilter.mode(textColor.withValues(alpha: 0.3), BlendMode.srcIn),
                          ),
                          const SizedBox(height: Spacing.lg),
                          Text(
                            "No habits on this date.",
                            style: TextStyle(
                              fontFamily: "TTNormsPro",
                              fontSize: 16,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                    children: visibleHabits.map((habit) => _buildHabitCard(habit)).toList(),
                  );
                },
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
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

  Widget _buildDateWidget(DateTime date) {
    bool isToday = date.year == today.year && date.month == today.month && date.day == today.day;
    bool isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;

    Color bgColor = Colors.transparent;
    Color txtColor = textColor;

    if (isToday) {
      bgColor = textColor;
      txtColor = scaffoldBg;
    } else if (isSelected) {
      bgColor = cta;
      txtColor = textColor;
    }

    Widget content = Column(
      children: [
        Text(
          DateFormat('E').format(date),
          style: const TextStyle(
            fontFamily: "ndot",
            fontSize: 12,
            color: textColor,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Container(
          width: ComponentSize.dateCircle,
          height: ComponentSize.dateCircle,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
          ),
          child: Text(
            date.day.toString(),
            style: TextStyle(
              fontFamily: "TTNormsPro",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: txtColor,
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
      },
      child: (isSelected || isToday)
        ? content 
        : Column(
            children: [
              Text(
                DateFormat('E').format(date),
                style: const TextStyle(
                  fontFamily: "ndot",
                  fontSize: 12,
                  color: textColor,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              DashedBorder(
                color: textColor.withValues(alpha: 0.3),
                dashWidth: 4,
                dashSpace: 4,
                isCircle: true,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: txtColor,
                    ),
                  ),
                ),
              )
            ],
          ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    bool isChecked = habit.isCheckedOn(selectedDate);
    int streak = habit.calculateStreak(today);
    bool isAchieved = streak > 0;
    
    final selMidnight  = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final todayMidnight = DateTime(today.year, today.month, today.day);
    bool isFutureDate = selMidnight.isAfter(todayMidnight);

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Dismissible(
        key: Key("habit_${habit.id}"),
        background: _buildEditBackground(),
        secondaryBackground: _buildDeleteBackground(),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            bool? delete = await _showDeleteDialog(context);
            if (delete == true) {
               final isar = Isar.getInstance()!;
               habit.markAsDeleted();
               await isar.writeTxn(() async => await isar.habits.put(habit));
               _loadHabits();
               SyncManager().syncUp();
            }
            return delete;
          }
          if (direction == DismissDirection.startToEnd) {
            _showAddHabitBottomSheet(context, habitToEdit: habit);
            return false;
          }
          return false;
        },
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)));
          },
          child: Opacity(
            opacity: isFutureDate ? 0.4 : 1.0,
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
                      habit.name,
                      style: TextStyle(
                        fontFamily: "ndot",
                        fontSize: 16,
                        color: isChecked ? textColor.withValues(alpha: 0.5) : textColor,
                        decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                        decorationColor: isChecked ? textColor.withValues(alpha: 0.5) : textColor,
                      ),
                    ),
                const SizedBox(height: Spacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isAchieved ? cta : textColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$streak days",
                        style: TextStyle(
                          fontFamily: "TTNormsPro",
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isAchieved ? textColor : cta,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      SvgPicture.asset(
                        "assets/icons/ctaStreaks.svg",
                        width: 12,
                        height: 12,
                        colorFilter: ColorFilter.mode(isAchieved ? textColor : cta, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.lg),
          GestureDetector(
            onTap: isFutureDate ? null : () async {
              final isar = Isar.getInstance()!;
              final midnight = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
              final startMidnight = DateTime(habit.startedAt.year, habit.startedAt.month, habit.startedAt.day);

              if (midnight.isBefore(startMidnight)) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("Cannot log completion before habit start date.")),
                 );
                 return;
              }

              final activeDates = habit.completedDates.toList();
              
              if (isChecked) {
                activeDates.removeWhere((d) => d.year == midnight.year && d.month == midnight.month && d.day == midnight.day);
              } else {
                activeDates.add(midnight);
              }
              habit.completedDates = activeDates;
              habit.cleanupCompletions();
              habit.markAsUpdated();
              
              await isar.writeTxn(() async => await isar.habits.put(habit));
              _loadHabits();
              WidgetService.updateWidgetData();
              NotificationService().reevaluateNotifications();
              SyncManager().syncUp();
            },
            child: isChecked
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
      )
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
                  "Delete Habit?",
                  style: TextStyle(
                    fontFamily: "TTNormsPro",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: scaffoldBg,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "This action cannot be undone and will be removed from your records.",
                  style: TextStyle(
                    fontFamily: "TTNormsPro",
                    fontSize: 14,
                    color: scaffoldBg.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: Spacing.xl),
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
                    const SizedBox(width: Spacing.lg),
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

  void _showAddHabitBottomSheet(BuildContext context, {Habit? habitToEdit}) {
    String selectedCategory = habitToEdit?.category ?? "";
    bool isCreatingNewCategory = false;
    TextEditingController nameController = TextEditingController(text: habitToEdit?.name ?? "");
    TextEditingController descController = TextEditingController(text: habitToEdit?.description ?? "");
    TextEditingController categoryController = TextEditingController();
    DateTime habitStartDate = habitToEdit?.startedAt ?? DateTime.now();
    DateTime? habitEndDate = habitToEdit?.endDate;

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                habitToEdit != null ? "Edit Habit" : "Add Habit",
                style: const TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: scaffoldBg,
                ),
              ),
              const SizedBox(height: Spacing.xl),
              const Text(
                "Name",
                style: TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 14,
                  color: scaffoldBg,
                ),
              ),
              const SizedBox(height: 12),
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
                    hintText: "e.g Morning walk",
                    hintStyle: TextStyle(
                      fontFamily: "TTNormsPro",
                      color: scaffoldBg.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xl),
              const Text(
                "Description(optional)",
                style: TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 14,
                  color: scaffoldBg,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: scaffoldBg.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: descController,
                  style: const TextStyle(
                    fontFamily: "TTNormsPro",
                    color: scaffoldBg,
                  ),
                  cursorColor: cta,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "e.g Get up at 6:00 for morning walk",
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
              // Date Pickers for Start and End Dates
              const SizedBox(height: Spacing.xl),
              const Text(
                "Start Date",
                style: TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 14,
                  color: scaffoldBg,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: habitStartDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: cta,
                            onPrimary: textColor,
                            onSurface: scaffoldBg,
                            surface: textColor,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: scaffoldBg,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setModalState(() => habitStartDate = picked);
                  }
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: scaffoldBg.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(habitStartDate),
                        style: const TextStyle(
                          fontFamily: "TTNormsPro",
                          fontSize: 14,
                          color: scaffoldBg,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: scaffoldBg),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              const Text(
                "End Date (optional)",
                style: TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 14,
                  color: scaffoldBg,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: habitEndDate ?? habitStartDate,
                    firstDate: habitStartDate,
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: cta,
                            onPrimary: textColor,
                            onSurface: scaffoldBg,
                            surface: textColor,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: scaffoldBg,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setModalState(() => habitEndDate = picked);
                  }
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: scaffoldBg.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        habitEndDate != null ? DateFormat('dd MMM yyyy').format(habitEndDate!) : "No end date",
                        style: const TextStyle(
                          fontFamily: "TTNormsPro",
                          fontSize: 14,
                          color: scaffoldBg,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: scaffoldBg),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xxl),

              GestureDetector(
                onTap: () async {
                  if (nameController.text.isNotEmpty) {
                    final isar = Isar.getInstance()!;
                    final h = habitToEdit ?? Habit()
                       ..createdAt = habitToEdit?.createdAt ?? DateTime.now()
                      ..startedAt = habitStartDate
                      ..endDate = habitEndDate;
                    
                    String? finalCat = selectedCategory;
                    if (isCreatingNewCategory && categoryController.text.isNotEmpty) {
                      finalCat = categoryController.text.trim();
                    }                    
                    
                    h.name = nameController.text;
                    h.description = descController.text.isEmpty ? null : descController.text;
                    h.category = (finalCat == "none" || finalCat!.isEmpty) ? null : finalCat;
                    if (habitToEdit == null) {
                       h.completedDates = [];
                       h.ensureRemoteId();
                    } else {
                       h.markAsUpdated();
                    }

                    
                    await isar.writeTxn(() async => await isar.habits.put(h));
                    _loadHabits();
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
                        habitToEdit != null ? "Save Changes" : "Create new Habit",
                        style: const TextStyle(
                          fontFamily: "ndot",
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.add_circle_outline, color: textColor, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
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

  Widget _buildNotificationRequestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cta.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cta.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: cta, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Keep the Streak Alive!",
                style: TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cta,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showNotifPrompt = false),
                child: Icon(Icons.close, color: cta.withValues(alpha: 0.5), size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Turn on daily reminders to stay consistent and reach your goals.",
            style: TextStyle(
              fontFamily: "TTNormsPro",
              fontSize: 13,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final granted = await NotificationService().requestPermission();
              if (granted == true) {
                final isar = Isar.getInstance()!;
                final settings = await isar.notificationSettings.get(1) ?? NotificationSettings();
                await isar.writeTxn(() async {
                  settings.habitReminders = true;
                  await isar.notificationSettings.put(settings);
                });
                await NotificationService().reevaluateNotifications();
                setState(() => _showNotifPrompt = false);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cta,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Enable Reminders",
                style: TextStyle(
                  fontFamily: "ndot",
                  fontSize: 10,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

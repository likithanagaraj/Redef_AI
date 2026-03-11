import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../constants.dart';
import '../design_tokens.dart';
import '../widgets/dashed_border.dart';
import 'main_screen.dart';
import '../models/habit.dart';

extension HabitLogic on Habit {
  bool isCheckedOn(DateTime date) {
    return completedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
  }

  int calculateStreak(DateTime today) {
    if (completedDates.isEmpty) return 0;
    
    final uniqueDates = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = DateTime(today.year, today.month, today.day);
    
    if (uniqueDates.isNotEmpty && uniqueDates.first.isBefore(checkDate)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
    }

    for (DateTime date in uniqueDates) {
      if (date.year == checkDate.year && date.month == checkDate.month && date.day == checkDate.day) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break; 
      }
    }
    return streak;
  }
}

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  @override
  _HabitsScreenState createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late DateTime today;
  late DateTime selectedDate;
  late List<DateTime> weekDates;

  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    selectedDate = today;
    weekDates = List.generate(7, (i) => today.subtract(Duration(days: 3 - i)));
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final isar = Isar.getInstance()!;
    final loadedHabits = await isar.habits.where().findAll();
    setState(() {
      habits = loadedHabits;
      habits.sort((a, b) => (a.isCheckedOn(selectedDate) ? 1 : 0).compareTo(b.isCheckedOn(selectedDate) ? 1 : 0));
    });
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
                            "Set the reminder",
                            style: TextStyle(
                              fontFamily: "TTNormsPro",
                              fontSize: 18,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Never miss your morning routine!\nSet a reminder to stay on track",
                            style: TextStyle(
                              fontFamily: "TTNormsPro",
                              fontSize: 12,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          GestureDetector(
                            onTap: () {
                              // Taking back to deepwork tab
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const MainScreen()),
                                (route) => false,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: cta,
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                              child: const Text(
                                "Set Now",
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
                     Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SvgPicture.asset(
                          "assets/icons/bell-notification.svg",
                          width: 100,
                          height: 100,
                          colorFilter: const ColorFilter.mode(textColor, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // Habits List
              // Filter habits for the selected date first
              Builder(
                builder: (context) {
                  final selMidnight = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                  final visibleHabits = habits.where((habit) {
                    final startMidnight = DateTime(habit.startedAt.year, habit.startedAt.month, habit.startedAt.day);
                    if (selMidnight.isBefore(startMidnight)) return false;
                    if (habit.endDate != null && selMidnight.isAfter(DateTime(habit.endDate!.year, habit.endDate!.month, habit.endDate!.day))) {
                      return false;
                    }
                    return true;
                  }).toList();

                  if (visibleHabits.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: Spacing.xxl),
                          SvgPicture.asset(
                            "assets/icons/whiteStreak.svg",
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
               await isar.writeTxn(() async => await isar.habits.delete(habit.id));
               _loadHabits();
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
          onTap: isFutureDate ? null : () async {

            
            final isar = Isar.getInstance()!;
            final midnight = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
            final activeDates = habit.completedDates.toList();
            
            if (isChecked) {
              activeDates.removeWhere((d) => d.year == midnight.year && d.month == midnight.month && d.day == midnight.day);
            } else {
              activeDates.add(midnight);
            }
            habit.completedDates = activeDates;
            
            await isar.writeTxn(() async => await isar.habits.put(habit));
            _loadHabits();
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
          isChecked
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
    TextEditingController nameController = TextEditingController(text: habitToEdit?.name ?? "");
    TextEditingController descController = TextEditingController(text: habitToEdit?.description ?? "");
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
                style: TextStyle(
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
                    
                    h.name = nameController.text;
                    h.description = descController.text.isEmpty ? null : descController.text;
                    if (habitToEdit == null) {
                       h.completedDates = [];
                    }
                    
                    await isar.writeTxn(() async => await isar.habits.put(h));
                    _loadHabits();
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
}

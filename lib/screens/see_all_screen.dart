import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redef_ai_main/constants.dart';
import '../design_tokens.dart';
import '../widgets/dashed_border.dart';
import 'package:isar/isar.dart';
import '../models/project.dart';
import '../models/session.dart';
import 'package:intl/intl.dart';

class SeeAllScreen extends StatefulWidget {
  const SeeAllScreen({Key? key}) : super(key: key);

  @override
  _SeeAllScreenState createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  List<DeepworkSession> _sessions = [];
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isar = Isar.getInstance()!;
    final sessions = await isar.deepworkSessions.where().sortByStartTimeDesc().findAll();
    final projects = await isar.projects.where().findAll();
    setState(() {
      _sessions = sessions;
      _projects = projects;
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "Today";
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return "Yesterday";
    }
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Focus History",
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      "assets/icons/close.svg",
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(textColor, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),
            
            // List
            Expanded(
              child: _sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/solid-clock.svg",
                            width: 64,
                            height: 64,
                            colorFilter: ColorFilter.mode(textColor.withValues(alpha: 0.3), BlendMode.srcIn),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No sessions recorded yet.",
                            style: TextStyle(
                              fontFamily: "TTNormsPro",
                              fontSize: 16,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        final isFirstOfGroup = index == 0 || _formatDate(_sessions[index - 1].startTime) != _formatDate(session.startTime);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isFirstOfGroup) ...[
                              if (index > 0) const SizedBox(height: 24),
                              Text(
                                _formatDate(session.startTime),
                                style: const TextStyle(
                                  fontFamily: "ndot",
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildDismissibleCard(
                              session.project.value?.name ?? "work @ ${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}",
                              (session.durationInMinutes == 0 && session.durationInSeconds > 0) 
                                  ? "${session.durationInSeconds} sec" 
                                  : "${session.durationInMinutes} min",
                              session,
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
        child: GestureDetector(
          onTap: () => _showAddSessionBottomSheet(context),
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cta,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Add Deepwork task",
                  style: TextStyle(
                    fontFamily: "ndot", // in the image it looks like ndot
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
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
      ),
    );
  }

  Widget _buildDismissibleCard(String title, String duration, DeepworkSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(session.id.toString()),
        background: _buildEditBackground(),
        secondaryBackground: _buildDeleteBackground(),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            bool? delete = await _showDeleteDialog(context);
            if (delete == true) {
               final isar = Isar.getInstance()!;
               await isar.writeTxn(() async => await isar.deepworkSessions.delete(session.id));
               _loadData();
            }
            return delete;
          }
          if (direction == DismissDirection.startToEnd) {
            _showAddSessionBottomSheet(context, sessionToEdit: session);
            return false;
          }
          return false;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: "ndot",
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cta,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  duration,
                  style: const TextStyle(
                    fontFamily: "TTNormsPro",
                    fontSize: 10,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditBackground() {
    return Container(
      decoration: BoxDecoration(
        color: textColor,
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(width: 6),
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
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(width: 6),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delete Session?",
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
                          borderRadius: BorderRadius.circular(16),
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

  void _showAddSessionBottomSheet(BuildContext context, {DeepworkSession? sessionToEdit}) {
    Project? selectedProject = sessionToEdit?.project.value;
    TextEditingController durationController = TextEditingController(text: sessionToEdit != null ? sessionToEdit.durationInMinutes.toString() : "");
    bool isCreatingNewProject = false;
    TextEditingController projectController = TextEditingController();
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
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sessionToEdit != null ? "Edit focused session" : "Add a missed focused session",
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: scaffoldBg,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Pick the project",
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 14,
                      color: scaffoldBg,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_projects.isEmpty)
                    const SizedBox.shrink()
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._projects.map((p) => _buildProjectBadge(p, selectedProject, (v) => setModalState(() => selectedProject = v))),
                      ],
                    ),
                  if (_projects.isNotEmpty) const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      isCreatingNewProject
                        ? Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: scaffoldBg.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: projectController,
                                autofocus: true,
                                style: const TextStyle(
                                  fontFamily: "TTNormsPro",
                                  color: scaffoldBg,
                                ),
                                cursorColor: cta,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Project name",
                                  hintStyle: TextStyle(
                                    fontFamily: "TTNormsPro",
                                    color: scaffoldBg.withValues(alpha:  0.3),
                                  ),
                                ),
                                onSubmitted: (val) async {
                                  if (val.isNotEmpty) {
                                    final isar = Isar.getInstance()!;
                                    final newProj = Project()..name = val;
                                    await isar.writeTxn(() async {
                                      await isar.projects.put(newProj);
                                    });
                                    setModalState(() {
                                      _projects.add(newProj);
                                      selectedProject = newProj;
                                      isCreatingNewProject = false;
                                    });
                                  } else {
                                    setModalState(() => isCreatingNewProject = false);
                                  }
                                },
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              setModalState(() => isCreatingNewProject = true);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: cta),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _projects.isEmpty ? "No project. Create one" : "Create new",
                                    style: const TextStyle(
                                      fontFamily: "TTNormsPro",
                                      fontSize: 12,
                                      color: cta,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.add, color: cta, size: 16),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Timings",
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 14,
                      color: scaffoldBg,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: durationController,
                    builder: (context, value, child) {
                      String text = value.text.trim();
                      int colons = text.replaceAll(RegExp(r'[^:]'), '').length;
                      String unit = "sec";
                      if (colons == 1) unit = "min";
                      if (colons >= 2) unit = "hrs";

                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: scaffoldBg.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: durationController,
                                style: const TextStyle(
                                  fontFamily: "ndot",
                                  color: scaffoldBg,
                                ),
                                cursorColor: cta,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "e.g 30:00",
                                  hintStyle: TextStyle(
                                    fontFamily: "ndot",
                                    color: scaffoldBg.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            ),
                            if (text.isNotEmpty)
                              Text(
                                unit,
                                style: const TextStyle(
                                  fontFamily: "TTNormsPro",
                                  fontSize: 12,
                                  color: cta,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () async {
                      if (durationController.text.isNotEmpty) {
                        String timeInput = durationController.text.trim();
                        List<String> parts = timeInput.split(":");
                        int totalSeconds = 0;
                        if (parts.length == 1) {
                          totalSeconds = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                        } else if (parts.length == 2) {
                          int m = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                          int s = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                          totalSeconds = m * 60 + s;
                        } else if (parts.length >= 3) {
                          int h = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                          int m = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                          int s = int.tryParse(parts[2].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                          totalSeconds = h * 3600 + m * 60 + s;
                        }

                        if (totalSeconds > 0) {
                          final isar = Isar.getInstance()!;
                          final session = sessionToEdit ?? DeepworkSession()
                            ..startTime = DateTime.now().subtract(Duration(seconds: totalSeconds))
                            ..endTime = DateTime.now()
                            ..isManualEntry = true;
                          
                          session.durationInMinutes = totalSeconds ~/ 60;
                          session.durationInSeconds = totalSeconds % 60;
                          session.project.value = selectedProject;
                          
                          await isar.writeTxn(() async {
                            await isar.deepworkSessions.put(session);
                            await session.project.save();
                          });
                          _loadData();
                        }
                      }
                      if (mounted) Navigator.pop(context);
                    },
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cta,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sessionToEdit != null ? "Save Session" : "Add New Session",
                            style: TextStyle(
                              fontFamily: "ndot",
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProjectBadge(Project project, Project? selected, Function(Project) onTap) {
    bool isSelected = project.id == selected?.id;
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? scaffoldBg : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        project.name,
        style: TextStyle(
          fontFamily: "TTNormsPro",
          fontSize: 10,
          color: isSelected ? textColor : scaffoldBg,
        ),
      ),
    );

    return GestureDetector(
      onTap: () => onTap(project),
      child: isSelected
          ? child
          : DashedBorder(
              color: scaffoldBg.withValues(alpha: 0.3),
              radius: 20,
              strokeWidth: 1,
              child: child,
            ),
    );
  }
}

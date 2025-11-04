import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redef_ai_main/Theme.dart';
import 'package:redef_ai_main/providers/deepwork_timer.dart';
import 'package:redef_ai_main/core/supabase_config.dart';

class ProjectSelectorSheet extends StatefulWidget {
  const ProjectSelectorSheet({super.key});

  @override
  State<ProjectSelectorSheet> createState() => _ProjectSelectorSheetState();
}

class _ProjectSelectorSheetState extends State<ProjectSelectorSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _recentProjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentProjects();
    // Auto-focus on text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentProjects() async {
    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get distinct project names from past sessions
      final response = await SupabaseConfig.client
          .from('pomodoros')
          .select('project')
          .eq('user_id', userId)
          .not('project', 'is', null)
          .order('created_at', ascending: false)
          .limit(20);

      // Extract unique project names
      final Set<String> uniqueProjects = {};
      for (var row in response) {
        final project = row['project'] as String?;
        if (project != null && project.isNotEmpty) {
          uniqueProjects.add(project);
        }
      }

      setState(() {
        _recentProjects = uniqueProjects.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading projects: $e');
      setState(() => _isLoading = false);
    }
  }

  void _selectProject(String projectName) {
    final timer = context.read<DeepworkTimer>();
    timer.selectProject(projectName);
    Navigator.pop(context);
  }

  void _createNewProject() {
    if (_controller.text.trim().isEmpty) return;
    _selectProject(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<DeepworkTimer>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'What are you focusing on?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontFamily: 'SourceSerif4',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'e.g., Redesigning the screen',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.arrow_forward,
                              color: AppColors.primary,
                            ),
                            onPressed: _createNewProject,
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _createNewProject(),
                ),
              ),

              const SizedBox(height: 24),

              // Recent projects section
              if (_recentProjects.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Projects',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Project chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recentProjects.map((project) {
                      final isSelected = timer.selectedProjectName == project;
                      return GestureDetector(
                        onTap: () => _selectProject(project),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              Flexible(
                                child: Text(
                                  project,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Loading indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),

              // No projects message
              if (!_isLoading && _recentProjects.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Start typing to create your first project',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

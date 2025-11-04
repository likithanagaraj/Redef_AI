import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:redef_ai_main/Theme.dart';
import 'package:redef_ai_main/providers/deepwork_timer.dart';
import 'package:redef_ai_main/widgets/project_bottomSheet.dart';


class AddProject extends StatelessWidget {
  const AddProject({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<DeepworkTimer>();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const ProjectSelectorSheet(),
        );
      },
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 240, // Limit width to prevent overflow
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show icon if project is selected
            if (timer.selectedProjectName != 'I am Focusing on')
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.work_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            Flexible(
              child: Text(
                timer.selectedProjectName,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'SourceSerif4',
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.2,
                  color: timer.selectedProjectName != 'I am Focusing on'
                      ? AppColors.primary
                      : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 24,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
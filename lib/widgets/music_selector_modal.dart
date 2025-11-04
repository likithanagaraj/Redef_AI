import 'package:flutter/material.dart';
import 'package:redef_ai_main/utilis.dart';

class MusicSelectorModal extends StatefulWidget {
  final String selectedMusic;
  final Function(String) onSelect;

  const MusicSelectorModal({
    super.key,
    required this.selectedMusic,
    required this.onSelect,
  });

  @override
  State<MusicSelectorModal> createState() => _MusicSelectorModalState();
}

class _MusicSelectorModalState extends State<MusicSelectorModal> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedMusic;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Music',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...availableMusics.map((music) {
            return RadioListTile<String>(
              title: Text(music.name),
              value: music.name,
              groupValue: _selected,
              onChanged: (value) {
                setState(() => _selected = value!);
                widget.onSelect(value!);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}

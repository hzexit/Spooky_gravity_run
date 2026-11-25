import 'package:flutter/material.dart';
import '../game/audio_manager.dart';

class MenuButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const MenuButton({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hover;
    final arrowColor = active ? Colors.white : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AudioManager.instance.play(AudioManager.click);
          widget.onTap();
        },
        child: SizedBox(
          width: 320,
          height: 52,
          child: Row(
            children: [
              Icon(Icons.chevron_right, color: arrowColor, size: 32),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              Icon(Icons.chevron_left, color: arrowColor, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
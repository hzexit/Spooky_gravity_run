import 'package:flutter/material.dart';
import 'pixel_ui.dart';

/// เก็บไว้เผื่อมีที่อื่นเรียกใช้ ตอนนี้เป็นปุ่มพิกเซลแล้ว
class MenuButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: PixelButton(
        label: label,
        onTap: onTap,
        tone: selected ? PxTone.red : PxTone.grey,
        big: selected,
        arrows: selected,
      ),
    );
  }
}
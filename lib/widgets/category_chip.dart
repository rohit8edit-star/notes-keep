import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int colorIndex;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.colorIndex = 0,
  });

  static const _colors = [
    AppTheme.primaryBlue,
    Color(0xFF26C6DA),
    Color(0xFF66BB6A),
    Color(0xFFFFCA28),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFFFF7043),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colors[colorIndex % _colors.length];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                    ? Colors.white.withOpacity(0.12)
                    : const Color(0xFFBBDEFB)),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xFF1565C0)),
          ),
        ),
      ),
    );
  }
}

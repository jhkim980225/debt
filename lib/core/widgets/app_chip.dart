import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_tokens.dart';

/// 선택 가능한 칩
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: isSelected
              ? Border.all(color: AppColors.textPrimary, width: 2)
              : null,
        ),
        child: Text(
          label,
          style: isSelected
              ? AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)
              : AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
        ),
      ),
    );
  }
}

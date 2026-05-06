import 'package:flutter/material.dart';
import '../theme/app_colors.dart';


/// 진행률 바
class AppProgressBar extends StatelessWidget {
  final double progress; // 0.0 ~ 1.0
  final Color? color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? AppColors.success,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

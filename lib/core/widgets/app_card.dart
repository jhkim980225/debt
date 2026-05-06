import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 기본 카드
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

/// 정보 카드 (색상 톤 지원)
class InfoCard extends StatelessWidget {
  final Widget child;
  final InfoCardTone tone;
  final EdgeInsets? padding;

  const InfoCard({
    super.key,
    required this.child,
    this.tone = InfoCardTone.info,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tone.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: child,
    );
  }
}

enum InfoCardTone {
  success,
  info,
  warning,
  purple,
  neutral;

  Color get backgroundColor {
    switch (this) {
      case InfoCardTone.success:
        return AppColors.successLight;
      case InfoCardTone.info:
        return AppColors.infoLight;
      case InfoCardTone.warning:
        return AppColors.accentLight;
      case InfoCardTone.purple:
        return AppColors.purpleLight;
      case InfoCardTone.neutral:
        return AppColors.surfaceSecondary;
    }
  }

  Color get textColor {
    switch (this) {
      case InfoCardTone.success:
        return AppColors.success;
      case InfoCardTone.info:
        return AppColors.infoDark;
      case InfoCardTone.warning:
        return AppColors.accentDark;
      case InfoCardTone.purple:
        return AppColors.purpleDark;
      case InfoCardTone.neutral:
        return AppColors.textSecondary;
    }
  }
}

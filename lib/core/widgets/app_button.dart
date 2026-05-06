import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_tokens.dart';

/// 메인 액션 버튼 (검정 배경)
class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.textOnDark,
          disabledBackgroundColor: AppColors.textPrimary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnDark,
                ),
              )
            : Text(text, style: AppTypography.buttonLarge.copyWith(
                color: AppColors.textOnDark,
              )),
      ),
    );
  }
}

/// 보조 버튼 (보더만)
class AppSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AppSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(text, style: AppTypography.buttonLarge),
      ),
    );
  }
}

/// 소셜 로그인 버튼
class SocialLoginButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? icon;
  final VoidCallback? onPressed;
  final bool hasBorder;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.foregroundColor = Colors.black,
    this.icon,
    this.onPressed,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: hasBorder
                ? const BorderSide(color: AppColors.borderMedium)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              text,
              style: AppTypography.buttonLarge.copyWith(color: foregroundColor),
            ),
          ],
        ),
      ),
    );
  }
}

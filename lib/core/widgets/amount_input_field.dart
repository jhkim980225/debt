import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_tokens.dart';
import '../utils/formatters.dart';

/// 금액 입력 필드 (천단위 콤마 자동, 우측 "원" 표시)
class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool large;
  final ValueChanged<int?>? onChanged;

  const AmountInputField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.large = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(label!, style: AppTypography.labelLarge),
          ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _AmountFormatter(),
            LengthLimitingTextInputFormatter(16), // 999,999,999,999
          ],
          textAlign: TextAlign.right,
          style: large
              ? AppTypography.displayAmountMedium
              : AppTypography.headingMedium,
          decoration: InputDecoration(
            hintText: hint ?? '0',
            suffixText: '원',
            suffixStyle: large
                ? AppTypography.headingMedium.copyWith(
                    color: AppColors.textSecondary,
                  )
                : AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
            errorText: errorText,
          ),
          onChanged: (value) {
            onChanged?.call(AppFormatters.parseAmount(value));
          },
        ),
      ],
    );
  }
}

class _AmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final formatted = AppFormatters.formatInput(text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

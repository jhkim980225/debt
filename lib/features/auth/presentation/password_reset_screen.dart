import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

/// 비밀번호 찾기 화면 (3단계)
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  int _currentStep = 1; // 1, 2, 3
  final _emailController = TextEditingController();
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            children: [
              // 진행률 바
              LinearProgressIndicator(
                value: _currentStep / 3,
                backgroundColor: AppColors.surfaceSecondary,
                valueColor: AlwaysStoppedAnimation(
                  _currentStep == 3 ? AppColors.success : AppColors.textPrimary,
                ),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xxxl),
                      if (_currentStep == 1) _buildStep1(),
                      if (_currentStep == 2) _buildStep2(),
                      if (_currentStep == 3) _buildStep3(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.passwordResetTitle, style: AppTypography.displayLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.passwordResetSubtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: '이메일',
            hintText: 'example@email.com',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        InfoCard(
          tone: InfoCardTone.info,
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.infoDark),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.socialLoginGuide,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.infoDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        AppPrimaryButton(
          text: AppStrings.getVerificationCode,
          onPressed: () {
            if (_emailController.text.isNotEmpty) {
              setState(() => _currentStep = 2);
            }
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.verificationCodeTitle, style: AppTypography.displayLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${_emailController.text}으로 6자리 코드를 보냈어요.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // 6자리 코드 입력
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 48,
              height: 56,
              child: TextField(
                controller: _codeControllers[i],
                focusNode: _codeFocusNodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: AppTypography.headingLarge,
                decoration: const InputDecoration(
                  counterText: '',
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && i < 5) {
                    _codeFocusNodes[i + 1].requestFocus();
                  }
                  if (value.isEmpty && i > 0) {
                    _codeFocusNodes[i - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),

        const SizedBox(height: AppSpacing.xxl),
        AppPrimaryButton(
          text: '확인',
          onPressed: () {
            // Phase 1: 코드 검증 생략, 바로 다음 단계
            setState(() => _currentStep = 3);
          },
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.newPasswordTitle, style: AppTypography.displayLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.newPasswordSubtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        TextField(
          controller: _newPasswordController,
          obscureText: _obscureNew,
          decoration: InputDecoration(
            labelText: '새 비밀번호',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNew ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textTertiary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: AppSpacing.lg),

        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            labelText: '비밀번호 확인',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textTertiary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        AppPrimaryButton(
          text: AppStrings.changePassword,
          onPressed: () {
            // Phase 1: 로컬에서는 비밀번호 변경 불가, 성공 토스트 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.passwordChanged),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/auth/login');
          },
        ),
      ],
    );
  }
}

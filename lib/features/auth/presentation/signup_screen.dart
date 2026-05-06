import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';

/// 회원가입 화면
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),

              // 헤드라인
              Text(AppStrings.signupTitle, style: AppTypography.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.signupSubtitle,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // 소셜 로그인 버튼 4개
              SocialLoginButton(
                text: AppStrings.kakaoLogin,
                backgroundColor: AppColors.kakao,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.chat_bubble, size: 18, color: Colors.black),
                onPressed: () => _handleSocialLogin(context, 'kakao'),
              ),
              const SizedBox(height: AppSpacing.sm),

              SocialLoginButton(
                text: AppStrings.googleLogin,
                backgroundColor: AppColors.google,
                foregroundColor: Colors.black,
                hasBorder: true,
                icon: const Icon(Icons.g_mobiledata, size: 22, color: Colors.black),
                onPressed: () => _handleSocialLogin(context, 'google'),
              ),
              const SizedBox(height: AppSpacing.sm),

              SocialLoginButton(
                text: AppStrings.appleLogin,
                backgroundColor: AppColors.apple,
                foregroundColor: AppColors.textOnDark,
                icon: const Icon(Icons.apple, size: 20, color: AppColors.textOnDark),
                onPressed: () => _handleSocialLogin(context, 'apple'),
              ),
              const SizedBox(height: AppSpacing.sm),

              SocialLoginButton(
                text: AppStrings.naverLogin,
                backgroundColor: AppColors.naver,
                foregroundColor: AppColors.textOnDark,
                icon: const Text('N', style: TextStyle(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
                onPressed: () => _handleSocialLogin(context, 'naver'),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 구분선
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Text(
                      AppStrings.or,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 이메일 회원가입
              AppSecondaryButton(
                text: AppStrings.emailSignup,
                onPressed: () => context.push('/auth/email-signup'),
              ),

              const Spacer(),

              // 약관 동의 안내
              Center(
                child: Text(
                  '가입하면 이용약관 및 개인정보 처리방침에\n동의하는 것으로 간주합니다.',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelTiny.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 로그인 링크
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${AppStrings.alreadyHaveAccount} ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/auth/login'),
                      child: Text(
                        AppStrings.login,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSocialLogin(BuildContext context, String provider) {
    // Phase 1: 소셜 로그인은 UI만, 실제 연동은 Supabase 연동 시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider 로그인은 서버 연동 후 사용할 수 있어요'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

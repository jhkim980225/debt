import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/providers.dart';

/// 로그인 화면
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _autoLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),

              // 헤드라인
              Text(AppStrings.loginTitle, style: AppTypography.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.loginSubtitle,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // 이메일 입력
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: 'example@email.com',
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 비밀번호 입력
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    onPressed: () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
                  ),
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),

              const SizedBox(height: AppSpacing.md),

              // 자동 로그인 + 비밀번호 찾기
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Checkbox(
                          value: _autoLogin,
                          onChanged: (v) => setState(() => _autoLogin = v ?? true),
                          activeColor: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        AppStrings.autoLogin,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/auth/reset-password'),
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              // 에러 메시지
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorMessage!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // 로그인 버튼
              AppPrimaryButton(
                text: AppStrings.login,
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 구분선
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Text(
                      AppStrings.simpleLogin,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 소셜 로그인 아이콘
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(AppColors.kakao, Icons.chat_bubble, Colors.black),
                  const SizedBox(width: AppSpacing.lg),
                  _socialIcon(AppColors.google, Icons.g_mobiledata, Colors.black, hasBorder: true),
                  const SizedBox(width: AppSpacing.lg),
                  _socialIcon(AppColors.apple, Icons.apple, AppColors.textOnDark),
                  const SizedBox(width: AppSpacing.lg),
                  _socialIcon(AppColors.naver, Icons.north, AppColors.textOnDark),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // 회원가입 링크
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${AppStrings.noAccountYet} ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/auth/signup'),
                      child: Text(
                        AppStrings.signup,
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

  Widget _socialIcon(Color bg, IconData icon, Color fg, {bool hasBorder = false}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: hasBorder ? Border.all(color: AppColors.borderMedium) : null,
      ),
      child: Icon(icon, color: fg, size: 20),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = AppStrings.errorEmailOrPassword);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.loginWithEmail(
        email: email,
        password: password,
      );
      ref.read(currentUserProvider.notifier).setUser(user);

      if (mounted) {
        // 빚 목록 로드
        await ref.read(debtListProvider.notifier).loadDebts(user.id);
        final debts = ref.read(debtListProvider);
        if (debts.isEmpty) {
          context.go('/debt/add');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

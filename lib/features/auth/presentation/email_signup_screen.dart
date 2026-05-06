import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/providers.dart';

/// 이메일 회원가입 화면
class EmailSignupScreen extends ConsumerStatefulWidget {
  const EmailSignupScreen({super.key});

  @override
  ConsumerState<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends ConsumerState<EmailSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  // 닉네임 후보
  late List<String> _nicknameOptions;
  int _selectedNickname = 0;

  static const _adjectives = [
    '햇살모은', '조용한', '바람부는', '새벽의', '천천히가는',
    '노을지는', '작은별빛', '따뜻한봄', '푸른', '차분한',
  ];
  static const _nouns = [
    '걸음', '언덕', '산책로', '하늘', '여행자',
    '두시', '봄날', '바다', '숲길', '달빛',
  ];

  @override
  void initState() {
    super.initState();
    _generateNicknames();
  }

  void _generateNicknames() {
    final random = Random();
    _nicknameOptions = List.generate(5, (_) {
      final adj = _adjectives[random.nextInt(_adjectives.length)];
      final noun = _nouns[random.nextInt(_nouns.length)];
      return '$adj$noun';
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // 비밀번호 검증
  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasLetter =>
      _passwordController.text.contains(RegExp(r'[a-zA-Z]'));
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool get _passwordsMatch =>
      _passwordController.text == _confirmController.text &&
      _confirmController.text.isNotEmpty;
  bool get _isPasswordValid =>
      _hasMinLength && _hasLetter && _hasNumber && _hasSpecial;

  int get _passwordStrength {
    int strength = 0;
    if (_hasMinLength) strength++;
    if (_hasLetter && _hasNumber) strength++;
    if (_hasSpecial) strength++;
    if (_passwordController.text.length >= 12) strength++;
    return strength;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.emailSignup),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // 이메일
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

              // 비밀번호
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
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: AppSpacing.sm),

              // 비밀번호 강도 바
              if (_passwordController.text.isNotEmpty) ...[
                Row(
                  children: List.generate(4, (i) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: i < 3 ? AppSpacing.xs : 0,
                        ),
                        decoration: BoxDecoration(
                          color: i < _passwordStrength
                              ? _strengthColor
                              : AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.sm),

                // 요구사항 체크리스트
                _requirement('8자 이상', _hasMinLength),
                _requirement('영문 포함', _hasLetter),
                _requirement('숫자 포함', _hasNumber),
                _requirement('특수문자 포함', _hasSpecial),
              ],

              const SizedBox(height: AppSpacing.lg),

              // 비밀번호 확인
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_passwordsMatch)
                        const Icon(Icons.check, color: AppColors.success, size: 20),
                      IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ],
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 닉네임 선택
              Text('닉네임', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: List.generate(_nicknameOptions.length, (i) {
                  final isSelected = i == _selectedNickname;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedNickname = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.surface
                            : AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: isSelected
                            ? Border.all(color: AppColors.textPrimary, width: 2)
                            : null,
                      ),
                      child: Text(
                        _nicknameOptions[i],
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () => setState(() => _generateNicknames()),
                child: Text(
                  '다른 추천',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              // 에러 메시지
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _errorMessage!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxxl),

              // 가입 버튼
              AppPrimaryButton(
                text: AppStrings.signup,
                isLoading: _isLoading,
                onPressed:
                    _isPasswordValid && _passwordsMatch ? _handleSignup : null,
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 1:
        return AppColors.danger;
      case 2:
        return AppColors.accent;
      case 3:
        return AppColors.success;
      case 4:
        return AppColors.success;
      default:
        return AppColors.surfaceSecondary;
    }
  }

  Widget _requirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: met ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTypography.labelTiny.copyWith(
              color: met ? AppColors.success : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nicknameOptions[_selectedNickname],
      );
      ref.read(currentUserProvider.notifier).setUser(user);

      if (mounted) {
        // 빚 등록 화면으로 강제 이동
        context.go('/debt/add');
      }
    } catch (e) {
      setState(
          () => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

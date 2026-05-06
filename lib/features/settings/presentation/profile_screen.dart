import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/providers.dart';

/// 프로필 화면
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nicknameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nicknameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('프로필'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // 아바타
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.successLight,
                  ),
                  child: Center(
                    child: Text(
                      (user?.displayName ?? '?').substring(0, 1),
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // 닉네임
              Text('닉네임', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nicknameController,
                      enabled: _isEditing,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (!_isEditing)
                    AppSecondaryButton(
                      text: '변경',
                      onPressed: () => setState(() => _isEditing = true),
                    )
                  else
                    AppPrimaryButton(
                      text: '저장',
                      onPressed: _saveNickname,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '30일에 1회 변경 가능',
                style: AppTypography.labelTiny,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 이메일
              Text('이메일', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Text(
                  user?.email ?? '',
                  style: AppTypography.bodyMedium,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 가입일
              Text('가입일', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Text(
                  user != null
                      ? AppFormatters.fullDate(user.createdAt)
                      : '-',
                  style: AppTypography.bodyMedium,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 가입 방식
              Text('가입 방식', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Text(
                  _authProviderLabel(user?.authProvider),
                  style: AppTypography.bodyMedium,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  void _saveNickname() {
    final name = _nicknameController.text.trim();
    if (name.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user != null) {
      user.displayName = name;
      ref.read(currentUserProvider.notifier).setUser(user);
    }

    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('닉네임이 변경됐어요'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _authProviderLabel(String? provider) {
    switch (provider) {
      case 'kakao':
        return '카카오로 가입';
      case 'google':
        return 'Google로 가입';
      case 'apple':
        return 'Apple로 가입';
      case 'naver':
        return '네이버로 가입';
      case 'email':
        return '이메일로 가입';
      default:
        return '이메일로 가입';
    }
  }
}

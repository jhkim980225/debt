import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/providers.dart';

/// 설정 메인 화면
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text('설정', style: AppTypography.headingLarge),
              const SizedBox(height: AppSpacing.xxl),

              // 프로필 섹션
              AppCard(
                onTap: () => context.push('/settings/profile'),
                child: Row(
                  children: [
                    // 아바타
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.successLight,
                      ),
                      child: Center(
                        child: Text(
                          (user?.displayName ?? '?').substring(0, 1),
                          style: AppTypography.headingMedium.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? '사용자',
                            style: AppTypography.headingSmall,
                          ),
                          Text(
                            _maskEmail(user?.email ?? ''),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textTertiary),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 빚 관리
              _sectionTitle('빚 관리'),
              const SizedBox(height: AppSpacing.sm),
              _settingsItem(
                icon: Icons.swap_vert,
                title: '상환 전략',
                subtitle: user?.strategy == 'avalanche'
                    ? '눈사태 방식'
                    : '눈덩이 방식',
                onTap: () => context.push('/simulation'),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 알림
              _sectionTitle('알림'),
              const SizedBox(height: AppSpacing.sm),
              _settingsItem(
                icon: Icons.notifications_outlined,
                title: '알림 설정',
                subtitle: '결제일, 동기부여, 연속 기록',
                onTap: () => _showNotificationSettings(context),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 정보
              _sectionTitle('정보'),
              const SizedBox(height: AppSpacing.sm),
              _settingsItem(
                icon: Icons.info_outline,
                title: '버전',
                subtitle: '1.0.0',
                onTap: null,
              ),
              _settingsItem(
                icon: Icons.description_outlined,
                title: '이용약관',
                onTap: () {},
              ),
              _settingsItem(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보처리방침',
                onTap: () {},
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 계정
              _sectionTitle('계정'),
              const SizedBox(height: AppSpacing.sm),
              _settingsItem(
                icon: Icons.logout,
                title: '로그아웃',
                onTap: () => _showLogoutDialog(context, ref),
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () => _showDeleteAccountDialog(context, ref),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    '회원 탈퇴',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelLarge.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.lg),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTypography.labelTiny,
                    ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    if (name.length <= 3) return '***@${parts[1]}';
    return '${name.substring(0, 3)}***@${parts[1]}';
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('알림 설정', style: AppTypography.headingMedium),
            const SizedBox(height: AppSpacing.xxl),
            _NotificationToggle(
                title: '결제일 알림', subtitle: '결제일 3일 전 알림'),
            _NotificationToggle(
                title: '동기부여 알림', subtitle: '매일 아침 응원 메시지'),
            _NotificationToggle(
                title: '연속 기록 위험', subtitle: '밤 9시, 오늘 기록 없을 때'),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃하시겠어요?'),
        content: const Text('로컬 데이터는 보존돼요. 다시 로그인하면 복구됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(currentUserProvider.notifier).logout();
              if (context.mounted) {
                context.go('/auth/signup');
              }
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('정말 떠나시려고요?'),
        content: const Text(
          '지금까지의 상환 기록, 연속 기록, 배지가 모두 사라져요.\n30일 안에 다시 로그인하면 복구할 수 있어요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('계속 쓸게요'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(currentUserProvider.notifier).logout();
              if (context.mounted) {
                context.go('/auth/signup');
              }
            },
            child: Text(
              '회원 탈퇴',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

/// 알림 토글 위젯
class _NotificationToggle extends StatefulWidget {
  final String title;
  final String subtitle;

  const _NotificationToggle({required this.title, required this.subtitle});

  @override
  State<_NotificationToggle> createState() => _NotificationToggleState();
}

class _NotificationToggleState extends State<_NotificationToggle> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTypography.bodyMedium),
                Text(widget.subtitle, style: AppTypography.labelTiny),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            activeTrackColor: AppColors.successLight,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.success;
              }
              return null;
            }),
            onChanged: (v) => setState(() => _enabled = v),
          ),
        ],
      ),
    );
  }
}

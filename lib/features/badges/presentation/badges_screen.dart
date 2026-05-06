import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/providers.dart';
import '../domain/badge_model.dart';

/// 동기부여 메시지 풀
const List<String> _dailyQuotes = [
  '빚을 갚는 건 미래의 나에게 보내는 선물이에요.',
  '한 걸음 한 걸음, 자유에 가까워지고 있어요.',
  '오늘의 절약이 내일의 자유를 만들어요.',
  '꾸준함이 답이에요.',
  '어제보다 가까워지고 있어요.',
  '작은 진전도 진전이에요.',
  '포기하지 않는 한, 이미 이기고 있어요.',
  '오늘도 한 걸음씩, 천천히 가요.',
  '완벽하지 않아도 괜찮아요. 계속하는 게 중요해요.',
  '당신의 꾸준함이 결국 답을 만들어요.',
  '지금 이 순간이 내일의 나를 만들어요.',
  '조금씩이라도 움직이면 분명히 도착해요.',
  '빚은 줄어들고, 자유는 가까워지고 있어요.',
  '오늘의 한 걸음이 내일의 큰 변화가 돼요.',
  '포기하지 않는 당신이 대단해요.',
  '천리길도 한 걸음부터, 이미 시작했잖아요.',
  '지금의 노력이 미래의 여유를 만들어요.',
  '꾸준히 걷다 보면 어느새 도착해 있을 거예요.',
  '작은 금액이라도 갚는 건 큰 용기예요.',
  '과거의 나와 비교하세요. 분명히 더 좋아졌어요.',
  '아직 멀어 보여도, 이미 많이 왔어요.',
  '매일 한 걸음이면, 일 년이면 365걸음이에요.',
  '빚 갚기는 마라톤이에요. 천천히, 하지만 멈추지 않고.',
  '오늘 하루도 스스로를 응원해주세요.',
  '자유를 향한 여정은 이미 시작됐어요.',
  '우리는 함께 가고 있어요.',
  '어둠이 짙을수록 새벽이 가까운 법이에요.',
  '매 순간의 선택이 미래를 바꿔요.',
  '지금의 인내가 내일의 기쁨이 돼요.',
  '한 번에 하나씩, 그게 비결이에요.',
];

/// 배지 아이콘 매핑
IconData _badgeIcon(String id) {
  switch (id) {
    case 'firstStep':
      return Icons.directions_walk;
    case 'sevenDayStreak':
      return Icons.local_fire_department;
    case 'thirtyDayStreak':
      return Icons.whatshot;
    case 'hundredDayStreak':
      return Icons.military_tech;
    case 'tenPercentClear':
      return Icons.trending_up;
    case 'quarterClear':
      return Icons.pie_chart;
    case 'halfClear':
      return Icons.star_half;
    case 'million':
      return Icons.savings;
    case 'fiveMillion':
      return Icons.account_balance_wallet;
    case 'tenMillion':
      return Icons.diamond;
    case 'interestSaver':
      return Icons.shield;
    case 'firstGraduation':
      return Icons.school;
    case 'allCleared':
      return Icons.emoji_events;
    case 'comeback':
      return Icons.replay;
    case 'extraEffort':
      return Icons.bolt;
    case 'disciplined':
      return Icons.calendar_month;
    case 'earlyBird':
      return Icons.wb_sunny;
    case 'weekendWarrior':
      return Icons.weekend;
    default:
      return Icons.emoji_events;
  }
}

/// 배지/동기부여 화면
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final earnedBadges = ref.watch(badgeListProvider);
    final payments = ref.watch(paymentListProvider);

    final streak = user?.streakCount ?? 0;
    final longestStreak = user?.longestStreak ?? 0;
    final earnedIds = earnedBadges.map((b) => b.id).toSet();

    // 오늘의 인용구 (날짜 기반 해시)
    final today = DateTime.now();
    final quoteIndex =
        (today.year * 366 + today.month * 31 + today.day) % _dailyQuotes.length;

    // 7일 캘린더 (이번 주 월~일)
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));
    final paidDates = payments
        .map((p) => DateTime(p.paidAt.year, p.paidAt.month, p.paidAt.day))
        .toSet();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // 헤더
              Text('나의 여정', style: AppTypography.headingLarge),

              const SizedBox(height: AppSpacing.xxl),

              // 섹션 1: 연속 기록
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: streak > 0
                        ? AppColors.successLight
                        : AppColors.surfaceSecondary,
                    border: Border.all(
                      color:
                          streak > 0 ? AppColors.success : AppColors.borderLight,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$streak',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: streak > 0
                              ? AppColors.success
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        streak > 0 ? '$streak일 연속 상환 중' : '오늘 시작해볼까요?',
                        style: AppTypography.bodySmall.copyWith(
                          color: streak > 0
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // 최고 기록
              Center(
                child: Text(
                  streak >= longestStreak && streak > 0
                      ? '최고 기록 갱신 중!'
                      : '최고 기록까지 ${longestStreak - streak}일 남았어요',
                  style: AppTypography.labelSmall.copyWith(
                    color: streak >= longestStreak && streak > 0
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 7일 캘린더
              AppCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekDays.map((day) {
                    final isToday = day.year == now.year &&
                        day.month == now.month &&
                        day.day == now.day;
                    final isPaid = paidDates
                        .contains(DateTime(day.year, day.month, day.day));
                    final dayNames = ['월', '화', '수', '목', '금', '토', '일'];
                    final dayName = dayNames[day.weekday - 1];

                    return Column(
                      children: [
                        Text(
                          dayName,
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isToday
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPaid
                                ? AppColors.success
                                : isToday
                                    ? AppColors.surfaceTertiary
                                    : Colors.transparent,
                            border: isToday && !isPaid
                                ? Border.all(
                                    color: AppColors.borderMedium, width: 1.5)
                                : null,
                          ),
                          child: Center(
                            child: isPaid
                                ? const Icon(Icons.check,
                                    size: 14, color: AppColors.textOnDark)
                                : Text(
                                    '${day.day}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isToday
                                          ? AppColors.textPrimary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // 섹션 2: 획득한 배지
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('획득한 배지', style: AppTypography.headingMedium),
                  Text(
                    '${earnedIds.length} / ${BadgeDefinition.all.length}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 배지 그리드 3열
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 0.85,
                ),
                itemCount: BadgeDefinition.all.length,
                itemBuilder: (context, index) {
                  final badge = BadgeDefinition.all[index];
                  final isEarned = earnedIds.contains(badge.id);

                  return GestureDetector(
                    onTap: () => _showBadgeDetail(context, badge, isEarned),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isEarned
                                ? AppColors.successLight
                                : AppColors.surfaceSecondary,
                            border: isEarned
                                ? Border.all(
                                    color: AppColors.success, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: isEarned
                                ? Icon(_badgeIcon(badge.id),
                                    size: 24, color: AppColors.success)
                                : const Icon(Icons.lock_outline,
                                    size: 20, color: AppColors.textTertiary),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          isEarned ? badge.name : '?',
                          style: AppTypography.labelSmall.copyWith(
                            color: isEarned
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                            fontWeight: isEarned
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          isEarned ? badge.description : '잠금 해제 필요',
                          style: AppTypography.labelTiny,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // 섹션 3: 오늘의 한마디
              InfoCard(
                tone: InfoCardTone.purple,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 한마디',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.purpleDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _dailyQuotes[quoteIndex],
                      style: AppTypography.quote.copyWith(
                        color: AppColors.purpleDark,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeDetail(
      BuildContext context, BadgeDefinition badge, bool isEarned) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEarned
                    ? AppColors.successLight
                    : AppColors.surfaceSecondary,
              ),
              child: Center(
                child: isEarned
                    ? Icon(_badgeIcon(badge.id),
                        size: 32, color: AppColors.success)
                    : const Icon(Icons.lock_outline,
                        size: 28, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isEarned ? badge.name : '???',
              style: AppTypography.headingMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              badge.description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

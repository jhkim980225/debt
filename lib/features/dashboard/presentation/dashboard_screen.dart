import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/debt_category.dart';
import '../../../core/constants/motivation_quotes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/debt_calculator.dart';
import '../../../core/providers.dart';
import '../../payment_record/presentation/payment_record_sheet.dart';

/// 대시보드 메인 화면
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(debtListProvider.notifier).loadDebts(user.id);
      ref.read(debtListProvider.notifier).sortByStrategy(user.strategy);
      await ref.read(paymentListProvider.notifier).loadPayments(user.id);
      await ref.read(badgeListProvider.notifier).loadBadges(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final debts = ref.watch(debtListProvider);
    final payments = ref.watch(paymentListProvider);

    // 빚 없으면 빈 상태
    if (debts.isEmpty) {
      return _buildEmptyState();
    }

    // 계산
    final totalBalance = debts.fold(0, (sum, d) => sum + d.currentBalance);
    final progress = DebtCalculator.overallProgress(
      initialAmounts: debts.map((d) => d.initialAmount).toList(),
      currentBalances: debts.map((d) => d.currentBalance).toList(),
    );
    final totalInitial =
        debts.fold(0, (sum, d) => sum + (d.initialAmount ?? 0));
    final totalPaid = totalInitial - totalBalance;

    // 이번 달 상환 금액
    final now = DateTime.now();
    final thisMonthPayments = payments
        .where((p) => p.paidAt.year == now.year && p.paidAt.month == now.month);
    final monthlyPaid = thisMonthPayments.fold(0, (sum, p) => sum + p.amount);

    // 동기부여 카피
    final quote = MotivationQuotes.situationalQuote(
      streakDays: user?.streakCount ?? 0,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            children: [
              const SizedBox(height: AppSpacing.lg),

              // 섹션 1: 인사 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppStrings.hello}, ${user?.displayName ?? ''}님',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        AppFormatters.date(now),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: const Icon(Icons.settings_outlined,
                            size: 20, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(quote, style: AppTypography.headingMedium),

              const SizedBox(height: AppSpacing.xxl),

              // 섹션 2: 총 빚 + 진행률
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.totalDebt,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppFormatters.amountWon(totalBalance),
                      style: AppTypography.displayAmount,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (monthlyPaid > 0)
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward,
                              size: 14, color: AppColors.success),
                          const SizedBox(width: 2),
                          Text(
                            '이번 달 ${AppFormatters.amountWon(monthlyPaid)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '이번 달 첫 상환을 시작해보세요',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // 진행률
                    if (progress != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.overallProgress,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            AppFormatters.progress(progress),
                            style: AppTypography.headingSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppProgressBar(progress: progress),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '시작: ${AppFormatters.amountWon(totalInitial)} · 갚은 금액: ${AppFormatters.amountWon(totalPaid)}',
                        style: AppTypography.labelTiny,
                      ),
                    ] else
                      Text(
                        '갚을수록 진행률이 채워져요',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 섹션 3: 연속 기록 카드
              if (user != null && user.streakCount > 0)
                InfoCard(
                  tone: InfoCardTone.info,
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.infoDark, size: 24),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.streakCount}일 연속 상환 중',
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.infoDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '매일 조금씩 갚고 있어요. 멋져요!',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.infoDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.xxl),

              // 섹션 4: 내 빚 목록
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.myDebts, style: AppTypography.headingSmall),
                  Row(
                    children: [
                      Text(
                        '${debts.length}개',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () => context.push('/debt/add'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: 14,
                                  color: AppColors.textOnDark),
                              const SizedBox(width: 2),
                              Text('추가',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textOnDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 빚 카드 리스트
              ...debts.asMap().entries.map((entry) {
                final index = entry.key;
                final debt = entry.value;
                final category = DebtCategory.values.firstWhere(
                  (c) => c.name == debt.category,
                  orElse: () => DebtCategory.other,
                );
                final debtProgress = DebtCalculator.debtProgress(
                  initialAmount: debt.initialAmount,
                  currentBalance: debt.currentBalance,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    onTap: () => context.push('/debt/${debt.id}'),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(debt.name,
                                  style: AppTypography.bodyLarge
                                      .copyWith(fontWeight: FontWeight.w500)),
                            ),
                            if (index == 0 && debts.length > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentLight,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.xs),
                                ),
                                child: Text(
                                  AppStrings.priority,
                                  style: AppTypography.labelTiny.copyWith(
                                    color: AppColors.accentDark,
                                  ),
                                ),
                              ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              AppFormatters.amountWon(debt.currentBalance),
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (debtProgress != null)
                          AppProgressBar(
                            progress: debtProgress,
                            color: category.color,
                            height: 4,
                          ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '이자율 ${AppFormatters.interestRate(debt.interestRate)}',
                              style: AppTypography.labelTiny,
                            ),
                            if (debtProgress != null)
                              Text(
                                '${AppFormatters.progress(debtProgress)} 완료',
                                style: AppTypography.labelTiny.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: AppSpacing.xxl),

              // 섹션 5: 액션 버튼
              Row(
                children: [
                  Expanded(
                    child: AppPrimaryButton(
                      text: '+ ${AppStrings.recordPayment}',
                      onPressed: () => _showPaymentSheet(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppSecondaryButton(
                      text: AppStrings.simulation,
                      onPressed: () {
                        // Phase 2
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  AppStrings.registerFirstDebt,
                  style: AppTypography.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppStrings.registerFirstDebtSub,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppPrimaryButton(
                  text: '빚 등록하기',
                  width: 200,
                  onPressed: () => context.go('/debt/add'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaymentRecordSheet(),
    );
  }
}

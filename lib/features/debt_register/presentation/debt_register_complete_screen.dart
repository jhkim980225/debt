import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/debt_calculator.dart';
import '../../../core/providers.dart';

/// 빚 등록 완료 축하 화면
class DebtRegisterCompleteScreen extends ConsumerWidget {
  const DebtRegisterCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtListProvider);
    final lastDebt = debts.isNotEmpty ? debts.last : null;

    // 예상 졸업일 계산
    DateTime? graduationDate;
    if (lastDebt != null && lastDebt.targetPayment != null && lastDebt.targetPayment! > 0) {
      graduationDate = DebtCalculator.estimateGraduationDate(
        balance: lastDebt.currentBalance,
        monthlyPayment: lastDebt.targetPayment!,
        annualRate: lastDebt.interestRate,
      );
    }

    final isFirst = debts.length == 1;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // 컨페티 느낌의 간단한 장식
              const _ConfettiDecoration(),

              const SizedBox(height: AppSpacing.xxl),

              // 큰 체크 원
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.success,
                  size: 40,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 헤드라인
              Text(
                isFirst ? AppStrings.firstStepTaken : '등록 완료!',
                style: AppTypography.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (isFirst)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    AppStrings.firstStepMessage,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: AppSpacing.xxl),

              // 첫 빚이면 배지 카드
              if (isFirst) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accent, size: 32),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.newBadgeEarned,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.accentDark,
                            ),
                          ),
                          Text(
                            AppStrings.firstStepBadge,
                            style: AppTypography.headingMedium.copyWith(
                              color: AppColors.accentDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // 등록 정보 요약 카드
              if (lastDebt != null)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppFormatters.amountWon(lastDebt.currentBalance),
                        style: AppTypography.displayAmount,
                      ),
                      if (lastDebt.targetPayment != null &&
                          lastDebt.targetPayment! > 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '매달 ${AppFormatters.amountWon(lastDebt.targetPayment!)}씩 갚으면',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (graduationDate != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${AppFormatters.yearMonth(graduationDate)}에 졸업해요',
                          style: AppTypography.headingMedium.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.xxl),

              // 다음 액션 카드 2개
              AppCard(
                onTap: () => context.go('/debt/add'),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child:
                          const Icon(Icons.add, color: AppColors.info, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.addAnotherDebt,
                              style: AppTypography.bodyLarge
                                  .copyWith(fontWeight: FontWeight.w500)),
                          Text(
                            AppStrings.addAnotherDebtReason,
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

              const SizedBox(height: AppSpacing.sm),

              AppCard(
                onTap: () => context.go('/home'),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.grid_view,
                          color: AppColors.success, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.goToDashboard,
                              style: AppTypography.bodyLarge
                                  .copyWith(fontWeight: FontWeight.w500)),
                          Text(
                            AppStrings.goToDashboardReason,
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

              // 메인 버튼
              AppPrimaryButton(
                text: AppStrings.goToDashboard,
                onPressed: () => context.go('/home'),
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

/// 간단한 컨페티 장식
class _ConfettiDecoration extends StatelessWidget {
  const _ConfettiDecoration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(AppColors.successAccent),
          const SizedBox(width: 8),
          _dot(AppColors.accent),
          const SizedBox(width: 8),
          _dot(AppColors.purple),
          const SizedBox(width: 8),
          _dot(AppColors.pink),
          const SizedBox(width: 8),
          _dot(AppColors.info),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

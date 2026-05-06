import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/debt_category.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/debt_calculator.dart';
import '../../../core/providers.dart';
import '../domain/debt_model.dart';
import '../../payment_record/presentation/payment_record_sheet.dart';

/// 빚 상세 화면
class DebtDetailScreen extends ConsumerWidget {
  final String debtId;

  const DebtDetailScreen({super.key, required this.debtId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtListProvider);
    final debt = debts.where((d) => d.id == debtId).firstOrNull;

    if (debt == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('빚 정보를 찾을 수 없어요')),
      );
    }

    final category = DebtCategory.values.firstWhere(
      (c) => c.name == debt.category,
      orElse: () => DebtCategory.other,
    );

    final progress = DebtCalculator.debtProgress(
      initialAmount: debt.initialAmount,
      currentBalance: debt.currentBalance,
    );

    final estimatedMonths = debt.targetPayment != null && debt.targetPayment! > 0
        ? DebtCalculator.estimateMonths(
            balance: debt.currentBalance,
            monthlyPayment: debt.targetPayment!,
            annualRate: debt.interestRate,
          )
        : null;

    final graduationDate = debt.targetPayment != null && debt.targetPayment! > 0
        ? DebtCalculator.estimateGraduationDate(
            balance: debt.currentBalance,
            monthlyPayment: debt.targetPayment!,
            annualRate: debt.interestRate,
          )
        : null;

    // 이 빚의 상환 기록
    final payments = ref.watch(paymentListProvider)
        .where((p) => p.debtId == debtId)
        .toList();
    final totalPaid = payments.fold(0, (sum, p) => sum + p.amount);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(debt.name),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenu(context, ref, value, debt),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('수정')),
              const PopupMenuItem(value: 'delete', child: Text('삭제')),
              if (!debt.isPaidOff)
                const PopupMenuItem(value: 'graduate', child: Text('졸업 처리')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // 잔액 카드
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '남은 잔액',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppFormatters.amountWon(debt.currentBalance),
                    style: AppTypography.displayAmount,
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('진행률', style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        )),
                        Text(
                          AppFormatters.progress(progress),
                          style: AppTypography.headingSmall.copyWith(
                            color: category.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppProgressBar(progress: progress, color: category.color),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '시작: ${AppFormatters.amountWon(debt.initialAmount ?? 0)} · 갚은 금액: ${AppFormatters.amountWon(totalPaid)}',
                      style: AppTypography.labelTiny,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 상세 정보
            AppCard(
              child: Column(
                children: [
                  _infoRow('카테고리', category.displayName),
                  const Divider(height: AppSpacing.xxl),
                  _infoRow('이자율', AppFormatters.interestRate(debt.interestRate)),
                  if (debt.minimumPayment != null) ...[
                    const Divider(height: AppSpacing.xxl),
                    _infoRow('최소 상환액', AppFormatters.amountWon(debt.minimumPayment!)),
                  ],
                  if (debt.targetPayment != null) ...[
                    const Divider(height: AppSpacing.xxl),
                    _infoRow('목표 상환액', AppFormatters.amountWon(debt.targetPayment!)),
                  ],
                  if (debt.paymentDay != null) ...[
                    const Divider(height: AppSpacing.xxl),
                    _infoRow('결제일', debt.paymentDay == -1 ? '매달 말일' : '매달 ${debt.paymentDay}일'),
                  ],
                  if (estimatedMonths != null) ...[
                    const Divider(height: AppSpacing.xxl),
                    _infoRow(
                      '예상 졸업',
                      graduationDate != null
                          ? AppFormatters.yearMonth(graduationDate)
                          : '약 $estimatedMonths개월 후',
                      valueColor: AppColors.success,
                    ),
                  ],
                  const Divider(height: AppSpacing.xxl),
                  _infoRow('등록일', AppFormatters.fullDate(debt.createdAt)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // 상환 기록 목록
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('상환 기록', style: AppTypography.headingSmall),
                Text(
                  '${payments.length}건',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            if (payments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Text(
                    '아직 상환 기록이 없어요',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              )
            else
              ...payments.take(20).map((payment) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppFormatters.fullDate(payment.paidAt),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (payment.note != null && payment.note!.isNotEmpty)
                            Text(
                              payment.note!,
                              style: AppTypography.labelTiny,
                            ),
                        ],
                      ),
                      Text(
                        '-${AppFormatters.amountWon(payment.amount)}',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )),

            const SizedBox(height: AppSpacing.xxl),

            // 상환 기록 버튼
            AppPrimaryButton(
              text: '+ 상환 기록',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => PaymentRecordSheet(
                    preselectedDebtId: debtId,
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        )),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _handleMenu(BuildContext context, WidgetRef ref, String value, DebtModel debt) {
    switch (value) {
      case 'delete':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('빚 삭제'),
            content: Text('${debt.name}을(를) 삭제할까요? 상환 기록도 함께 삭제돼요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(debtListProvider.notifier).removeDebt(debt.id);
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: Text('삭제', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        );
        break;
      case 'graduate':
        debt.isPaidOff = true;
        debt.paidOffAt = DateTime.now();
        debt.currentBalance = 0;
        ref.read(debtListProvider.notifier).updateDebt(debt);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${debt.name} 졸업을 축하해요!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
        break;
    }
  }
}

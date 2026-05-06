import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/debt_category.dart';
import '../../../core/constants/motivation_quotes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/amount_input_field.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/debt_calculator.dart';
import '../../../core/providers.dart';
import '../../debt_register/domain/debt_model.dart';
import '../domain/payment_model.dart';

/// 상환 기록 바텀시트
class PaymentRecordSheet extends ConsumerStatefulWidget {
  final String? preselectedDebtId;

  const PaymentRecordSheet({super.key, this.preselectedDebtId});

  @override
  ConsumerState<PaymentRecordSheet> createState() =>
      _PaymentRecordSheetState();
}

class _PaymentRecordSheetState extends ConsumerState<PaymentRecordSheet> {
  final _amountController = TextEditingController();
  String? _selectedDebtId;
  DateTime _selectedDate = DateTime.now();
  String _dateLabel = AppStrings.today;
  bool _showMemo = false;
  final _memoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final debts = ref.read(debtListProvider);
    if (widget.preselectedDebtId != null) {
      _selectedDebtId = widget.preselectedDebtId;
    } else if (debts.isNotEmpty) {
      // 우선순위 빚 자동 선택
      _selectedDebtId = debts.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  DebtModel? get _selectedDebt {
    final debts = ref.read(debtListProvider);
    return debts.where((d) => d.id == _selectedDebtId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(debtListProvider);
    final selectedDebt = _selectedDebt;
    final amount = AppFormatters.parseAmount(_amountController.text);

    // 원금/이자 분리
    Map<String, int>? principalInterest;
    if (selectedDebt != null && amount != null && amount > 0) {
      principalInterest = DebtCalculator.splitPrincipalInterest(
        totalPayment: amount,
        currentBalance: selectedDebt.currentBalance,
        annualRate: selectedDebt.interestRate,
      );
    }

    // 변화 미리보기 (잔액 차감은 원금만)
    int? newBalance;
    double? newProgress;
    double? oldProgress;
    if (selectedDebt != null && amount != null && amount > 0) {
      final principalAmount = principalInterest!['principal']!;
      newBalance = (selectedDebt.currentBalance - principalAmount).clamp(0, selectedDebt.currentBalance);
      if (selectedDebt.initialAmount != null) {
        oldProgress = DebtCalculator.debtProgress(
          initialAmount: selectedDebt.initialAmount,
          currentBalance: selectedDebt.currentBalance,
        );
        newProgress = DebtCalculator.debtProgress(
          initialAmount: selectedDebt.initialAmount,
          currentBalance: newBalance,
        );
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(AppStrings.paymentRecordTitle,
                    style: AppTypography.headingSmall),
                Text(
                  AppFormatters.date(DateTime.now()),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 빚 선택 (1개면 자동, 여러 개면 라디오)
                  if (debts.length > 1) ...[
                    Text(AppStrings.whereDidYouPay,
                        style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    ...debts.map((debt) {
                      final category = DebtCategory.values.firstWhere(
                        (c) => c.name == debt.category,
                        orElse: () => DebtCategory.other,
                      );
                      final isSelected = _selectedDebtId == debt.id;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDebtId = debt.id),
                        child: Container(
                          margin:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.surface
                                : AppColors.surfaceSecondary,
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.textPrimary,
                                    width: 1.5)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 20,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
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
                                    style: AppTypography.bodyMedium),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    AppFormatters.amountWon(
                                        debt.currentBalance),
                                    style: AppTypography.bodySmall,
                                  ),
                                  Text(
                                    AppFormatters.interestRate(
                                        debt.interestRate),
                                    style: AppTypography.labelTiny,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.lg),
                  ] else if (debts.length == 1)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Text(
                        '${debts.first.name}에 갚기',
                        style: AppTypography.headingSmall,
                      ),
                    ),

                  // 금액 입력
                  Text(AppStrings.howMuchDidYouPay,
                      style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  AmountInputField(
                    controller: _amountController,
                    large: true,
                    onChanged: (_) => setState(() {}),
                  ),

                  // 빠른 선택 칩
                  if (selectedDebt != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        if (selectedDebt.minimumPayment != null)
                          AppChip(
                            label:
                                '최소 ${AppFormatters.amountManWon(selectedDebt.minimumPayment!)}',
                            onTap: () {
                              _amountController.text =
                                  AppFormatters.amount(
                                      selectedDebt.minimumPayment!);
                              setState(() {});
                            },
                          ),
                        if (selectedDebt.targetPayment != null)
                          AppChip(
                            label:
                                '목표 ${AppFormatters.amountManWon(selectedDebt.targetPayment!)}',
                            isSelected: true,
                            onTap: () {
                              _amountController.text =
                                  AppFormatters.amount(
                                      selectedDebt.targetPayment!);
                              setState(() {});
                            },
                          ),
                        if (selectedDebt.targetPayment != null)
                          AppChip(
                            label: '+10만원 더',
                            onTap: () {
                              _amountController.text =
                                  AppFormatters.amount(
                                      selectedDebt.targetPayment! +
                                          100000);
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xxl),

                  // 원금/이자 분리 표시 (이자율 > 0일 때만)
                  if (principalInterest != null &&
                      selectedDebt != null &&
                      selectedDebt.interestRate > 0) ...[
                    InfoCard(
                      tone: InfoCardTone.info,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Text(
                        '원금 ${AppFormatters.amountWon(principalInterest['principal']!)} (잔액 차감) + 이자 ${AppFormatters.amountWon(principalInterest['interest']!)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.infoDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  // 즉시 변화 미리보기
                  if (newBalance != null)
                    InfoCard(
                      tone: InfoCardTone.success,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.thisIsHowItChanges,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      AppStrings.remainingBalance,
                                      style:
                                          AppTypography.labelTiny.copyWith(
                                        color: AppColors.successDark,
                                      ),
                                    ),
                                    Text(
                                      AppFormatters.amountWon(newBalance),
                                      style: AppTypography.headingMedium
                                          .copyWith(
                                        color: AppColors.successDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward,
                                  color: AppColors.success, size: 20),
                              if (newProgress != null)
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        AppStrings.progressRate,
                                        style: AppTypography.labelTiny
                                            .copyWith(
                                          color: AppColors.successDark,
                                        ),
                                      ),
                                      Text(
                                        AppFormatters.progress(
                                            newProgress),
                                        style: AppTypography.headingMedium
                                            .copyWith(
                                          color: AppColors.successDark,
                                        ),
                                      ),
                                      if (oldProgress != null)
                                        Text(
                                          '▲ ${((newProgress - oldProgress) * 100).toStringAsFixed(1)}%',
                                          style: AppTypography.labelTiny
                                              .copyWith(
                                            color: AppColors.success,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xxl),

                  // 날짜 선택
                  Text(AppStrings.whenDidYouPay,
                      style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      AppChip(
                        label: AppStrings.today,
                        isSelected: _dateLabel == AppStrings.today,
                        onTap: () => setState(() {
                          _selectedDate = DateTime.now();
                          _dateLabel = AppStrings.today;
                        }),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppChip(
                        label: AppStrings.yesterday,
                        isSelected: _dateLabel == AppStrings.yesterday,
                        onTap: () => setState(() {
                          _selectedDate = DateTime.now()
                              .subtract(const Duration(days: 1));
                          _dateLabel = AppStrings.yesterday;
                        }),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppChip(
                        label: AppStrings.selectDate,
                        isSelected: _dateLabel == AppStrings.selectDate,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 30)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                              _dateLabel = AppStrings.selectDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 메모 토글
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showMemo = !_showMemo),
                    child: Row(
                      children: [
                        Icon(
                          _showMemo
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        Text(
                          '메모 추가',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showMemo) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _memoController,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        hintText: '예: 보너스로 추가 상환',
                        counterText: '',
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // 동기부여 인용구
                  InfoCard(
                    tone: InfoCardTone.purple,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      MotivationQuotes.randomPaymentQuote(),
                      style: AppTypography.quote.copyWith(
                        color: AppColors.purpleDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),

          // 하단 버튼
          Container(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AppSecondaryButton(
                    text: AppStrings.cancel,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: AppPrimaryButton(
                    text: '${AppStrings.recordComplete} ✓',
                    isLoading: _isLoading,
                    onPressed: amount != null && amount > 0
                        ? _handleRecord
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRecord() async {
    final user = ref.read(currentUserProvider);
    final selectedDebt = _selectedDebt;
    final amount = AppFormatters.parseAmount(_amountController.text);

    if (user == null || selectedDebt == null || amount == null || amount <= 0) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 원금/이자 분리
      final split = DebtCalculator.splitPrincipalInterest(
        totalPayment: amount,
        currentBalance: selectedDebt.currentBalance,
        annualRate: selectedDebt.interestRate,
      );
      final principalAmount = split['principal']!;
      final interestAmount = split['interest']!;

      final balanceBefore = selectedDebt.currentBalance;
      // 잔액 차감은 원금만 적용
      final balanceAfter = (balanceBefore - principalAmount).clamp(0, balanceBefore);
      final isExtra = selectedDebt.targetPayment != null &&
          amount > selectedDebt.targetPayment!;

      // Payment 생성
      final payment = PaymentModel(
        id: const Uuid().v4(),
        userId: user.id,
        debtId: selectedDebt.id,
        amount: amount,
        principalAmount: principalAmount,
        interestAmount: interestAmount,
        paidAt: _selectedDate,
        note: _memoController.text.isEmpty ? null : _memoController.text,
        isExtra: isExtra,
        createdAt: DateTime.now(),
        balanceBefore: balanceBefore,
        balanceAfter: balanceAfter,
      );

      await ref.read(paymentListProvider.notifier).addPayment(payment);

      // Debt 잔액 갱신
      selectedDebt.currentBalance = balanceAfter;
      if (balanceAfter <= 0) {
        selectedDebt.isPaidOff = true;
        selectedDebt.paidOffAt = DateTime.now();
      }
      await ref.read(debtListProvider.notifier).updateDebt(selectedDebt);

      // 연속 기록 갱신
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final hadYesterday = await paymentRepo.hasPaymentOnDate(user.id, yesterday);

      int newStreak;
      if (hadYesterday) {
        newStreak = user.streakCount + 1;
      } else {
        newStreak = 1;
      }
      await ref.read(currentUserProvider.notifier).updateStreak(newStreak);

      // 진행률 변화 계산
      final progressChange = selectedDebt.initialAmount != null
          ? (amount / selectedDebt.initialAmount! * 100).toStringAsFixed(0)
          : null;

      if (mounted) {
        Navigator.pop(context);
        // 토스트
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              progressChange != null
                  ? '기록 완료! +$progressChange% 진행'
                  : '기록 완료!',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('기록 중 문제가 생겼어요: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

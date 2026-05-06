import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/debt_category.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/amount_input_field.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/debt_calculator.dart';
import '../../../core/providers.dart';
import '../domain/debt_model.dart';
import 'debt_register_step1_screen.dart';

/// 빚 등록 2단계
class DebtRegisterStep2Screen extends ConsumerStatefulWidget {
  const DebtRegisterStep2Screen({super.key});

  @override
  ConsumerState<DebtRegisterStep2Screen> createState() =>
      _DebtRegisterStep2ScreenState();
}

class _DebtRegisterStep2ScreenState
    extends ConsumerState<DebtRegisterStep2Screen> {
  final _minPaymentController = TextEditingController();
  final _targetPaymentController = TextEditingController();
  final _customLoanTermController = TextEditingController();

  int? _loanTermMonths; // 선택된 대출 기간 (개월)
  bool _isCustomLoanTerm = false; // 직접입력 모드 여부
  int? _selectedPaymentDay;
  String _notificationTiming = 'threeDaysBefore';

  @override
  void dispose() {
    _minPaymentController.dispose();
    _targetPaymentController.dispose();
    _customLoanTermController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _tempData => ref.read(debtRegisterTempProvider);

  int get _balance => _tempData['currentBalance'] as int? ?? 0;
  double get _interestRate => _tempData['interestRate'] as double? ?? 0;
  String get _debtName => _tempData['name'] as String? ?? '';
  String get _categoryName => _tempData['category'] as String? ?? 'other';

  DebtCategory get _category => DebtCategory.values.firstWhere(
        (c) => c.name == _categoryName,
        orElse: () => DebtCategory.other,
      );

  @override
  Widget build(BuildContext context) {
    final targetPayment =
        AppFormatters.parseAmount(_targetPaymentController.text);
    final minPayment =
        AppFormatters.parseAmount(_minPaymentController.text);

    // 완납 단축 계산
    int? monthsSaved;
    if (minPayment != null &&
        minPayment > 0 &&
        targetPayment != null &&
        targetPayment > minPayment) {
      monthsSaved = DebtCalculator.monthsSaved(
        balance: _balance,
        minimumPayment: minPayment,
        targetPayment: targetPayment,
        annualRate: _interestRate,
      );
    }

    // 예상 완납: 대출 기간이 있으면 우선 사용
    final paymentBasedMonths = targetPayment != null && targetPayment > 0
        ? DebtCalculator.estimateMonths(
            balance: _balance,
            monthlyPayment: targetPayment,
            annualRate: _interestRate,
          )
        : null;
    final estimatedMonths = _loanTermMonths ?? paymentBasedMonths;

    // 상환액 기반 예상이 대출 기간을 초과하는지 확인
    final bool paymentExceedsLoanTerm = _loanTermMonths != null &&
        paymentBasedMonths != null &&
        paymentBasedMonths > _loanTermMonths!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.debtRegisterTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: Text(
                '2 / 2',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행률 100%
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: AppProgressBar(
                progress: 1.0,
                color: AppColors.success,
                height: 4,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),

                    // 동기 카피
                    Text(AppStrings.repaymentPlan,
                        style: AppTypography.headingMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.skipOk,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 대출 기간
                    Text(AppStrings.loanTerm,
                        style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _loanTermChip('1년', 12),
                        _loanTermChip('2년', 24),
                        _loanTermChip('3년', 36),
                        _loanTermChip('5년', 60),
                        _loanTermChip('10년', 120),
                        AppChip(
                          label: '직접입력',
                          isSelected: _isCustomLoanTerm,
                          onTap: () => setState(() {
                            _isCustomLoanTerm = true;
                            _loanTermMonths = null;
                          }),
                        ),
                      ],
                    ),
                    if (_isCustomLoanTerm) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: 160,
                        child: TextField(
                          controller: _customLoanTermController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          textAlign: TextAlign.right,
                          style: AppTypography.headingMedium,
                          decoration: InputDecoration(
                            hintText: '0',
                            suffixText: '년',
                            suffixStyle: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          onChanged: (value) {
                            final years = int.tryParse(value);
                            setState(() {
                              _loanTermMonths =
                                  years != null && years > 0 ? years * 12 : null;
                            });
                          },
                        ),
                      ),
                    ],
                    if (_loanTermMonths != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${_loanTermMonths! ~/ 12}년 ($_loanTermMonths개월)',
                        style: AppTypography.labelTiny,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl),

                    // 상환액
                    AmountInputField(
                      controller: _minPaymentController,
                      label: AppStrings.minimumPayment,
                      hint: '0',
                      onChanged: (_) => setState(() {}),
                    ),
                    // 원금/이자 분리 표시 (이자율 > 0이고 상환액 입력 시)
                    if (minPayment != null &&
                        minPayment > 0 &&
                        _interestRate > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Builder(builder: (context) {
                        final split =
                            DebtCalculator.splitPrincipalInterest(
                          totalPayment: minPayment,
                          currentBalance: _balance,
                          annualRate: _interestRate,
                        );
                        return InfoCard(
                          tone: InfoCardTone.info,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Text(
                            '원금 ${AppFormatters.amountWon(split['principal']!)} + 이자 ${AppFormatters.amountWon(split['interest']!)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.infoDark,
                            ),
                          ),
                        );
                      }),
                    ] else ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '카드사가 요구하는 결제액이에요',
                        style: AppTypography.labelTiny,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl),

                    // 목표 상환액
                    AmountInputField(
                      controller: _targetPaymentController,
                      label: AppStrings.targetPayment,
                      hint: '0',
                      onChanged: (_) => setState(() {}),
                    ),
                    // 원금/이자 분리 표시 (목표 금액)
                    if (targetPayment != null &&
                        targetPayment > 0 &&
                        _interestRate > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Builder(builder: (context) {
                        final split =
                            DebtCalculator.splitPrincipalInterest(
                          totalPayment: targetPayment,
                          currentBalance: _balance,
                          annualRate: _interestRate,
                        );
                        return InfoCard(
                          tone: InfoCardTone.info,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Text(
                            '원금 ${AppFormatters.amountWon(split['principal']!)} + 이자 ${AppFormatters.amountWon(split['interest']!)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.infoDark,
                            ),
                          ),
                        );
                      }),
                    ],

                    // 즉시 피드백 카드
                    if (monthsSaved != null && monthsSaved > 0) ...[
                      const SizedBox(height: AppSpacing.md),
                      InfoCard(
                        tone: InfoCardTone.success,
                        child: Text(
                          '상환액보다 ${AppFormatters.amountWon(targetPayment! - minPayment!)} 더 갚으면 완납이 $monthsSaved개월 빨라져요',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl),

                    // 결제일
                    Text(AppStrings.paymentDay,
                        style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _dayChip('5일', 5),
                        const SizedBox(width: AppSpacing.sm),
                        _dayChip('15일', 15),
                        const SizedBox(width: AppSpacing.sm),
                        _dayChip('25일', 25),
                        const SizedBox(width: AppSpacing.sm),
                        _dayChip('말일', -1),
                      ],
                    ),
                    if (_selectedPaymentDay != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _selectedPaymentDay == -1
                            ? '매달 말일에 알려드릴게요'
                            : '매달 $_selectedPaymentDay일에 알려드릴게요',
                        style: AppTypography.labelTiny,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl),

                    // 알림 시점
                    Text(AppStrings.notificationTiming,
                        style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    _notificationOption(
                      'threeDaysBefore',
                      AppStrings.threeDaysBefore,
                      AppStrings.threeBeforeSub,
                      isDefault: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _notificationOption(
                        'sameDay', AppStrings.sameDay, null),
                    const SizedBox(height: AppSpacing.sm),
                    _notificationOption(
                        'none', AppStrings.noNotification, null),

                    const SizedBox(height: AppSpacing.xxl),

                    // 미리보기 카드
                    Text(AppStrings.previewCard,
                        style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _category.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(_debtName,
                                  style: AppTypography.headingSmall),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            AppFormatters.amountWon(_balance),
                            style: AppTypography.displayAmount,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '이자율 ${AppFormatters.interestRate(_interestRate)}'
                            '${_selectedPaymentDay != null ? ' · ${_selectedPaymentDay == -1 ? "말일" : "$_selectedPaymentDay일"} 결제' : ''}'
                            '${targetPayment != null && targetPayment > 0 ? ' · 목표 ${AppFormatters.amountWon(targetPayment)}' : ''}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (estimatedMonths != null) ...[
                            const Divider(height: AppSpacing.xxl),
                            Row(
                              children: [
                                Text(
                                  '${AppStrings.estimatedGraduation}: ',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  _loanTermMonths != null
                                      ? '${_loanTermMonths! ~/ 12}년 ($_loanTermMonths개월)'
                                      : '약 $estimatedMonths개월 후',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (paymentExceedsLoanTerm) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '현재 상환액으로는 대출 기간 내 완납이 어려워요. 상환액을 늘려보세요.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxxl),
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
                      text: AppStrings.skip,
                      onPressed: () => _handleComplete(skip: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: AppPrimaryButton(
                      text: AppStrings.registerComplete,
                      onPressed: () => _handleComplete(skip: false),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loanTermChip(String label, int months) {
    return AppChip(
      label: label,
      isSelected: !_isCustomLoanTerm && _loanTermMonths == months,
      onTap: () => setState(() {
        _isCustomLoanTerm = false;
        _loanTermMonths = months;
        _customLoanTermController.clear();
      }),
    );
  }

  Widget _dayChip(String label, int day) {
    return Expanded(
      child: AppChip(
        label: label,
        isSelected: _selectedPaymentDay == day,
        onTap: () => setState(() => _selectedPaymentDay = day),
      ),
    );
  }

  Widget _notificationOption(String value, String title, String? subtitle,
      {bool isDefault = false}) {
    final isSelected = _notificationTiming == value;
    return GestureDetector(
      onTap: () => setState(() => _notificationTiming = value),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isSelected
              ? Border.all(color: AppColors.textPrimary, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              size: 20,
              color:
                  isSelected ? AppColors.textPrimary : AppColors.textTertiary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius:
                                BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            '추천',
                            style: AppTypography.labelTiny.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTypography.labelTiny,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleComplete({required bool skip}) async {
    final user = ref.read(currentUserProvider);
    final userId = user?.id ?? 'local_user';

    final tempData = ref.read(debtRegisterTempProvider);
    final balance = tempData['currentBalance'] as int;

    final debt = DebtModel(
      id: const Uuid().v4(),
      userId: userId,
      name: tempData['name'] as String,
      category: tempData['category'] as String,
      initialAmount: (tempData['initialAmount'] as int?) ?? balance,
      currentBalance: balance,
      interestRate: tempData['interestRate'] as double? ?? 0,
      minimumPayment: skip
          ? null
          : AppFormatters.parseAmount(_minPaymentController.text),
      targetPayment: skip
          ? null
          : AppFormatters.parseAmount(_targetPaymentController.text),
      paymentDay: skip ? null : _selectedPaymentDay,
      notificationTiming: skip ? 'threeDaysBefore' : _notificationTiming,
      createdAt: DateTime.now(),
      loanTermMonths: skip ? null : _loanTermMonths,
    );

    // 저장 (네트워크 오류 시에도 로컬 상태에 반영)
    try {
      await ref.read(debtListProvider.notifier).addDebt(debt);
    } catch (_) {
      ref.read(debtListProvider.notifier).addDebtLocal(debt);
    }

    // 전략 기반 정렬
    ref
        .read(debtListProvider.notifier)
        .sortByStrategy(user?.strategy ?? 'snowball');

    // 첫 빚이면 firstStep 배지 획득
    final debtCount = ref.read(debtListProvider).length;
    if (debtCount == 1) {
      try {
        await ref
            .read(badgeListProvider.notifier)
            .earnBadge('firstStep', userId);
      } catch (_) {
        // 배지 저장 실패 무시
      }
    }

    // 임시 데이터 정리
    ref.read(debtRegisterTempProvider.notifier).state = {};

    if (mounted) {
      context.go('/debt/add/complete');
    }
  }
}

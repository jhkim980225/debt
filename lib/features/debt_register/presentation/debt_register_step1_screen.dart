import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/debt_category.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/amount_input_field.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/debt_calculator.dart';

// 임시 상태 (빚 등록 플로우)
final debtRegisterTempProvider =
    StateProvider<Map<String, dynamic>>((ref) => {});

/// 빚 등록 1단계
class DebtRegisterStep1Screen extends ConsumerStatefulWidget {
  const DebtRegisterStep1Screen({super.key});

  @override
  ConsumerState<DebtRegisterStep1Screen> createState() =>
      _DebtRegisterStep1ScreenState();
}

class _DebtRegisterStep1ScreenState
    extends ConsumerState<DebtRegisterStep1Screen> {
  DebtCategory? _selectedCategory;
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _initialAmountController = TextEditingController();
  final _interestRateController = TextEditingController();

  String? _categoryError;
  String? _nameError;
  String? _balanceError;
  String? _initialAmountError;

  @override
  void initState() {
    super.initState();
    // 기존 임시 데이터 복원
    final temp = ref.read(debtRegisterTempProvider);
    if (temp.isNotEmpty) {
      final cat = temp['category'] as String?;
      if (cat != null) {
        _selectedCategory = DebtCategory.values.firstWhere(
          (c) => c.name == cat,
          orElse: () => DebtCategory.other,
        );
      }
      _nameController.text = temp['name'] as String? ?? '';
      if (temp['currentBalance'] != null) {
        _balanceController.text =
            AppFormatters.amount(temp['currentBalance'] as int);
      }
      if (temp['initialAmount'] != null) {
        _initialAmountController.text =
            AppFormatters.amount(temp['initialAmount'] as int);
      }
      if (temp['interestRate'] != null) {
        _interestRateController.text =
            (temp['interestRate'] as double).toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _initialAmountController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCloseDialog(),
        ),
        title: const Text(AppStrings.debtRegisterTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: Text(
                '1 / 2',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),

                    // 섹션 1: 카테고리 선택
                    Text(AppStrings.whatKindOfDebt,
                        style: AppTypography.headingMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.selectCategory,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_categoryError != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _categoryError!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),

                    // 3x2 그리드
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.1,
                      children: DebtCategory.values.map((category) {
                        final isSelected = _selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              _categoryError = null;
                              // 플레이스홀더 업데이트
                              if (_nameController.text.isEmpty) {
                                _nameController.text = '';
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? category.color.withValues(alpha: 0.1)
                                  : AppColors.surfaceSecondary,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.lg),
                              border: isSelected
                                  ? Border.all(
                                      color: category.color, width: 2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  category.icon,
                                  color: isSelected
                                      ? category.color
                                      : AppColors.textSecondary,
                                  size: 24,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  category.displayName,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isSelected
                                        ? category.color
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 섹션 2: 빚 이름
                    Text(AppStrings.debtName, style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _nameController,
                      maxLength: 30,
                      decoration: InputDecoration(
                        hintText: _selectedCategory?.placeholder ?? '빚 이름을 입력해주세요',
                        counterText: '',
                        errorText: _nameError,
                      ),
                      onChanged: (_) => setState(() => _nameError = null),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 섹션 3: 현재 남은 금액
                    AmountInputField(
                      controller: _balanceController,
                      label: AppStrings.currentBalance,
                      errorText: _balanceError,
                      large: true,
                      onChanged: (_) => setState(() {
                        _balanceError = null;
                        _initialAmountError = null;
                      }),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 섹션 3.5: 처음 빌린 금액 (선택)
                    AmountInputField(
                      controller: _initialAmountController,
                      label: AppStrings.initialAmount,
                      hint: '선택 입력',
                      errorText: _initialAmountError,
                      onChanged: (_) => setState(() => _initialAmountError = null),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.initialAmountSub,
                      style: AppTypography.labelTiny,
                    ),
                    // 즉각 피드백: 진행률 표시
                    Builder(builder: (context) {
                      final initialAmount =
                          AppFormatters.parseAmount(_initialAmountController.text);
                      final currentBalance =
                          AppFormatters.parseAmount(_balanceController.text);
                      if (initialAmount != null &&
                          currentBalance != null &&
                          initialAmount > currentBalance &&
                          currentBalance > 0) {
                        final progress = DebtCalculator.debtProgress(
                          initialAmount: initialAmount,
                          currentBalance: currentBalance,
                        );
                        if (progress != null && progress > 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: InfoCard(
                              tone: InfoCardTone.success,
                              child: Row(
                                children: [
                                  const Icon(Icons.celebration_outlined,
                                      size: 16, color: AppColors.success),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      '이미 ${AppFormatters.progress(progress)} 갚았어요!',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    }),

                    const SizedBox(height: AppSpacing.xxl),

                    // 섹션 4: 연 이자율
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.annualInterestRate,
                            style: AppTypography.labelLarge),
                        GestureDetector(
                          onTap: _handleDontKnow,
                          child: Text(
                            AppStrings.iDontKnow,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _interestRateController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: '0',
                        suffixText: '%',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // 빠른 선택 칩
                    if (_selectedCategory != null)
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          AppChip(
                            label: '0% (무이자)',
                            isSelected:
                                _interestRateController.text == '0',
                            onTap: () {
                              setState(() =>
                                  _interestRateController.text = '0');
                            },
                          ),
                          AppChip(
                            label:
                                '${_selectedCategory!.averageInterestRate}% (평균)',
                            isSelected: _interestRateController.text ==
                                _selectedCategory!.averageInterestRate
                                    .toString(),
                            onTap: () {
                              setState(() =>
                                  _interestRateController.text =
                                      _selectedCategory!
                                          .averageInterestRate
                                          .toString());
                            },
                          ),
                        ],
                      ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 안심 메시지
                    InfoCard(
                      tone: InfoCardTone.info,
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: AppColors.infoDark),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              AppStrings.dontWorryAboutAccuracy,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.infoDark,
                              ),
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
                      onPressed: () => _showCloseDialog(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: AppPrimaryButton(
                      text: '${AppStrings.nextStep} →',
                      onPressed: _handleNext,
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

  void _handleDontKnow() {
    if (_selectedCategory == null) {
      setState(() => _categoryError = AppStrings.errorSelectCategory);
      return;
    }
    setState(() {
      _interestRateController.text =
          _selectedCategory!.averageInterestRate.toString();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('정확한 이자율은 다음에 수정할 수 있어요. 일단 평균값으로 시작할게요.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNext() {
    bool hasError = false;

    if (_selectedCategory == null) {
      setState(() => _categoryError = AppStrings.errorSelectCategory);
      hasError = true;
    }
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = AppStrings.errorEnterDebtName);
      hasError = true;
    }
    final balance = AppFormatters.parseAmount(_balanceController.text);
    if (balance == null || balance <= 0) {
      setState(() => _balanceError = AppStrings.errorEnterBalance);
      hasError = true;
    }

    // 처음 빌린 금액 검증 (선택 입력이지만, 입력 시 남은 금액 이상이어야 함)
    final initialAmount =
        AppFormatters.parseAmount(_initialAmountController.text);
    if (initialAmount != null && balance != null && initialAmount < balance) {
      setState(() => _initialAmountError =
          AppStrings.errorInitialLessThanBalance);
      hasError = true;
    }

    if (hasError) return;

    final rate =
        double.tryParse(_interestRateController.text) ?? 0;

    // 임시 상태에 저장
    ref.read(debtRegisterTempProvider.notifier).state = {
      'category': _selectedCategory!.name,
      'name': _nameController.text.trim(),
      'currentBalance': balance,
      'initialAmount': initialAmount,
      'interestRate': rate,
    };

    context.push('/debt/add/step2');
  }

  void _showCloseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('등록 취소'),
        content: const Text('지금까지 입력한 내용이 사라져요. 정말 닫으시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속 입력하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(debtRegisterTempProvider.notifier).state = {};
              context.go('/home');
            },
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

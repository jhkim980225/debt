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
import '../../debt_register/domain/debt_model.dart';

/// 시뮬레이션 결과
class _SimResult {
  final int months;
  final int totalInterest;
  final List<int> balanceHistory; // 월별 잔액

  _SimResult({
    required this.months,
    required this.totalInterest,
    required this.balanceHistory,
  });
}

/// 상환 시뮬레이션 화면
class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({super.key});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  double _monthlyBudget = 500000;
  String _selectedStrategy = 'snowball';

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    final debts = ref.read(debtListProvider);

    // 초기값: 사용자 예산 또는 최소 상환액 합계
    if (user?.monthlyBudget != null && user!.monthlyBudget! > 0) {
      _monthlyBudget = user.monthlyBudget!.toDouble();
    } else {
      final minSum = debts.fold<int>(
          0, (s, d) => s + (d.minimumPayment ?? 0));
      if (minSum > 0) _monthlyBudget = minSum.toDouble();
    }
    _monthlyBudget = _monthlyBudget.clamp(200000, 2000000);
    _selectedStrategy = user?.strategy ?? 'snowball';
  }

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(debtListProvider);

    // 빚 없음
    if (debts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('상환 시뮬레이션'),
        ),
        body: Center(
          child: Text(
            '갚을 빚이 없어요',
            style: AppTypography.headingMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    // 시뮬레이션 계산
    final snowball = _simulate(debts, _monthlyBudget.toInt(), 'snowball');
    final avalanche = _simulate(debts, _monthlyBudget.toInt(), 'avalanche');

    // 추천 전략 결정
    final recommended = _getRecommendedStrategy(debts, snowball, avalanche);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('상환 시뮬레이션'),
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

                    // 월 상환 가능 금액
                    Text('월 상환 가능 금액',
                        style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: Text(
                        AppFormatters.amountWon(_monthlyBudget.toInt()),
                        style: AppTypography.displayAmount.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Slider(
                      value: _monthlyBudget,
                      min: 200000,
                      max: 2000000,
                      divisions: 36,
                      activeColor: AppColors.info,
                      inactiveColor: AppColors.infoLight,
                      onChanged: (value) {
                        setState(() => _monthlyBudget = value);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('20만원', style: AppTypography.labelTiny),
                        Text('200만원', style: AppTypography.labelTiny),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 전략 비교
                    Text('전략 비교', style: AppTypography.headingMedium),
                    const SizedBox(height: AppSpacing.lg),

                    // 눈덩이 카드
                    _strategyCard(
                      strategy: 'snowball',
                      title: '눈덩이 방식',
                      subtitle: '작은 빚부터 갚아 성취감 ↑',
                      result: snowball,
                      isRecommended: recommended == 'snowball',
                      isSelected: _selectedStrategy == 'snowball',
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // 눈사태 카드
                    _strategyCard(
                      strategy: 'avalanche',
                      title: '눈사태 방식',
                      subtitle: '고이자부터 갚아 총 이자 ↓',
                      result: avalanche,
                      isRecommended: recommended == 'avalanche',
                      isSelected: _selectedStrategy == 'avalanche',
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 잔액 변화 시각화 (텍스트 기반)
                    Text('잔액 변화 예측', style: AppTypography.headingMedium),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _balanceChart(snowball, avalanche),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 3,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text('눈덩이',
                                  style: AppTypography.labelTiny),
                              const SizedBox(width: AppSpacing.lg),
                              Container(
                                width: 12,
                                height: 3,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.success,
                                    width: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text('눈사태',
                                  style: AppTypography.labelTiny),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 인사이트
                    _buildInsight(snowball, avalanche),

                    // 빚 1개일 때
                    if (debts.length == 1)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: AppSpacing.lg),
                        child: InfoCard(
                          tone: InfoCardTone.info,
                          child: Text(
                            '빚이 1개라 두 전략의 차이가 없어요',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.infoDark,
                            ),
                          ),
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
              child: AppPrimaryButton(
                text: '이 계획으로 시작하기',
                onPressed: _applyStrategy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _strategyCard({
    required String strategy,
    required String title,
    required String subtitle,
    required _SimResult result,
    required bool isRecommended,
    required bool isSelected,
  }) {
    final years = result.months ~/ 12;
    final months = result.months % 12;
    final timeStr =
        years > 0 ? '$years년 $months개월' : '$months개월';

    return GestureDetector(
      onTap: () => setState(() => _selectedStrategy = strategy),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.info : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: AppTypography.headingSmall),
                if (isRecommended) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      '추천',
                      style: AppTypography.labelTiny.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('완납까지',
                          style: AppTypography.labelTiny),
                      Text(timeStr,
                          style: AppTypography.headingSmall),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('총 이자',
                          style: AppTypography.labelTiny),
                      Text(
                        AppFormatters.amountManWon(result.totalInterest),
                        style: AppTypography.headingSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceChart(_SimResult snowball, _SimResult avalanche) {
    // 간단한 텍스트 기반 잔액 변화 (5구간)
    final maxMonths =
        snowball.months > avalanche.months ? snowball.months : avalanche.months;
    if (maxMonths == 0) return const SizedBox.shrink();

    final steps = 5;
    final stepSize = (maxMonths / steps).ceil();

    return Column(
      children: List.generate(steps + 1, (i) {
        final month = (i * stepSize).clamp(0, maxMonths);
        final snowBal = month < snowball.balanceHistory.length
            ? snowball.balanceHistory[month]
            : 0;
        final avaBal = month < avalanche.balanceHistory.length
            ? avalanche.balanceHistory[month]
            : 0;
        final totalInitial = snowball.balanceHistory.isNotEmpty
            ? snowball.balanceHistory[0]
            : 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '$month개월',
                  style: AppTypography.labelTiny,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    // 눈덩이
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: totalInitial > 0
                            ? (snowBal / totalInitial).clamp(0.0, 1.0)
                            : 0,
                        minHeight: 6,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.info),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // 눈사태
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: totalInitial > 0
                            ? (avaBal / totalInitial).clamp(0.0, 1.0)
                            : 0,
                        minHeight: 6,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.success),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInsight(_SimResult snowball, _SimResult avalanche) {
    final selected =
        _selectedStrategy == 'snowball' ? snowball : avalanche;
    final now = DateTime.now();
    final graduation =
        DateTime(now.year, now.month + selected.months, now.day);

    return InfoCard(
      tone: InfoCardTone.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이 페이스로 갚으면 ${graduation.year}년 ${graduation.month}월에 자유로워져요',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (selected.totalInterest > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '총 이자 ${AppFormatters.amountManWon(selected.totalInterest)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _SimResult _simulate(
      List<DebtModel> debts, int monthlyBudget, String strategy) {
    // 깊은 복사
    final simDebts = debts
        .map((d) => _SimDebt(
              balance: d.currentBalance.toDouble(),
              rate: d.interestRate,
              minPayment: d.minimumPayment ?? 0,
            ))
        .toList();

    // 정렬
    if (strategy == 'snowball') {
      simDebts.sort((a, b) => a.balance.compareTo(b.balance));
    } else {
      simDebts.sort((a, b) => b.rate.compareTo(a.rate));
    }

    int months = 0;
    double totalInterest = 0;
    final balanceHistory = <int>[];
    balanceHistory
        .add(simDebts.fold<double>(0, (s, d) => s + d.balance).toInt());

    while (simDebts.any((d) => d.balance > 0) && months < 600) {
      months++;

      // 이자 부과
      for (final debt in simDebts) {
        if (debt.balance <= 0) continue;
        final interest = debt.balance * (debt.rate / 100 / 12);
        debt.balance += interest;
        totalInterest += interest;
      }

      // 최소 결제
      var budgetLeft = monthlyBudget.toDouble();
      for (final debt in simDebts) {
        if (debt.balance <= 0) continue;
        final payment = [
          debt.minPayment.toDouble(),
          debt.balance,
          budgetLeft,
        ].reduce((a, b) => a < b ? a : b);
        debt.balance -= payment;
        budgetLeft -= payment;
      }

      // 남은 예산을 우선순위 빚에
      if (budgetLeft > 0) {
        for (final debt in simDebts) {
          if (debt.balance <= 0) continue;
          final payment =
              debt.balance < budgetLeft ? debt.balance : budgetLeft;
          debt.balance -= payment;
          budgetLeft -= payment;
          break;
        }
      }

      balanceHistory
          .add(simDebts.fold<double>(0, (s, d) => s + d.balance.clamp(0, double.infinity)).toInt());
    }

    return _SimResult(
      months: months,
      totalInterest: totalInterest.toInt(),
      balanceHistory: balanceHistory,
    );
  }

  String _getRecommendedStrategy(
      List<DebtModel> debts, _SimResult snowball, _SimResult avalanche) {
    // 눈사태 추천 조건
    if (debts.length >= 2 && debts.length <= 3) {
      final rates = debts.map((d) => d.interestRate).toList()..sort();
      if (rates.last - rates.first >= 5) {
        return 'avalanche';
      }
    }
    if (avalanche.totalInterest < snowball.totalInterest - 500000) {
      return 'avalanche';
    }
    // 기본 추천: 눈덩이
    return 'snowball';
  }

  void _applyStrategy() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      user.strategy = _selectedStrategy;
      user.monthlyBudget = _monthlyBudget.toInt();
    }

    // 우선순위 재계산
    ref.read(debtListProvider.notifier).sortByStrategy(_selectedStrategy);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('전략이 적용됐어요'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }
}

class _SimDebt {
  double balance;
  final double rate;
  final int minPayment;

  _SimDebt({
    required this.balance,
    required this.rate,
    required this.minPayment,
  });
}

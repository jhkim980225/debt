import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/providers.dart';
import '../../payment_record/domain/payment_model.dart';

/// 기간 필터 열거형
enum StatsPeriod { sixMonths, thisYear, all }

/// 통계 화면
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  StatsPeriod _period = StatsPeriod.sixMonths;

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(paymentListProvider);
    final debts = ref.watch(debtListProvider);

    // 기간 필터링
    final now = DateTime.now();
    final filteredPayments = _filterByPeriod(payments, now);

    // 데이터 부족 시
    if (payments.length < 5) {
      return _buildEmptyState();
    }

    // 핵심 지표 계산
    final totalPaid = filteredPayments.fold<int>(0, (s, p) => s + p.amount);
    final monthlyData = _groupByMonth(filteredPayments);

    // 빚별 비중
    final debtDistribution = <String, int>{};
    for (final debt in debts) {
      debtDistribution[debt.name] = debt.currentBalance;
    }
    final totalDebt =
        debtDistribution.values.fold<int>(0, (s, v) => s + v);

    // 인사이트 생성
    final insights = _generateInsights(filteredPayments, payments);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text('통계', style: AppTypography.headingLarge),
              const SizedBox(height: AppSpacing.lg),

              // 기간 필터
              Row(
                children: [
                  AppChip(
                    label: '최근 6개월',
                    isSelected: _period == StatsPeriod.sixMonths,
                    onTap: () =>
                        setState(() => _period = StatsPeriod.sixMonths),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppChip(
                    label: '올해',
                    isSelected: _period == StatsPeriod.thisYear,
                    onTap: () =>
                        setState(() => _period = StatsPeriod.thisYear),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppChip(
                    label: '전체',
                    isSelected: _period == StatsPeriod.all,
                    onTap: () => setState(() => _period = StatsPeriod.all),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 핵심 지표
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('총 상환액',
                              style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            AppFormatters.amountManWon(totalPaid),
                            style: AppTypography.headingMedium.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('상환 횟수',
                              style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${filteredPayments.length}회',
                            style: AppTypography.headingMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 월별 상환액 차트 (텍스트 기반 바 차트)
              Text('월별 상환액', style: AppTypography.headingMedium),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  children: monthlyData.entries.map((entry) {
                    final maxAmount = monthlyData.values.isEmpty
                        ? 1
                        : monthlyData.values
                            .reduce((a, b) => a > b ? a : b);
                    final ratio =
                        maxAmount > 0 ? entry.value / maxAmount : 0.0;
                    final isCurrentMonth = entry.key ==
                        '${now.year}-${now.month.toString().padLeft(2, '0')}';

                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${int.parse(entry.key.split('-')[1])}월',
                              style: AppTypography.labelSmall.copyWith(
                                color: isCurrentMonth
                                    ? AppColors.info
                                    : AppColors.textSecondary,
                                fontWeight: isCurrentMonth
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xs),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 20,
                                backgroundColor: AppColors.surfaceSecondary,
                                valueColor: AlwaysStoppedAnimation(
                                  isCurrentMonth
                                      ? AppColors.info
                                      : AppColors.infoMedium,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 60,
                            child: Text(
                              AppFormatters.amountManWon(entry.value),
                              style: AppTypography.labelSmall,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 빚별 비중
              if (debts.isNotEmpty) ...[
                Text('빚별 비중', style: AppTypography.headingMedium),
                const SizedBox(height: AppSpacing.lg),
                // 스택 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: SizedBox(
                    height: 12,
                    child: Row(
                      children: debts.map((debt) {
                        final ratio = totalDebt > 0
                            ? debt.currentBalance / totalDebt
                            : 0.0;
                        return Expanded(
                          flex: (ratio * 100).toInt().clamp(1, 100),
                          child: Container(
                            color: _debtColor(debts.indexOf(debt)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // 리스트
                ...debts.map((debt) {
                  final ratio = totalDebt > 0
                      ? (debt.currentBalance / totalDebt * 100)
                      : 0.0;
                  final index = debts.indexOf(debt);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _debtColor(index),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(debt.name,
                              style: AppTypography.bodyMedium),
                        ),
                        Text(
                          AppFormatters.amountManWon(debt.currentBalance),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${ratio.toInt()}%',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // 인사이트
              if (insights.isNotEmpty) ...[
                Text('발견한 패턴', style: AppTypography.headingMedium),
                const SizedBox(height: AppSpacing.lg),
                ...insights.map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: InfoCard(
                        tone: insight.tone,
                        child: Text(
                          insight.message,
                          style: AppTypography.bodyMedium.copyWith(
                            color: insight.tone.textColor,
                          ),
                        ),
                      ),
                    )),
              ],

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
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart_rounded,
                    size: 64, color: AppColors.textTertiary),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  '상환 기록이 쌓이면\n여기에 그래프와 패턴이 나타나요',
                  style: AppTypography.headingMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '1주일만 기록해도 흥미로운 패턴이 보일 거예요',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PaymentModel> _filterByPeriod(List<PaymentModel> payments, DateTime now) {
    switch (_period) {
      case StatsPeriod.sixMonths:
        final cutoff = DateTime(now.year, now.month - 6, now.day);
        return payments.where((p) => p.paidAt.isAfter(cutoff)).toList();
      case StatsPeriod.thisYear:
        return payments
            .where((p) => p.paidAt.year == now.year)
            .toList();
      case StatsPeriod.all:
        return payments;
    }
  }

  Map<String, int> _groupByMonth(List<PaymentModel> payments) {
    final map = <String, int>{};
    for (final p in payments) {
      final key =
          '${p.paidAt.year}-${p.paidAt.month.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0) + p.amount;
    }
    // 정렬
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }

  Color _debtColor(int index) {
    const colors = [
      AppColors.info,
      AppColors.success,
      AppColors.accent,
      AppColors.purple,
      AppColors.pink,
      AppColors.danger,
    ];
    return colors[index % colors.length];
  }

  List<_Insight> _generateInsights(
      List<PaymentModel> filtered, List<PaymentModel> all) {
    final insights = <_Insight>[];

    if (filtered.length < 5) return insights;

    // 1. 상환 속도 변화
    final now = DateTime.now();
    final recent3 = filtered
        .where((p) =>
            p.paidAt.isAfter(DateTime(now.year, now.month - 3, now.day)))
        .toList();
    final prev3 = filtered
        .where((p) =>
            p.paidAt.isBefore(DateTime(now.year, now.month - 3, now.day)))
        .toList();

    if (recent3.isNotEmpty && prev3.isNotEmpty) {
      final recentAvg = recent3.fold<int>(0, (s, p) => s + p.amount) /
          recent3.length;
      final prevAvg =
          prev3.fold<int>(0, (s, p) => s + p.amount) / prev3.length;
      if (recentAvg > prevAvg * 1.1) {
        insights.add(_Insight(
          message: '상환 속도가 점점 빨라지고 있어요',
          tone: InfoCardTone.success,
        ));
      }
    }

    // 2. 자주 갚는 요일
    final dayCounts = <int, int>{};
    for (final p in filtered) {
      dayCounts[p.paidAt.weekday] = (dayCounts[p.paidAt.weekday] ?? 0) + 1;
    }
    if (dayCounts.isNotEmpty) {
      final maxDay =
          dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (maxDay.value >= 5) {
        final dayNames = ['', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
        insights.add(_Insight(
          message: '${dayNames[maxDay.key]}에 가장 많이 갚는 것 같아요',
          tone: InfoCardTone.warning,
        ));
      }
    }

    // 3. 주말 vs 평일
    final weekdayPayments =
        filtered.where((p) => p.paidAt.weekday <= 5).length;
    final weekendPayments =
        filtered.where((p) => p.paidAt.weekday > 5).length;
    if (weekdayPayments > 0 && weekendPayments > 0) {
      final weekdayAvg = weekdayPayments / 5;
      final weekendAvg = weekendPayments / 2;
      if (weekdayAvg > weekendAvg * 1.3) {
        insights.add(_Insight(
          message: '주말보다 평일에 더 많이 갚는 것 같아요',
          tone: InfoCardTone.warning,
        ));
      } else if (weekendAvg > weekdayAvg * 1.3) {
        insights.add(_Insight(
          message: '주말에 더 활발하게 갚고 있어요',
          tone: InfoCardTone.success,
        ));
      }
    }

    return insights.take(3).toList();
  }
}

class _Insight {
  final String message;
  final InfoCardTone tone;

  _Insight({required this.message, required this.tone});
}

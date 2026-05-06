import 'dart:math';

/// 빚 계산 유틸리티 (docs/data-model.md 참조)
class DebtCalculator {
  DebtCalculator._();

  /// 예상 완납 개월수 계산 (복리 기준)
  /// [balance]: 현재 잔액
  /// [monthlyPayment]: 매달 상환액
  /// [annualRate]: 연 이자율 (%)
  /// 반환: 개월수 (null이면 상환 불가능)
  static int? estimateMonths({
    required int balance,
    required int monthlyPayment,
    required double annualRate,
  }) {
    if (balance <= 0 || monthlyPayment <= 0) return null;

    final p = balance.toDouble();
    final m = monthlyPayment.toDouble();
    final r = annualRate / 100 / 12; // 월 이자율

    if (r == 0) {
      // 무이자
      return (p / m).ceil();
    }

    // n = -log(1 - P*r/M) / log(1 + r)
    final prm = p * r / m;
    if (prm >= 1) {
      // 상환 불가능 (이자가 상환액보다 큼)
      return null;
    }

    final n = -log(1 - prm) / log(1 + r);
    return n.ceil();
  }

  /// 예상 졸업 날짜
  static DateTime? estimateGraduationDate({
    required int balance,
    required int monthlyPayment,
    required double annualRate,
  }) {
    final months = estimateMonths(
      balance: balance,
      monthlyPayment: monthlyPayment,
      annualRate: annualRate,
    );
    if (months == null) return null;

    final now = DateTime.now();
    return DateTime(now.year, now.month + months, now.day);
  }

  /// 목표 상환 시 단축되는 개월수
  /// [minimumPayment]: 최소 상환액
  /// [targetPayment]: 목표 상환액
  static int? monthsSaved({
    required int balance,
    required int minimumPayment,
    required int targetPayment,
    required double annualRate,
  }) {
    final minMonths = estimateMonths(
      balance: balance,
      monthlyPayment: minimumPayment,
      annualRate: annualRate,
    );
    final targetMonths = estimateMonths(
      balance: balance,
      monthlyPayment: targetPayment,
      annualRate: annualRate,
    );
    if (minMonths == null || targetMonths == null) return null;
    return minMonths - targetMonths;
  }

  /// 빚 진행률 (0.0 ~ 1.0)
  /// [initialAmount]이 null이면 null 반환
  static double? debtProgress({
    required int? initialAmount,
    required int currentBalance,
  }) {
    if (initialAmount == null || initialAmount <= 0) return null;
    final progress = (initialAmount - currentBalance) / initialAmount;
    return progress.clamp(0.0, 1.0);
  }

  /// 원리금 분리: 총 납부액에서 원금/이자를 분리
  /// [totalPayment]: 원리금 (사용자 입력)
  /// [currentBalance]: 현재 잔액
  /// [annualRate]: 연 이자율 (%)
  /// 반환: { 'principal': 원금, 'interest': 이자 }
  static Map<String, int> splitPrincipalInterest({
    required int totalPayment,
    required int currentBalance,
    required double annualRate,
  }) {
    if (annualRate <= 0) {
      return {'principal': totalPayment, 'interest': 0};
    }

    final monthlyRate = annualRate / 12 / 100;
    final interest = (currentBalance * monthlyRate).round();
    final principal = (totalPayment - interest).clamp(0, totalPayment);

    return {'principal': principal, 'interest': totalPayment - principal};
  }

  /// 전체 빚 진행률
  static double? overallProgress({
    required List<int?> initialAmounts,
    required List<int> currentBalances,
  }) {
    int totalInitial = 0;
    int totalCurrent = 0;
    bool hasAny = false;

    for (int i = 0; i < initialAmounts.length; i++) {
      if (initialAmounts[i] != null && initialAmounts[i]! > 0) {
        totalInitial += initialAmounts[i]!;
        totalCurrent += currentBalances[i];
        hasAny = true;
      }
    }

    if (!hasAny || totalInitial == 0) return null;
    return ((totalInitial - totalCurrent) / totalInitial).clamp(0.0, 1.0);
  }
}

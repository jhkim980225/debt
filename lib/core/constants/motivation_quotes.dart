import 'dart:math';

/// 동기부여 카피 풀
class MotivationQuotes {
  MotivationQuotes._();

  static final _random = Random();

  /// 대시보드 상단 카피 (짧고 따뜻한)
  static const List<String> dashboardQuotes = [
    '오늘도 한 걸음씩, 천천히 가요',
    '어제보다 가까워지고 있어요',
    '함께 가요, 멈추지 말고',
    '꾸준함이 가장 빠른 길이에요',
    '작은 한 걸음이 큰 변화를 만들어요',
    '오늘의 노력이 내일의 자유예요',
    '지금 이 순간도 진전이에요',
    '당신의 페이스로 충분해요',
    '매일 조금씩, 반드시 도착해요',
    '포기하지 않는 것이 가장 큰 힘이에요',
    '자유는 한 걸음씩 가까워져요',
    '오늘 하루도 잘하고 있어요',
    '천천히, 하지만 멈추지 말고',
    '빚은 줄고, 자유는 늘고',
    '오늘의 선택이 미래를 만들어요',
    '조금씩 가벼워지고 있어요',
    '꾸준함을 선택한 당신, 멋져요',
    '어제보다 더 가벼운 오늘이에요',
    '매 걸음이 의미 있어요',
    '오늘도 한 뼘씩 자유에 가까이',
  ];

  /// 상환 기록 인용구 (시적, 감성)
  static const List<String> paymentQuotes = [
    '오늘의 선택이 미래를 만들어요.',
    '한 걸음 한 걸음, 자유에 가까워지고 있어요.',
    '작은 물방울이 바위를 뚫듯이.',
    '매일의 기록이 내일의 자유가 돼요.',
    '오늘 갚은 만큼, 마음도 가벼워져요.',
  ];

  /// 랜덤 대시보드 카피
  static String randomDashboardQuote() {
    return dashboardQuotes[_random.nextInt(dashboardQuotes.length)];
  }

  /// 랜덤 상환 인용구
  static String randomPaymentQuote() {
    return paymentQuotes[_random.nextInt(paymentQuotes.length)];
  }

  /// 상황 기반 대시보드 카피
  static String situationalQuote({
    required int streakDays,
    String? upcomingDebtName,
    int? daysUntilPayment,
    bool isNewMonth = false,
    String? graduatedDebtName,
  }) {
    if (graduatedDebtName != null) {
      return '$graduatedDebtName 졸업 축하해요! 다음 목표로!';
    }
    if (isNewMonth) {
      final now = DateTime.now();
      return '${now.month}월의 첫 걸음을 떼볼까요?';
    }
    if (upcomingDebtName != null && daysUntilPayment != null && daysUntilPayment <= 3) {
      return '$upcomingDebtName 결제일이 $daysUntilPayment일 남았어요';
    }
    if (streakDays >= 7) {
      return '$streakDays일째 함께하고 있어요. 멋져요!';
    }
    return randomDashboardQuote();
  }
}

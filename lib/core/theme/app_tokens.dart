/// 간격, 모서리, 애니메이션 토큰 (docs/design-system.md 참조)
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// 화면 좌우 패딩
  static const double screenPadding = 20;
}

class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;
}

class AppDuration {
  AppDuration._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

class AppShadow {
  AppShadow._();
  // 대부분 그림자 없이 보더로 깊이 표현, 모달/드롭다운에만 사용
}

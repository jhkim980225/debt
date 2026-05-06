import 'package:flutter/material.dart';

/// 앱 전체 컬러 팔레트 (docs/design-system.md 참조)
class AppColors {
  AppColors._();

  // 기본 (Surface)
  static const Color background = Color(0xFFFAFAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF5F5F4);
  static const Color surfaceTertiary = Color(0xFFF0EFEA);

  // 텍스트
  static const Color textPrimary = Color(0xFF1C1B1A);
  static const Color textSecondary = Color(0xFF6B6967);
  static const Color textTertiary = Color(0xFF9C9A97);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // 보더
  static const Color borderLight = Color(0xFFE8E6E3);
  static const Color borderMedium = Color(0xFFD4D2CF);

  // 성공/진전 (녹색)
  static const Color success = Color(0xFF0F6E56);
  static const Color successLight = Color(0xFFE1F5EE);
  static const Color successAccent = Color(0xFF97C459);
  static const Color successDark = Color(0xFF04342C);

  // 위험/경고 (빨강)
  static const Color danger = Color(0xFFE24B4A);
  static const Color dangerLight = Color(0xFFFCEBEB);
  static const Color dangerDark = Color(0xFF791F1F);

  // 정보 (파랑)
  static const Color info = Color(0xFF185FA5);
  static const Color infoLight = Color(0xFFE6F1FB);
  static const Color infoMedium = Color(0xFFB5D4F4);
  static const Color infoDark = Color(0xFF0C447C);

  // 액센트 (주황)
  static const Color accent = Color(0xFFBA7517);
  static const Color accentLight = Color(0xFFFAEEDA);
  static const Color accentMedium = Color(0xFFFAC775);
  static const Color accentDark = Color(0xFF633806);

  // 보라
  static const Color purple = Color(0xFF534AB7);
  static const Color purpleLight = Color(0xFFEEEDFE);
  static const Color purpleMedium = Color(0xFFCECBF6);
  static const Color purpleDark = Color(0xFF3C3489);

  // 핑크
  static const Color pink = Color(0xFFD4537E);
  static const Color pinkLight = Color(0xFFFBEAF0);
  static const Color pinkMedium = Color(0xFFF4C0D1);
  static const Color pinkDark = Color(0xFF72243E);

  // 소셜 로그인 브랜드
  static const Color kakao = Color(0xFFFEE500);
  static const Color naver = Color(0xFF03C75A);
  static const Color apple = Color(0xFF000000);
  static const Color google = Color(0xFFFFFFFF);
}

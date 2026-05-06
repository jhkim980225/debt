import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 빚 카테고리 정의
enum DebtCategory {
  creditCard,
  studentLoan,
  bankLoan,
  personal,
  installment,
  other;

  /// 한글 표시명
  String get displayName {
    switch (this) {
      case DebtCategory.creditCard:
        return '신용카드';
      case DebtCategory.studentLoan:
        return '학자금';
      case DebtCategory.bankLoan:
        return '은행대출';
      case DebtCategory.personal:
        return '지인';
      case DebtCategory.installment:
        return '할부';
      case DebtCategory.other:
        return '기타';
    }
  }

  /// 카테고리별 색상
  Color get color {
    switch (this) {
      case DebtCategory.creditCard:
        return AppColors.danger;
      case DebtCategory.studentLoan:
        return AppColors.accent;
      case DebtCategory.bankLoan:
        return AppColors.success;
      case DebtCategory.personal:
        return AppColors.purple;
      case DebtCategory.installment:
        return AppColors.pink;
      case DebtCategory.other:
        return AppColors.textSecondary;
    }
  }

  /// 카테고리별 아이콘
  IconData get icon {
    switch (this) {
      case DebtCategory.creditCard:
        return Icons.credit_card;
      case DebtCategory.studentLoan:
        return Icons.school;
      case DebtCategory.bankLoan:
        return Icons.account_balance;
      case DebtCategory.personal:
        return Icons.people;
      case DebtCategory.installment:
        return Icons.shopping_bag;
      case DebtCategory.other:
        return Icons.add;
    }
  }

  /// 카테고리별 평균 이자율 (잘 모르겠어요 용)
  double get averageInterestRate {
    switch (this) {
      case DebtCategory.creditCard:
        return 18.9;
      case DebtCategory.studentLoan:
        return 4.5;
      case DebtCategory.bankLoan:
        return 6.5;
      case DebtCategory.personal:
        return 0;
      case DebtCategory.installment:
        return 0;
      case DebtCategory.other:
        return 5;
    }
  }

  /// 카테고리별 플레이스홀더
  String get placeholder {
    switch (this) {
      case DebtCategory.creditCard:
        return '예: 신용카드 A';
      case DebtCategory.studentLoan:
        return '예: 학자금 2학기';
      case DebtCategory.bankLoan:
        return '예: 주택담보대출';
      case DebtCategory.personal:
        return '예: 친구 빌린 돈';
      case DebtCategory.installment:
        return '예: 노트북 할부';
      case DebtCategory.other:
        return '예: 기타 빚';
    }
  }
}

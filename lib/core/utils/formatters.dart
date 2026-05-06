import 'package:intl/intl.dart';

/// 금액/날짜 포맷 유틸리티
class AppFormatters {
  AppFormatters._();

  static final _numberFormat = NumberFormat('#,###');
  static final _dateFormat = DateFormat('M월 d일');
  static final _fullDateFormat = DateFormat('yyyy년 M월 d일');
  static final _yearMonthFormat = DateFormat('yyyy년 M월');

  /// 천단위 콤마 금액 (예: 1,234,567)
  static String amount(int value) {
    return _numberFormat.format(value);
  }

  /// 금액 + 원 (예: 1,234,567원)
  static String amountWon(int value) {
    return '${amount(value)}원';
  }

  /// 만원 단위 표시 (예: 1,234만원)
  static String amountManWon(int value) {
    if (value >= 10000) {
      final man = value ~/ 10000;
      return '${_numberFormat.format(man)}만원';
    }
    return amountWon(value);
  }

  /// 금액 범위 표시 (커뮤니티용, 예: 1000만원대)
  static String amountRange(int value) {
    if (value < 1000000) return '100만원 미만';
    if (value < 10000000) return '${value ~/ 1000000 * 100}만원대';
    if (value < 100000000) return '${value ~/ 10000000 * 1000}만원대';
    return '1억원 이상';
  }

  /// 날짜 (예: 5월 1일)
  static String date(DateTime date) {
    return _dateFormat.format(date);
  }

  /// 전체 날짜 (예: 2025년 5월 1일)
  static String fullDate(DateTime date) {
    return _fullDateFormat.format(date);
  }

  /// 년월 (예: 2025년 5월)
  static String yearMonth(DateTime date) {
    return _yearMonthFormat.format(date);
  }

  /// 이자율 (예: 18.9%)
  static String interestRate(double rate) {
    if (rate == rate.toInt().toDouble()) {
      return '${rate.toInt()}%';
    }
    return '${rate.toStringAsFixed(1)}%';
  }

  /// 진행률 (예: 42%)
  static String progress(double ratio) {
    return '${(ratio * 100).toInt()}%';
  }

  /// 숫자 입력 시 천단위 콤마 변환 (입력 필드용)
  static String formatInput(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '';
    final value = int.tryParse(digitsOnly);
    if (value == null) return digitsOnly;
    return _numberFormat.format(value);
  }

  /// 콤마 제거하여 숫자로 변환
  static int? parseAmount(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return null;
    return int.tryParse(digitsOnly);
  }
}

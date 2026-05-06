import 'package:hive/hive.dart';

part 'debt_model.g.dart';

@HiveType(typeId: 1)
class DebtModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String category; // creditCard, studentLoan, bankLoan, personal, installment, other

  @HiveField(4)
  int? initialAmount;

  @HiveField(5)
  int currentBalance;

  @HiveField(6)
  double interestRate;

  @HiveField(7)
  int? minimumPayment;

  @HiveField(8)
  int? targetPayment;

  @HiveField(9)
  int? paymentDay; // 1-31 또는 -1(말일)

  @HiveField(10)
  String notificationTiming; // threeDaysBefore, sameDay, none

  @HiveField(11)
  bool isPaidOff;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  DateTime? paidOffAt;

  @HiveField(14)
  int priority;

  @HiveField(15)
  int? loanTermMonths; // 대출 기간 (개월 단위)

  DebtModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.initialAmount,
    required this.currentBalance,
    this.interestRate = 0,
    this.minimumPayment,
    this.targetPayment,
    this.paymentDay,
    this.notificationTiming = 'threeDaysBefore',
    this.isPaidOff = false,
    required this.createdAt,
    this.paidOffAt,
    this.priority = 0,
    this.loanTermMonths,
  });
}

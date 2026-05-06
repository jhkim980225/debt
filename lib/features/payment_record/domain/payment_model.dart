import 'package:hive/hive.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 2)
class PaymentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String debtId;

  @HiveField(3)
  final int amount;

  @HiveField(4)
  final DateTime paidAt;

  @HiveField(5)
  String? note;

  @HiveField(6)
  final bool isExtra;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final int balanceBefore;

  @HiveField(9)
  final int balanceAfter;

  @HiveField(10)
  final int? principalAmount;

  @HiveField(11)
  final int? interestAmount;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.debtId,
    required this.amount,
    this.principalAmount,
    this.interestAmount,
    required this.paidAt,
    this.note,
    this.isExtra = false,
    required this.createdAt,
    required this.balanceBefore,
    required this.balanceAfter,
  });
}

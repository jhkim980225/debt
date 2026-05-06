import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/payment_model.dart';

/// Supabase 기반 상환 기록 저장소
class PaymentRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// 특정 빚의 상환 기록
  Future<List<PaymentModel>> getPaymentsForDebt(String debtId) async {
    final data = await _client
        .from('payments')
        .select()
        .eq('debt_id', debtId)
        .order('paid_at', ascending: false);

    return data.map((p) => _fromMap(p)).toList();
  }

  /// 사용자 전체 상환 기록
  Future<List<PaymentModel>> getAllPayments(String userId) async {
    final data = await _client
        .from('payments')
        .select()
        .eq('user_id', userId)
        .order('paid_at', ascending: false);

    return data.map((p) => _fromMap(p)).toList();
  }

  /// 상환 기록 추가
  Future<void> addPayment(PaymentModel payment) async {
    await _client.from('payments').insert({
      'id': payment.id,
      'user_id': payment.userId,
      'debt_id': payment.debtId,
      'amount': payment.amount,
      'principal_amount': payment.principalAmount,
      'interest_amount': payment.interestAmount,
      'paid_at': payment.paidAt.toIso8601String(),
      'note': payment.note,
      'is_extra': payment.isExtra,
      'balance_before': payment.balanceBefore,
      'balance_after': payment.balanceAfter,
    });
  }

  /// 특정 날짜의 상환 기록 존재 여부 (연속 기록용)
  Future<bool> hasPaymentOnDate(String userId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final data = await _client
        .from('payments')
        .select('id')
        .eq('user_id', userId)
        .gte('paid_at', start.toIso8601String())
        .lt('paid_at', end.toIso8601String())
        .limit(1);

    return data.isNotEmpty;
  }

  /// 이번 달 총 상환 금액
  Future<int> getMonthlyTotal(String userId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);

    final data = await _client
        .from('payments')
        .select('amount')
        .eq('user_id', userId)
        .gte('paid_at', start.toIso8601String());

    return data.fold<int>(0, (sum, p) => sum + (p['amount'] as int));
  }

  /// 누적 총 상환 금액
  Future<int> getTotalPaid(String userId) async {
    final data = await _client
        .from('payments')
        .select('amount')
        .eq('user_id', userId);

    return data.fold<int>(0, (sum, p) => sum + (p['amount'] as int));
  }

  PaymentModel _fromMap(Map<String, dynamic> p) {
    return PaymentModel(
      id: p['id'],
      userId: p['user_id'],
      debtId: p['debt_id'],
      amount: p['amount'],
      principalAmount: p['principal_amount'],
      interestAmount: p['interest_amount'],
      paidAt: DateTime.parse(p['paid_at']),
      note: p['note'],
      isExtra: p['is_extra'] ?? false,
      createdAt: DateTime.parse(p['created_at']),
      balanceBefore: p['balance_before'],
      balanceAfter: p['balance_after'],
    );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/debt_model.dart';

/// Supabase 기반 빚 저장소
class DebtRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// 모든 빚 목록
  Future<List<DebtModel>> getAllDebts(String userId) async {
    final data = await _client
        .from('debts')
        .select()
        .eq('user_id', userId)
        .order('priority');

    return data.map((d) => _fromMap(d)).toList();
  }

  /// 활성 빚 목록 (졸업 안 한)
  Future<List<DebtModel>> getActiveDebts(String userId) async {
    final data = await _client
        .from('debts')
        .select()
        .eq('user_id', userId)
        .eq('is_paid_off', false)
        .order('priority');

    return data.map((d) => _fromMap(d)).toList();
  }

  /// 빚 추가
  Future<void> addDebt(DebtModel debt) async {
    await _client.from('debts').insert(_toMap(debt));
  }

  /// 빚 수정
  Future<void> updateDebt(DebtModel debt) async {
    await _client.from('debts').update(_toMap(debt)).eq('id', debt.id);
  }

  /// 빚 삭제
  Future<void> deleteDebt(String debtId) async {
    await _client.from('debts').delete().eq('id', debtId);
  }

  /// 빚 조회
  Future<DebtModel?> getDebt(String debtId) async {
    final data = await _client
        .from('debts')
        .select()
        .eq('id', debtId)
        .maybeSingle();

    return data != null ? _fromMap(data) : null;
  }

  /// 빚 개수
  Future<int> getDebtCount(String userId) async {
    final data = await _client
        .from('debts')
        .select('id')
        .eq('user_id', userId);

    return data.length;
  }

  DebtModel _fromMap(Map<String, dynamic> d) {
    return DebtModel(
      id: d['id'],
      userId: d['user_id'],
      name: d['name'],
      category: d['category'],
      initialAmount: d['initial_amount'],
      currentBalance: d['current_balance'],
      interestRate: (d['interest_rate'] as num).toDouble(),
      minimumPayment: d['minimum_payment'],
      targetPayment: d['target_payment'],
      paymentDay: d['payment_day'],
      notificationTiming: d['notification_timing'] ?? 'threeDaysBefore',
      isPaidOff: d['is_paid_off'] ?? false,
      createdAt: DateTime.parse(d['created_at']),
      paidOffAt: d['paid_off_at'] != null ? DateTime.parse(d['paid_off_at']) : null,
      priority: d['priority'] ?? 0,
      loanTermMonths: d['loan_term_months'],
    );
  }

  Map<String, dynamic> _toMap(DebtModel debt) {
    final map = {
      'id': debt.id,
      'user_id': debt.userId,
      'name': debt.name,
      'category': debt.category,
      'initial_amount': debt.initialAmount,
      'current_balance': debt.currentBalance,
      'interest_rate': debt.interestRate,
      'minimum_payment': debt.minimumPayment,
      'target_payment': debt.targetPayment,
      'payment_day': debt.paymentDay,
      'notification_timing': debt.notificationTiming,
      'is_paid_off': debt.isPaidOff,
      'paid_off_at': debt.paidOffAt?.toIso8601String(),
      'priority': debt.priority,
    };
    // TODO: Supabase 마이그레이션 적용 후 아래 주석 해제
    // map['loan_term_months'] = debt.loanTermMonths;
    return map;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/user_model.dart';
import '../features/debt_register/data/debt_repository.dart';
import '../features/debt_register/domain/debt_model.dart';
import '../features/payment_record/data/payment_repository.dart';
import '../features/payment_record/domain/payment_model.dart';
import '../features/badges/data/badge_repository.dart';
import '../features/badges/domain/badge_model.dart';

// Repository 프로바이더
final authRepositoryProvider = Provider((ref) => AuthRepository());
final debtRepositoryProvider = Provider((ref) => DebtRepository());
final paymentRepositoryProvider = Provider((ref) => PaymentRepository());
final badgeRepositoryProvider = Provider((ref) => BadgeRepository());

// 현재 사용자
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  return CurrentUserNotifier(ref.read(authRepositoryProvider));
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _authRepo;

  CurrentUserNotifier(this._authRepo) : super(null);

  Future<void> loadUser() async {
    state = await _authRepo.getCurrentUser();
  }

  void setUser(UserModel user) {
    state = user;
  }

  Future<void> logout() async {
    await _authRepo.logout();
    state = null;
  }

  Future<void> updateStreak(int newStreak) async {
    if (state == null) return;
    state!.streakCount = newStreak;
    if (newStreak > state!.longestStreak) {
      state!.longestStreak = newStreak;
    }
    await _authRepo.updateUser(state!);
    state = UserModel(
      id: state!.id,
      email: state!.email,
      displayName: state!.displayName,
      profileImageUrl: state!.profileImageUrl,
      authProvider: state!.authProvider,
      createdAt: state!.createdAt,
      lastLoginAt: state!.lastLoginAt,
      totalDaysActive: state!.totalDaysActive,
      streakCount: newStreak,
      longestStreak: state!.longestStreak,
      strategy: state!.strategy,
      monthlyBudget: state!.monthlyBudget,
    );
  }
}

// 빚 목록
final debtListProvider =
    StateNotifierProvider<DebtListNotifier, List<DebtModel>>((ref) {
  return DebtListNotifier(ref.read(debtRepositoryProvider));
});

class DebtListNotifier extends StateNotifier<List<DebtModel>> {
  final DebtRepository _debtRepo;

  DebtListNotifier(this._debtRepo) : super([]);

  Future<void> loadDebts(String userId) async {
    state = await _debtRepo.getActiveDebts(userId);
  }

  Future<void> addDebt(DebtModel debt) async {
    await _debtRepo.addDebt(debt);
    state = [...state, debt];
  }

  /// Supabase 실패 시 로컬 상태에만 추가
  void addDebtLocal(DebtModel debt) {
    state = [...state, debt];
  }

  Future<void> updateDebt(DebtModel debt) async {
    await _debtRepo.updateDebt(debt);
    state = state.map((d) => d.id == debt.id ? debt : d).toList();
  }

  Future<void> removeDebt(String debtId) async {
    await _debtRepo.deleteDebt(debtId);
    state = state.where((d) => d.id != debtId).toList();
  }

  /// 전략 기반 정렬
  void sortByStrategy(String strategy) {
    final sorted = [...state];
    if (strategy == 'snowball') {
      sorted.sort((a, b) => a.currentBalance.compareTo(b.currentBalance));
    } else {
      sorted.sort((a, b) => b.interestRate.compareTo(a.interestRate));
    }
    // 우선순위 갱신
    for (int i = 0; i < sorted.length; i++) {
      sorted[i].priority = i;
    }
    state = sorted;
  }
}

// 상환 기록
final paymentListProvider =
    StateNotifierProvider<PaymentListNotifier, List<PaymentModel>>((ref) {
  return PaymentListNotifier(ref.read(paymentRepositoryProvider));
});

class PaymentListNotifier extends StateNotifier<List<PaymentModel>> {
  final PaymentRepository _paymentRepo;

  PaymentListNotifier(this._paymentRepo) : super([]);

  Future<void> loadPayments(String userId) async {
    state = await _paymentRepo.getAllPayments(userId);
  }

  Future<void> addPayment(PaymentModel payment) async {
    await _paymentRepo.addPayment(payment);
    state = [payment, ...state];
  }
}

// 배지 목록
final badgeListProvider =
    StateNotifierProvider<BadgeListNotifier, List<BadgeModel>>((ref) {
  return BadgeListNotifier(ref.read(badgeRepositoryProvider));
});

class BadgeListNotifier extends StateNotifier<List<BadgeModel>> {
  final BadgeRepository _badgeRepo;

  BadgeListNotifier(this._badgeRepo) : super([]);

  Future<void> loadBadges(String userId) async {
    state = await _badgeRepo.getUserBadges(userId);
  }

  Future<BadgeModel> earnBadge(String badgeId, String userId) async {
    final badge = await _badgeRepo.earnBadge(
      badgeId: badgeId,
      userId: userId,
    );
    if (!state.any((b) => b.id == badgeId)) {
      state = [badge, ...state];
    }
    return badge;
  }
}

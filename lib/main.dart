import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_config.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/debt_register/data/debt_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // 온보딩 완료 여부 확인
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

  // 초기 로그인 상태 확인
  final authRepo = AuthRepository();
  final isLoggedIn = await authRepo.isLoggedIn();
  bool hasDebts = false;

  if (isLoggedIn) {
    final user = await authRepo.getCurrentUser();
    if (user != null) {
      final debtRepo = DebtRepository();
      final count = await debtRepo.getDebtCount(user.id);
      hasDebts = count > 0;
    }
  }

  runApp(
    ProviderScope(
      child: DebtFreeApp(
        isLoggedIn: isLoggedIn,
        hasDebts: hasDebts,
        onboardingCompleted: onboardingCompleted,
      ),
    ),
  );
}

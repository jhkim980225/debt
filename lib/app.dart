import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/strings.dart';
import 'routes/app_router.dart';


/// 앱 루트 위젯
class DebtFreeApp extends ConsumerWidget {
  final bool isLoggedIn;
  final bool hasDebts;
  final bool onboardingCompleted;

  const DebtFreeApp({
    super.key,
    required this.isLoggedIn,
    required this.hasDebts,
    this.onboardingCompleted = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter.router(
      isLoggedIn: isLoggedIn && onboardingCompleted,
      hasDebts: hasDebts,
    );

    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

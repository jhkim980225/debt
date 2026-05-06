import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/email_signup_screen.dart';
import '../features/auth/presentation/password_reset_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/debt_register/presentation/debt_register_step1_screen.dart';
import '../features/debt_register/presentation/debt_register_step2_screen.dart';
import '../features/debt_register/presentation/debt_register_complete_screen.dart';
import '../features/dashboard/presentation/home_shell.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/debt_register/presentation/debt_detail_screen.dart';
import '../features/statistics/presentation/statistics_screen.dart';
import '../features/badges/presentation/badges_screen.dart';
import '../features/community/presentation/community_screen.dart';
import '../features/community/presentation/post_detail_screen.dart';
import '../features/community/presentation/write_post_screen.dart';
import '../features/simulation/presentation/simulation_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/profile_screen.dart';

/// 앱 라우팅 설정
class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router({required bool isLoggedIn, required bool hasDebts}) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: isLoggedIn ? (hasDebts ? '/home' : '/debt/add') : '/onboarding',
      routes: [
        // 온보딩
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),

        // 인증
        GoRoute(
          path: '/auth/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/auth/email-signup',
          builder: (context, state) => const EmailSignupScreen(),
        ),
        GoRoute(
          path: '/auth/reset-password',
          builder: (context, state) => const PasswordResetScreen(),
        ),

        // 빚 등록
        GoRoute(
          path: '/debt/add',
          builder: (context, state) => const DebtRegisterStep1Screen(),
        ),
        GoRoute(
          path: '/debt/add/step2',
          builder: (context, state) => const DebtRegisterStep2Screen(),
        ),
        GoRoute(
          path: '/debt/add/complete',
          builder: (context, state) => const DebtRegisterCompleteScreen(),
        ),

        // 빚 상세
        GoRoute(
          path: '/debt/:id',
          builder: (context, state) => DebtDetailScreen(
            debtId: state.pathParameters['id']!,
          ),
        ),

        // 시뮬레이션
        GoRoute(
          path: '/simulation',
          builder: (context, state) => const SimulationScreen(),
        ),

        // 설정
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/settings/profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        // 커뮤니티
        GoRoute(
          path: '/community/write',
          builder: (context, state) => const WritePostScreen(),
        ),
        GoRoute(
          path: '/community/post/:id',
          builder: (context, state) => PostDetailScreen(
            postId: state.pathParameters['id']!,
          ),
        ),

        // 홈 (탭 네비게이션)
        ShellRoute(
          builder: (context, state, child) => HomeShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/home/stats',
              builder: (context, state) => const StatisticsScreen(),
            ),
            GoRoute(
              path: '/home/badges',
              builder: (context, state) => const BadgesScreen(),
            ),
            GoRoute(
              path: '/home/community',
              builder: (context, state) => const CommunityScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

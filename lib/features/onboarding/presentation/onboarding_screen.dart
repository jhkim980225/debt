import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';

/// 온보딩 슬라이드 데이터
class _OnboardingSlide {
  final IconData icon;
  final String headline;
  final String subCopy;

  const _OnboardingSlide({
    required this.icon,
    required this.headline,
    required this.subCopy,
  });
}

const _slides = [
  _OnboardingSlide(
    icon: Icons.route_outlined,
    headline: '빚, 혼자 갚지 마세요',
    subCopy: '함께 계획하고, 매일 응원받으며,\n한 걸음씩 자유에 가까워져요.',
  ),
  _OnboardingSlide(
    icon: Icons.dashboard_outlined,
    headline: '한눈에 보이는 내 빚',
    subCopy: '전체 그림이 보이면 막막함이 사라져요.\n진행률, 예상 완납일까지 한 화면에.',
  ),
  _OnboardingSlide(
    icon: Icons.calendar_today_outlined,
    headline: '매일 작은 진전',
    subCopy: '꾸준함이 가장 큰 힘이에요.\n매일의 한 걸음을 응원해줄게요.',
  ),
  _OnboardingSlide(
    icon: Icons.people_outline,
    headline: '혼자가 아니에요',
    subCopy: '비슷한 여정에 있는 사람들과\n정보를 나누고 응원받아요.',
  ),
];

/// 온보딩 화면
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 상단: 건너뛰기
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _slides.length - 1)
                    GestureDetector(
                      onTap: _skip,
                      child: Text(
                        '건너뛰기',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 슬라이드
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 일러스트 (아이콘 대체)
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.successLight,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 56,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        Text(
                          slide.headline,
                          style: AppTypography.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          slide.subCopy,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 하단: 인디케이터 + 버튼
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  // 점 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.borderMedium,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // 메인 버튼
                  AppPrimaryButton(
                    text: _currentPage == _slides.length - 1
                        ? '시작하기'
                        : '다음',
                    onPressed: _next,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 보조 텍스트
                  GestureDetector(
                    onTap: () => context.go('/auth/login'),
                    child: Text(
                      '이미 계정이 있어요',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: AppDuration.normal,
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _skip() {
    _complete();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
    if (mounted) {
      context.go('/auth/signup');
    }
  }
}

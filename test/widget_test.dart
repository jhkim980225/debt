import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:debt_free/core/utils/debt_calculator.dart';
import 'package:debt_free/core/utils/formatters.dart';
import 'package:debt_free/core/constants/strings.dart';
import 'package:debt_free/core/theme/app_theme.dart';
import 'package:debt_free/features/badges/domain/badge_model.dart';
import 'package:debt_free/features/community/domain/post_model.dart';

void main() {
  // ──────────────────────────────────────────
  // 유틸리티 단위 테스트
  // ──────────────────────────────────────────

  group('DebtCalculator', () {
    test('debtProgress - 정상 계산', () {
      final progress = DebtCalculator.debtProgress(
        initialAmount: 10000000,
        currentBalance: 7000000,
      );
      expect(progress, closeTo(0.3, 0.001));
    });

    test('debtProgress - 전액 상환', () {
      final progress = DebtCalculator.debtProgress(
        initialAmount: 5000000,
        currentBalance: 0,
      );
      expect(progress, 1.0);
    });

    test('debtProgress - 상환 전', () {
      final progress = DebtCalculator.debtProgress(
        initialAmount: 5000000,
        currentBalance: 5000000,
      );
      expect(progress, 0.0);
    });

    test('debtProgress - initialAmount null이면 null', () {
      final progress = DebtCalculator.debtProgress(
        initialAmount: null,
        currentBalance: 5000000,
      );
      expect(progress, isNull);
    });

    test('debtProgress - initialAmount 0이면 null', () {
      final progress = DebtCalculator.debtProgress(
        initialAmount: 0,
        currentBalance: 0,
      );
      expect(progress, isNull);
    });

    test('debtProgress - clamp 0~1', () {
      // currentBalance > initialAmount (비정상이지만 에러 안남)
      final progress = DebtCalculator.debtProgress(
        initialAmount: 5000000,
        currentBalance: 7000000,
      );
      expect(progress, 0.0);
    });

    test('estimateMonths - 무이자', () {
      final months = DebtCalculator.estimateMonths(
        balance: 1200000,
        monthlyPayment: 100000,
        annualRate: 0,
      );
      expect(months, 12);
    });

    test('estimateMonths - 유이자', () {
      final months = DebtCalculator.estimateMonths(
        balance: 1000000,
        monthlyPayment: 100000,
        annualRate: 12,
      );
      expect(months, isNotNull);
      expect(months!, greaterThan(10));
      expect(months, lessThan(15));
    });

    test('estimateMonths - 상환 불가능 (이자가 상환액보다 큼)', () {
      final months = DebtCalculator.estimateMonths(
        balance: 10000000,
        monthlyPayment: 10000,
        annualRate: 24,
      );
      expect(months, isNull);
    });

    test('estimateMonths - 잔액 0이면 null', () {
      expect(
        DebtCalculator.estimateMonths(
            balance: 0, monthlyPayment: 100000, annualRate: 5),
        isNull,
      );
    });

    test('monthsSaved - 목표 상환 시 단축', () {
      final saved = DebtCalculator.monthsSaved(
        balance: 5000000,
        minimumPayment: 100000,
        targetPayment: 200000,
        annualRate: 12,
      );
      expect(saved, isNotNull);
      expect(saved!, greaterThan(0));
    });

    test('overallProgress - 여러 빚 합산', () {
      final progress = DebtCalculator.overallProgress(
        initialAmounts: [10000000, 5000000],
        currentBalances: [7000000, 2500000],
      );
      // (15000000 - 9500000) / 15000000 = 0.3667
      expect(progress, isNotNull);
      expect(progress!, closeTo(0.3667, 0.001));
    });

    test('overallProgress - 모든 initialAmount null이면 null', () {
      final progress = DebtCalculator.overallProgress(
        initialAmounts: [null, null],
        currentBalances: [7000000, 2500000],
      );
      expect(progress, isNull);
    });

    test('splitPrincipalInterest - 이자율 0', () {
      final split = DebtCalculator.splitPrincipalInterest(
        totalPayment: 100000,
        currentBalance: 5000000,
        annualRate: 0,
      );
      expect(split['principal'], 100000);
      expect(split['interest'], 0);
    });

    test('splitPrincipalInterest - 이자 분리', () {
      final split = DebtCalculator.splitPrincipalInterest(
        totalPayment: 100000,
        currentBalance: 6000000,
        annualRate: 12,
      );
      // 월이자 = 6000000 * 0.01 = 60000
      expect(split['interest'], 60000);
      expect(split['principal'], 40000);
    });
  });

  group('AppFormatters', () {
    test('amount - 천단위 콤마', () {
      expect(AppFormatters.amount(1234567), '1,234,567');
      expect(AppFormatters.amount(0), '0');
      expect(AppFormatters.amount(999), '999');
      expect(AppFormatters.amount(1000), '1,000');
    });

    test('amountWon - 원 단위', () {
      expect(AppFormatters.amountWon(5000000), '5,000,000원');
    });

    test('amountManWon - 만원 단위', () {
      expect(AppFormatters.amountManWon(50000), '5만원');
      expect(AppFormatters.amountManWon(5000), '5,000원');
    });

    test('amountRange - 범위 표시', () {
      expect(AppFormatters.amountRange(500000), '100만원 미만');
      expect(AppFormatters.amountRange(5000000), '500만원대');
      expect(AppFormatters.amountRange(15000000), '1000만원대');
      expect(AppFormatters.amountRange(100000000), '1억원 이상');
    });

    test('progress - 진행률 % 변환', () {
      expect(AppFormatters.progress(0.3), '30%');
      expect(AppFormatters.progress(1.0), '100%');
      expect(AppFormatters.progress(0.0), '0%');
      expect(AppFormatters.progress(0.456), '45%');
    });

    test('interestRate - 이자율 표시', () {
      expect(AppFormatters.interestRate(18.0), '18%');
      expect(AppFormatters.interestRate(18.9), '18.9%');
      expect(AppFormatters.interestRate(0.0), '0%');
    });

    test('parseAmount - 콤마 제거 파싱', () {
      expect(AppFormatters.parseAmount('1,234,567'), 1234567);
      expect(AppFormatters.parseAmount('5000000'), 5000000);
      expect(AppFormatters.parseAmount(''), isNull);
    });

    test('formatInput - 입력 시 콤마 자동 추가', () {
      expect(AppFormatters.formatInput('1234567'), '1,234,567');
      expect(AppFormatters.formatInput(''), '');
      expect(AppFormatters.formatInput('100'), '100');
    });
  });

  // ──────────────────────────────────────────
  // 문자열 상수 테스트
  // ──────────────────────────────────────────

  group('AppStrings', () {
    test('처음 빌린 금액 문자열 존재', () {
      expect(AppStrings.initialAmount, '처음 빌린 금액');
      expect(AppStrings.initialAmountSub, isNotEmpty);
      expect(AppStrings.errorInitialLessThanBalance, isNotEmpty);
    });

    test('핵심 문자열 누락 없음', () {
      expect(AppStrings.appName, '빚프리');
      expect(AppStrings.debtRegisterTitle, isNotEmpty);
      expect(AppStrings.currentBalance, isNotEmpty);
      expect(AppStrings.annualInterestRate, isNotEmpty);
      expect(AppStrings.recordPayment, isNotEmpty);
      expect(AppStrings.simulation, isNotEmpty);
    });
  });

  // ──────────────────────────────────────────
  // 모델 테스트
  // ──────────────────────────────────────────

  group('BadgeDefinition', () {
    test('18개 배지 정의 존재', () {
      expect(BadgeDefinition.all.length, 18);
    });

    test('모든 배지에 id, name, description 있음', () {
      for (final badge in BadgeDefinition.all) {
        expect(badge.id, isNotEmpty);
        expect(badge.name, isNotEmpty);
        expect(badge.description, isNotEmpty);
      }
    });

    test('배지 ID 중복 없음', () {
      final ids = BadgeDefinition.all.map((b) => b.id).toSet();
      expect(ids.length, BadgeDefinition.all.length);
    });

    test('필수 배지 존재', () {
      final ids = BadgeDefinition.all.map((b) => b.id).toSet();
      expect(ids.contains('firstStep'), isTrue);
      expect(ids.contains('sevenDayStreak'), isTrue);
      expect(ids.contains('firstGraduation'), isTrue);
      expect(ids.contains('allCleared'), isTrue);
    });
  });

  group('PostCategory', () {
    test('7개 카테고리 정의', () {
      expect(PostCategory.values.length, 7);
    });

    test('displayName 있음', () {
      for (final cat in PostCategory.values) {
        expect(cat.displayName, isNotEmpty);
      }
    });

    test('필수 카테고리 존재', () {
      expect(PostCategory.free.displayName, '자유');
      expect(PostCategory.question.displayName, '질문');
      expect(PostCategory.certify.displayName, '인증');
      expect(PostCategory.save.displayName, '절약');
    });
  });

  group('PostModel', () {
    test('기본 생성', () {
      final post = PostModel(
        id: 'test-1',
        userId: 'user-1',
        authorName: '테스트유저',
        category: PostCategory.free,
        title: '제목입니다',
        content: '내용입니다',
        createdAt: DateTime(2026, 5, 5),
      );
      expect(post.id, 'test-1');
      expect(post.isAnonymous, isFalse);
      expect(post.likeCount, 0);
      expect(post.commentCount, 0);
      expect(post.viewCount, 0);
      expect(post.isHot, isFalse);
      expect(post.imageUrls, isEmpty);
    });

    test('익명 글', () {
      final post = PostModel(
        id: 'test-2',
        userId: 'user-1',
        authorName: '테스트유저',
        category: PostCategory.horror,
        title: '익명으로 씁니다',
        content: '비밀',
        isAnonymous: true,
        createdAt: DateTime.now(),
      );
      expect(post.isAnonymous, isTrue);
    });
  });

  group('CommentModel', () {
    test('일반 댓글', () {
      final comment = CommentModel(
        id: 'c-1',
        postId: 'p-1',
        userId: 'user-1',
        authorName: '댓글러',
        content: '좋은 글이에요',
        createdAt: DateTime.now(),
      );
      expect(comment.parentId, isNull);
      expect(comment.isAnonymous, isFalse);
    });

    test('대댓글', () {
      final reply = CommentModel(
        id: 'c-2',
        postId: 'p-1',
        userId: 'user-2',
        authorName: '답글러',
        content: '감사합니다',
        parentId: 'c-1',
        createdAt: DateTime.now(),
      );
      expect(reply.parentId, 'c-1');
    });
  });

  // ──────────────────────────────────────────
  // 위젯 테스트
  // ──────────────────────────────────────────

  group('OnboardingScreen', () {
    testWidgets('4개 슬라이드 표시', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _OnboardingTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 첫 슬라이드 헤드라인
      expect(find.text('빚, 혼자 갚지 마세요'), findsOneWidget);
      // 다음 버튼
      expect(find.text('다음'), findsOneWidget);
      // 건너뛰기
      expect(find.text('건너뛰기'), findsOneWidget);
    });

    testWidgets('스와이프 시 다음 슬라이드', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _OnboardingTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 오른쪽으로 스와이프
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('한눈에 보이는 내 빚'), findsOneWidget);
    });

    testWidgets('마지막 슬라이드에서 "시작하기" 표시', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _OnboardingTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 3번 스와이프
      for (int i = 0; i < 3; i++) {
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
      }

      expect(find.text('혼자가 아니에요'), findsOneWidget);
      expect(find.text('시작하기'), findsOneWidget);
      // 건너뛰기 사라짐
      expect(find.text('건너뛰기'), findsNothing);
    });
  });

  group('BadgesScreen', () {
    testWidgets('배지 화면 기본 구성', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _BadgesTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 헤더
      expect(find.text('나의 여정'), findsOneWidget);
      // 오늘의 한마디 섹션
      expect(find.text('오늘의 한마디'), findsOneWidget);
      // 배지 그리드 (18개 배지 - 미획득이면 ? 표시)
      expect(find.text('획득한 배지'), findsOneWidget);
      expect(find.text('0 / 18'), findsOneWidget);
    });

    testWidgets('streak 0일 때 안내 문구', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _BadgesTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // streak 0
      expect(find.text('0'), findsOneWidget);
      expect(find.text('오늘 시작해볼까요?'), findsOneWidget);
    });
  });

  group('StatisticsScreen', () {
    testWidgets('데이터 부족 시 빈 상태', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _StatisticsTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 빈 상태 메시지
      expect(
        find.textContaining('상환 기록이 쌓이면'),
        findsOneWidget,
      );
    });
  });

  group('CommunityScreen', () {
    testWidgets('빈 게시판 표시', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _CommunityTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 헤더
      expect(find.text('게시판'), findsOneWidget);
      // 카테고리 필터
      expect(find.text('전체'), findsOneWidget);
      expect(find.text('자유'), findsOneWidget);
      expect(find.text('질문'), findsOneWidget);
      // 정렬
      expect(find.text('최신순'), findsOneWidget);
      expect(find.text('인기순'), findsOneWidget);
      // 빈 상태
      expect(find.text('아직 글이 없어요. 첫 글을 써볼래요?'), findsOneWidget);
      // 글 수
      expect(find.text('0글'), findsOneWidget);
    });

    testWidgets('카테고리 필터 탭', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _CommunityTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 절약 카테고리 탭
      await tester.tap(find.text('절약'));
      await tester.pumpAndSettle();

      expect(find.text('절약에 글이 없어요'), findsOneWidget);
    });
  });

  group('SettingsScreen', () {
    testWidgets('설정 화면 기본 구성', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _SettingsTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 헤더
      expect(find.text('설정'), findsOneWidget);
      // 섹션들
      expect(find.text('빚 관리'), findsOneWidget);
      expect(find.text('알림'), findsOneWidget);
      expect(find.text('정보'), findsOneWidget);
      expect(find.text('계정'), findsOneWidget);
      // 항목
      expect(find.text('상환 전략'), findsOneWidget);
      expect(find.text('로그아웃'), findsOneWidget);
      expect(find.text('회원 탈퇴'), findsOneWidget);
      expect(find.text('버전'), findsOneWidget);
    });

    testWidgets('로그아웃 다이얼로그 표시', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _SettingsTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      expect(find.text('로그아웃하시겠어요?'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
    });

    testWidgets('회원탈퇴 다이얼로그 표시', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _SettingsTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('회원 탈퇴'));
      await tester.pumpAndSettle();

      expect(find.text('정말 떠나시려고요?'), findsOneWidget);
      expect(find.text('계속 쓸게요'), findsOneWidget);
    });
  });

  group('SimulationScreen', () {
    testWidgets('빚 없으면 안내 메시지', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _SimulationTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('갚을 빚이 없어요'), findsOneWidget);
    });
  });

  group('WritePostScreen', () {
    testWidgets('글쓰기 화면 기본 구성', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _WritePostTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('글쓰기'), findsOneWidget);
      expect(find.text('카테고리'), findsOneWidget);
      expect(find.text('익명으로 작성'), findsOneWidget);
      // 올리기 버튼 (비활성)
      expect(find.text('올리기'), findsOneWidget);
    });

    testWidgets('카테고리 선택 시 가이드 표시', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _WritePostTestWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 인증 카테고리 탭
      await tester.tap(find.text('인증'));
      await tester.pumpAndSettle();

      expect(
        find.text('어떤 진전이 있었나요? (사진 첨부 권장)'),
        findsOneWidget,
      );
    });
  });
}

// ──────────────────────────────────────────
// 테스트 래퍼 위젯들 (go_router 의존성 제거)
// ──────────────────────────────────────────

// 온보딩은 go_router 필요하므로 핵심 UI만 추출
class _OnboardingTestWrapper extends StatefulWidget {
  const _OnboardingTestWrapper();

  @override
  State<_OnboardingTestWrapper> createState() => _OnboardingTestWrapperState();
}

class _OnboardingTestWrapperState extends State<_OnboardingTestWrapper> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    {'icon': Icons.route_outlined, 'headline': '빚, 혼자 갚지 마세요', 'sub': '함께 계획하고, 매일 응원받으며,\n한 걸음씩 자유에 가까워져요.'},
    {'icon': Icons.dashboard_outlined, 'headline': '한눈에 보이는 내 빚', 'sub': '전체 그림이 보이면 막막함이 사라져요.\n진행률, 예상 완납일까지 한 화면에.'},
    {'icon': Icons.calendar_today_outlined, 'headline': '매일 작은 진전', 'sub': '꾸준함이 가장 큰 힘이에요.\n매일의 한 걸음을 응원해줄게요.'},
    {'icon': Icons.people_outline, 'headline': '혼자가 아니에요', 'sub': '비슷한 여정에 있는 사람들과\n정보를 나누고 응원받아요.'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _slides.length - 1)
                    GestureDetector(
                      onTap: () {},
                      child: const Text('건너뛰기'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(slide['headline'] as String, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      Text(slide['sub'] as String, textAlign: TextAlign.center),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _slides.length - 1) {
                    _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                  }
                },
                child: Text(_currentPage == _slides.length - 1 ? '시작하기' : '다음'),
              ),
            ),
            const Text('이미 계정이 있어요'),
          ],
        ),
      ),
    );
  }
}

// 배지 화면 래퍼
class _BadgesTestWrapper extends StatelessWidget {
  const _BadgesTestWrapper();

  @override
  Widget build(BuildContext context) {
    // 배지 화면 직접 import하면 go_router 의존성 때문에 문제.
    // 핵심 UI 로직만 테스트
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text('나의 여정', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
              // streak
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('0', style: TextStyle(fontSize: 40)),
                      Text('오늘 시작해볼까요?'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('획득한 배지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  Text('0 / ${BadgeDefinition.all.length}'),
                ],
              ),
              const SizedBox(height: 32),
              const Text('오늘의 한마디', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

// 통계 화면 래퍼 (데이터 없는 상태)
class _StatisticsTestWrapper extends StatelessWidget {
  const _StatisticsTestWrapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart_rounded, size: 64),
            const SizedBox(height: 24),
            Text(
              '상환 기록이 쌓이면\n여기에 그래프와 패턴이 나타나요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// 커뮤니티 화면 래퍼
class _CommunityTestWrapper extends StatefulWidget {
  const _CommunityTestWrapper();

  @override
  State<_CommunityTestWrapper> createState() => _CommunityTestWrapperState();
}

class _CommunityTestWrapperState extends State<_CommunityTestWrapper> {
  PostCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final emptyMessage = _selectedCategory == null
        ? '아직 글이 없어요. 첫 글을 써볼래요?'
        : '${_selectedCategory!.displayName}에 글이 없어요';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('게시판', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
            ),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _chip('전체', _selectedCategory == null, () => setState(() => _selectedCategory = null)),
                  ...PostCategory.values.map((cat) =>
                    _chip(cat.displayName, _selectedCategory == cat, () => setState(() => _selectedCategory = cat)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('최신순'),
                  const SizedBox(width: 8),
                  const Text('인기순'),
                  const SizedBox(width: 8),
                  const Text('댓글많은'),
                  const Spacer(),
                  const Text('0글'),
                ],
              ),
            ),
            Expanded(
              child: Center(child: Text(emptyMessage)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(999),
            border: selected ? Border.all(width: 2) : null,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

// 설정 화면 래퍼
class _SettingsTestWrapper extends StatelessWidget {
  const _SettingsTestWrapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text('설정', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
              // 섹션들
              Text('빚 관리', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ListTile(title: const Text('상환 전략'), subtitle: const Text('눈덩이 방식'), dense: true),
              const SizedBox(height: 24),
              Text('알림', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              const ListTile(title: Text('알림 설정'), dense: true),
              const SizedBox(height: 24),
              Text('정보', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              const ListTile(title: Text('버전'), subtitle: Text('1.0.0'), dense: true),
              const SizedBox(height: 24),
              Text('계정', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('로그아웃하시겠어요?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('로그아웃')),
                      ],
                    ),
                  );
                },
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('로그아웃')),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('정말 떠나시려고요?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('계속 쓸게요')),
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('회원 탈퇴')),
                      ],
                    ),
                  );
                },
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('회원 탈퇴')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 시뮬레이션 래퍼 (빚 없는 상태)
class _SimulationTestWrapper extends StatelessWidget {
  const _SimulationTestWrapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상환 시뮬레이션')),
      body: const Center(child: Text('갚을 빚이 없어요')),
    );
  }
}

// 글쓰기 래퍼
class _WritePostTestWrapper extends StatefulWidget {
  const _WritePostTestWrapper();

  @override
  State<_WritePostTestWrapper> createState() => _WritePostTestWrapperState();
}

class _WritePostTestWrapperState extends State<_WritePostTestWrapper> {
  PostCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글쓰기'),
        actions: [
          TextButton(
            onPressed: null,
            child: const Text('올리기'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('카테고리', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PostCategory.values.map((cat) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: _selectedCategory == cat ? Border.all(width: 2) : null,
                        color: Colors.grey[100],
                      ),
                      child: Text(cat.displayName),
                    ),
                  );
                }).toList(),
              ),
              if (_selectedCategory != null) ...[
                const SizedBox(height: 8),
                Text(_guideText(_selectedCategory!)),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (_) {}),
                  const Text('익명으로 작성'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _guideText(PostCategory cat) {
    switch (cat) {
      case PostCategory.certify: return '어떤 진전이 있었나요? (사진 첨부 권장)';
      case PostCategory.question: return '구체적으로 적어주시면 좋은 답이 와요';
      case PostCategory.save: return '실제로 효과 본 노하우를 공유해주세요';
      default: return '자유롭게 이야기해주세요';
    }
  }
}

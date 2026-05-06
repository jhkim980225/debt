import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:debt_free/features/community/domain/post_model.dart';
import 'package:debt_free/features/community/data/community_providers.dart';

// ──────────────────────────────────────────
// 더미 사용자 10명 (docs/dummy-users.md 참조)
// ──────────────────────────────────────────

const _dummyUsers = [
  {'id': 'user-001', 'name': '햇살모은이'},
  {'id': 'user-002', 'name': '조용한걸음'},
  {'id': 'user-003', 'name': '바람부는언덕'},
  {'id': 'user-004', 'name': '꾸준한하루'},
  {'id': 'user-005', 'name': '새벽이슬'},
  {'id': 'user-006', 'name': '산책하는고양이'},
  {'id': 'user-007', 'name': '느린거북이'},
  {'id': 'user-008', 'name': '달빛여행자'},
  {'id': 'user-009', 'name': '푸른나무'},
  {'id': 'user-010', 'name': '작은불꽃'},
];

/// 더미 게시글 생성
List<PostModel> _createDummyPosts() {
  final now = DateTime.now();
  return [
    PostModel(
      id: 'post-001',
      userId: 'user-001',
      authorName: '햇살모은이',
      category: PostCategory.free,
      title: '드디어 빚 갚기 시작했어요',
      content: '카드빚 500만원... 올해 안에 다 갚는 게 목표입니다. 같이 힘내요!',
      likeCount: 42,
      commentCount: 8,
      viewCount: 320,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    PostModel(
      id: 'post-002',
      userId: 'user-002',
      authorName: '조용한걸음',
      category: PostCategory.save,
      title: '커피값 아끼니까 한 달에 15만원 절약됨',
      content: '매일 아메리카노 한 잔씩 사먹던 걸 텀블러로 바꿨더니 진짜 차이가 크네요.',
      likeCount: 128,
      commentCount: 23,
      viewCount: 1540,
      createdAt: now.subtract(const Duration(hours: 5)),
      isHot: true,
    ),
    PostModel(
      id: 'post-003',
      userId: 'user-003',
      authorName: '바람부는언덕',
      category: PostCategory.question,
      title: '학자금 대출 이자율 낮추는 방법 있나요?',
      content: '현재 4.5%인데 더 낮출 수 있는 방법이 있을까요? 대환대출 해보신 분 계신가요?',
      likeCount: 15,
      commentCount: 12,
      viewCount: 430,
      createdAt: now.subtract(const Duration(hours: 12)),
    ),
    PostModel(
      id: 'post-004',
      userId: 'user-004',
      authorName: '꾸준한하루',
      category: PostCategory.certify,
      title: '100일 연속 상환 달성!',
      content: '매일 조금씩이라도 갚다 보니 어느새 100일이 됐어요. 중간에 포기하고 싶었지만 버텼습니다.',
      likeCount: 256,
      commentCount: 45,
      viewCount: 2100,
      createdAt: now.subtract(const Duration(days: 1)),
      isHot: true,
    ),
    PostModel(
      id: 'post-005',
      userId: 'user-005',
      authorName: '새벽이슬',
      category: PostCategory.horror,
      title: '리볼빙의 늪에서 빠져나온 이야기',
      content: '리볼빙이 편한 줄 알았는데 이자만 100만원 넘게 냈어요. 절대 쓰지 마세요.',
      isAnonymous: true,
      likeCount: 89,
      commentCount: 31,
      viewCount: 980,
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    PostModel(
      id: 'post-006',
      userId: 'user-006',
      authorName: '산책하는고양이',
      category: PostCategory.sidejob,
      title: '주말 배달 알바로 월 80만원 추가 수입',
      content: '토요일 일요일 각각 5시간씩 배달하고 있어요. 체력적으로 힘들지만 빚 갚는 속도가 확 빨라졌어요.',
      likeCount: 67,
      commentCount: 19,
      viewCount: 720,
      createdAt: now.subtract(const Duration(days: 3)),
    ),
    PostModel(
      id: 'post-007',
      userId: 'user-007',
      authorName: '느린거북이',
      category: PostCategory.finance,
      title: '신용점수 올리는 현실적인 방법 정리',
      content: '1. 연체 절대 안 하기 2. 카드 한도 30% 이하 사용 3. 통신비 자동이체 4. 대출 건수 줄이기',
      likeCount: 203,
      commentCount: 38,
      viewCount: 3200,
      createdAt: now.subtract(const Duration(days: 4)),
      isHot: true,
      isEditorPick: true,
    ),
    PostModel(
      id: 'post-008',
      userId: 'user-008',
      authorName: '달빛여행자',
      category: PostCategory.free,
      title: '오늘 마지막 할부금 냈어요',
      content: '2년 동안 갚은 차 할부... 드디어 끝났습니다. 눈물이 나네요.',
      likeCount: 312,
      commentCount: 52,
      viewCount: 4100,
      createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      isHot: true,
    ),
    PostModel(
      id: 'post-009',
      userId: 'user-009',
      authorName: '푸른나무',
      category: PostCategory.question,
      title: '눈덩이 방식이 정말 효과 있나요?',
      content: '작은 빚부터 갚으라는데 이자율 높은 거 먼저 갚는 게 수학적으로 맞지 않나요?',
      likeCount: 34,
      commentCount: 28,
      viewCount: 560,
      createdAt: now.subtract(const Duration(hours: 8)),
    ),
    PostModel(
      id: 'post-010',
      userId: 'user-010',
      authorName: '작은불꽃',
      category: PostCategory.certify,
      title: '첫 빚 졸업! 카드빚 200만원 완납',
      content: '6개월 걸렸지만 해냈어요. 다음은 학자금 대출 차례!',
      likeCount: 178,
      commentCount: 33,
      viewCount: 1800,
      createdAt: now.subtract(const Duration(days: 5)),
    ),
  ];
}

/// 더미 댓글 생성
List<CommentModel> _createDummyComments() {
  final now = DateTime.now();
  return [
    // post-001 댓글
    CommentModel(
      id: 'comment-001',
      postId: 'post-001',
      userId: 'user-002',
      authorName: '조용한걸음',
      content: '화이팅! 저도 올해 목표 세웠어요. 같이 가요!',
      likeCount: 5,
      createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
    ),
    CommentModel(
      id: 'comment-002',
      postId: 'post-001',
      userId: 'user-004',
      authorName: '꾸준한하루',
      content: '시작이 반이에요. 응원합니다!',
      likeCount: 3,
      createdAt: now.subtract(const Duration(hours: 1)),
    ),
    // comment-001에 대한 대댓글
    CommentModel(
      id: 'comment-003',
      postId: 'post-001',
      userId: 'user-001',
      authorName: '햇살모은이',
      content: '감사합니다! 같이 힘내요 ㅎㅎ',
      likeCount: 2,
      parentId: 'comment-001',
      createdAt: now.subtract(const Duration(minutes: 50)),
    ),

    // post-002 댓글
    CommentModel(
      id: 'comment-004',
      postId: 'post-002',
      userId: 'user-003',
      authorName: '바람부는언덕',
      content: '저도 텀블러 시작했는데 확실히 차이가 크더라고요',
      likeCount: 8,
      createdAt: now.subtract(const Duration(hours: 4)),
    ),
    CommentModel(
      id: 'comment-005',
      postId: 'post-002',
      userId: 'user-006',
      authorName: '산책하는고양이',
      content: '한 달에 15만원이면 1년에 180만원... 대단해요',
      likeCount: 12,
      createdAt: now.subtract(const Duration(hours: 3)),
    ),
    // 익명 댓글
    CommentModel(
      id: 'comment-006',
      postId: 'post-002',
      userId: 'user-009',
      authorName: '푸른나무',
      content: '저는 점심도 도시락으로 바꿨어요',
      isAnonymous: true,
      likeCount: 6,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    // comment-004 대댓글
    CommentModel(
      id: 'comment-007',
      postId: 'post-002',
      userId: 'user-002',
      authorName: '조용한걸음',
      content: '맞아요! 습관이 들면 아깝지도 않아요',
      likeCount: 4,
      parentId: 'comment-004',
      createdAt: now.subtract(const Duration(hours: 2, minutes: 30)),
    ),

    // post-004 댓글 (인증글)
    CommentModel(
      id: 'comment-008',
      postId: 'post-004',
      userId: 'user-008',
      authorName: '달빛여행자',
      content: '100일 대단해요!! 저도 지금 30일째인데 목표가 생겼어요',
      likeCount: 15,
      createdAt: now.subtract(const Duration(hours: 20)),
    ),
    CommentModel(
      id: 'comment-009',
      postId: 'post-004',
      userId: 'user-010',
      authorName: '작은불꽃',
      content: '이 글 보고 오늘도 기록했습니다. 감사해요!',
      likeCount: 9,
      createdAt: now.subtract(const Duration(hours: 18)),
    ),
    // comment-008 대댓글
    CommentModel(
      id: 'comment-010',
      postId: 'post-004',
      userId: 'user-004',
      authorName: '꾸준한하루',
      content: '30일도 엄청나요! 꼭 100일 달성하시길!',
      likeCount: 7,
      parentId: 'comment-008',
      createdAt: now.subtract(const Duration(hours: 17)),
    ),

    // post-005 댓글 (공포의빚)
    CommentModel(
      id: 'comment-011',
      postId: 'post-005',
      userId: 'user-007',
      authorName: '느린거북이',
      content: '리볼빙 정말 무서워요... 경험 공유 감사합니다',
      likeCount: 11,
      createdAt: now.subtract(const Duration(days: 1, hours: 20)),
    ),

    // post-009 댓글 (질문글 답변들)
    CommentModel(
      id: 'comment-012',
      postId: 'post-009',
      userId: 'user-007',
      authorName: '느린거북이',
      content: '수학적으로는 눈사태가 맞지만 심리적으로 눈덩이가 더 지속 가능해요',
      likeCount: 18,
      createdAt: now.subtract(const Duration(hours: 7)),
    ),
    CommentModel(
      id: 'comment-013',
      postId: 'post-009',
      userId: 'user-004',
      authorName: '꾸준한하루',
      content: '저는 눈덩이로 해서 작은 빚 2개 먼저 갚으니까 동기부여가 확 됐어요',
      likeCount: 14,
      createdAt: now.subtract(const Duration(hours: 6)),
    ),
    // comment-012 대댓글
    CommentModel(
      id: 'comment-014',
      postId: 'post-009',
      userId: 'user-009',
      authorName: '푸른나무',
      content: '아 그런 관점도 있네요. 감사합니다!',
      likeCount: 3,
      parentId: 'comment-012',
      createdAt: now.subtract(const Duration(hours: 5)),
    ),
  ];
}

void main() {
  // ──────────────────────────────────────────
  // Provider 단위 테스트
  // ──────────────────────────────────────────

  group('CommunityPostsNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container
          .read(communityPostsProvider.notifier)
          .seedPosts(_createDummyPosts());
    });

    tearDown(() => container.dispose());

    test('더미 게시글 10개 시드', () {
      final posts = container.read(communityPostsProvider);
      expect(posts.length, 10);
    });

    test('더미 사용자 10명의 글이 모두 존재', () {
      final posts = container.read(communityPostsProvider);
      for (final user in _dummyUsers) {
        expect(
          posts.any((p) => p.userId == user['id']),
          isTrue,
          reason: '${user['name']}의 글이 없음',
        );
      }
    });

    test('카테고리 필터 - 자유', () {
      final posts = container.read(communityPostsProvider);
      final free = posts.where((p) => p.category == PostCategory.free).toList();
      expect(free.length, 2);
    });

    test('카테고리 필터 - 인증', () {
      final posts = container.read(communityPostsProvider);
      final certify = posts.where((p) => p.category == PostCategory.certify).toList();
      expect(certify.length, 2);
    });

    test('카테고리 필터 - 모든 카테고리 커버', () {
      final posts = container.read(communityPostsProvider);
      final categories = posts.map((p) => p.category).toSet();
      expect(categories.length, 7); // 7개 카테고리 전부
    });

    test('HOT 라벨 글 존재', () {
      final posts = container.read(communityPostsProvider);
      final hot = posts.where((p) => p.isHot).toList();
      expect(hot.length, 4);
    });

    test('에디터픽 글 존재', () {
      final posts = container.read(communityPostsProvider);
      final picks = posts.where((p) => p.isEditorPick).toList();
      expect(picks.length, 1);
      expect(picks.first.title, contains('신용점수'));
    });

    test('익명 글 존재', () {
      final posts = container.read(communityPostsProvider);
      final anon = posts.where((p) => p.isAnonymous).toList();
      expect(anon.length, 1);
      expect(anon.first.category, PostCategory.horror);
    });

    test('게시글 좋아요 토글 - 증가', () {
      container
          .read(communityPostsProvider.notifier)
          .toggleLike('post-001', liked: true);
      final post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-001');
      expect(post.likeCount, 43); // 42 + 1
    });

    test('게시글 좋아요 토글 - 취소', () {
      // 먼저 좋아요
      container
          .read(communityPostsProvider.notifier)
          .toggleLike('post-001', liked: true);
      // 취소
      container
          .read(communityPostsProvider.notifier)
          .toggleLike('post-001', liked: false);
      final post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-001');
      expect(post.likeCount, 42); // 원래대로
    });

    test('댓글 수 증가', () {
      container
          .read(communityPostsProvider.notifier)
          .incrementCommentCount('post-001');
      final post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-001');
      expect(post.commentCount, 9); // 8 + 1
    });

    test('조회수 증가', () {
      container
          .read(communityPostsProvider.notifier)
          .incrementViewCount('post-001');
      final post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-001');
      expect(post.viewCount, 321); // 320 + 1
    });

    test('새 글 추가', () {
      final newPost = PostModel(
        id: 'post-new',
        userId: 'user-001',
        authorName: '햇살모은이',
        category: PostCategory.free,
        title: '새 글입니다',
        content: '테스트 내용',
        createdAt: DateTime.now(),
      );
      container.read(communityPostsProvider.notifier).addPost(newPost);
      final posts = container.read(communityPostsProvider);
      expect(posts.length, 11);
      expect(posts.first.id, 'post-new'); // 맨 앞에 추가
    });

    test('정렬 - 최신순', () {
      final posts = container.read(communityPostsProvider);
      final sorted = List<PostModel>.from(posts)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      expect(sorted.first.createdAt.isAfter(sorted.last.createdAt), isTrue);
    });

    test('정렬 - 인기순', () {
      final posts = container.read(communityPostsProvider);
      final sorted = List<PostModel>.from(posts)
        ..sort((a, b) =>
            (b.likeCount + b.viewCount).compareTo(a.likeCount + a.viewCount));
      expect(sorted.first.likeCount + sorted.first.viewCount,
          greaterThanOrEqualTo(sorted.last.likeCount + sorted.last.viewCount));
    });

    test('정렬 - 댓글많은순', () {
      final posts = container.read(communityPostsProvider);
      final sorted = List<PostModel>.from(posts)
        ..sort((a, b) => b.commentCount.compareTo(a.commentCount));
      expect(sorted.first.commentCount,
          greaterThanOrEqualTo(sorted.last.commentCount));
    });
  });

  group('CommunityCommentsNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container
          .read(communityCommentsProvider.notifier)
          .seedComments(_createDummyComments());
    });

    tearDown(() => container.dispose());

    test('더미 댓글 14개 시드', () {
      final comments = container.read(communityCommentsProvider);
      expect(comments.length, 14);
    });

    test('게시글별 댓글 조회', () {
      final notifier = container.read(communityCommentsProvider.notifier);

      final post1Comments = notifier.commentsForPost('post-001');
      expect(post1Comments.length, 3); // 댓글 2 + 대댓글 1

      final post2Comments = notifier.commentsForPost('post-002');
      expect(post2Comments.length, 4); // 댓글 3 + 대댓글 1

      final post4Comments = notifier.commentsForPost('post-004');
      expect(post4Comments.length, 3); // 댓글 2 + 대댓글 1
    });

    test('대댓글 구분', () {
      final comments = container.read(communityCommentsProvider);

      // 대댓글 (parentId != null)
      final replies = comments.where((c) => c.parentId != null).toList();
      expect(replies.length, 4); // comment-003, 007, 010, 014
      expect(replies.any((c) => c.id == 'comment-003'), isTrue);
      expect(replies.any((c) => c.id == 'comment-007'), isTrue);
      expect(replies.any((c) => c.id == 'comment-010'), isTrue);
      expect(replies.any((c) => c.id == 'comment-014'), isTrue);
    });

    test('대댓글이 올바른 부모에 연결', () {
      final comments = container.read(communityCommentsProvider);

      final reply3 = comments.firstWhere((c) => c.id == 'comment-003');
      expect(reply3.parentId, 'comment-001');

      final reply7 = comments.firstWhere((c) => c.id == 'comment-007');
      expect(reply7.parentId, 'comment-004');

      final reply10 = comments.firstWhere((c) => c.id == 'comment-010');
      expect(reply10.parentId, 'comment-008');
    });

    test('익명 댓글 존재', () {
      final comments = container.read(communityCommentsProvider);
      final anon = comments.where((c) => c.isAnonymous).toList();
      expect(anon.length, 1);
      expect(anon.first.id, 'comment-006');
    });

    test('댓글 추가', () {
      final newComment = CommentModel(
        id: 'comment-new',
        postId: 'post-001',
        userId: 'local_user',
        authorName: '나',
        content: '테스트 댓글입니다',
        createdAt: DateTime.now(),
      );
      container.read(communityCommentsProvider.notifier).addComment(newComment);
      final comments = container.read(communityCommentsProvider);
      expect(comments.length, 15);
    });

    test('대댓글 추가', () {
      final reply = CommentModel(
        id: 'comment-reply-new',
        postId: 'post-001',
        userId: 'local_user',
        authorName: '나',
        content: '대댓글 테스트',
        parentId: 'comment-001',
        createdAt: DateTime.now(),
      );
      container.read(communityCommentsProvider.notifier).addComment(reply);
      final post1 = container
          .read(communityCommentsProvider.notifier)
          .commentsForPost('post-001');
      final replies = post1.where((c) => c.parentId == 'comment-001').toList();
      expect(replies.length, 2); // 기존 comment-003 + 새 reply
    });

    test('댓글 좋아요 토글 - 증가', () {
      container
          .read(communityCommentsProvider.notifier)
          .toggleCommentLike('comment-001', liked: true);
      final comment = container
          .read(communityCommentsProvider)
          .firstWhere((c) => c.id == 'comment-001');
      expect(comment.likeCount, 6); // 5 + 1
    });

    test('댓글 좋아요 토글 - 취소', () {
      container
          .read(communityCommentsProvider.notifier)
          .toggleCommentLike('comment-001', liked: true);
      container
          .read(communityCommentsProvider.notifier)
          .toggleCommentLike('comment-001', liked: false);
      final comment = container
          .read(communityCommentsProvider)
          .firstWhere((c) => c.id == 'comment-001');
      expect(comment.likeCount, 5); // 원래대로
    });
  });

  group('좋아요 상태 관리 (likedPostsProvider / likedCommentsProvider)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container
          .read(communityPostsProvider.notifier)
          .seedPosts(_createDummyPosts());
      container
          .read(communityCommentsProvider.notifier)
          .seedComments(_createDummyComments());
    });

    tearDown(() => container.dispose());

    test('초기 상태 - 좋아요 없음', () {
      expect(container.read(likedPostsProvider), isEmpty);
      expect(container.read(likedCommentsProvider), isEmpty);
    });

    test('게시글 좋아요 추가 + provider 동기화', () {
      // 좋아요 상태 추가
      container.read(likedPostsProvider.notifier).state = {'post-001'};
      container
          .read(communityPostsProvider.notifier)
          .toggleLike('post-001', liked: true);

      expect(container.read(likedPostsProvider).contains('post-001'), isTrue);
      final post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-001');
      expect(post.likeCount, 43);
    });

    test('게시글 좋아요 취소 + provider 동기화', () {
      // 좋아요
      container.read(likedPostsProvider.notifier).state = {'post-001'};
      container
          .read(communityPostsProvider.notifier)
          .toggleLike('post-001', liked: true);
      // 취소
      container.read(likedPostsProvider.notifier).state = {};
      container
          .read(communityPostsProvider.notifier)
          .toggleLike('post-001', liked: false);

      expect(container.read(likedPostsProvider), isEmpty);
      final post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-001');
      expect(post.likeCount, 42);
    });

    test('여러 게시글 동시 좋아요', () {
      container.read(likedPostsProvider.notifier).state = {
        'post-001',
        'post-003',
        'post-005'
      };
      container
          .read(communityPostsProvider.notifier)
          .toggleLike('post-001', liked: true);
      container
          .read(communityPostsProvider.notifier)
          .toggleLike('post-003', liked: true);
      container
          .read(communityPostsProvider.notifier)
          .toggleLike('post-005', liked: true);

      expect(container.read(likedPostsProvider).length, 3);

      final p1 = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-001');
      final p3 = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-003');
      expect(p1.likeCount, 43);
      expect(p3.likeCount, 16);
    });

    test('댓글 좋아요 추가 + provider 동기화', () {
      container.read(likedCommentsProvider.notifier).state = {'comment-001'};
      container
          .read(communityCommentsProvider.notifier)
          .toggleCommentLike('comment-001', liked: true);

      expect(
          container.read(likedCommentsProvider).contains('comment-001'), isTrue);
      final c = container
          .read(communityCommentsProvider)
          .firstWhere((c) => c.id == 'comment-001');
      expect(c.likeCount, 6);
    });

    test('댓글 좋아요 취소 + provider 동기화', () {
      // 좋아요
      container.read(likedCommentsProvider.notifier).state = {'comment-001'};
      container
          .read(communityCommentsProvider.notifier)
          .toggleCommentLike('comment-001', liked: true);
      // 취소
      container.read(likedCommentsProvider.notifier).state = {};
      container
          .read(communityCommentsProvider.notifier)
          .toggleCommentLike('comment-001', liked: false);

      expect(container.read(likedCommentsProvider), isEmpty);
      final c = container
          .read(communityCommentsProvider)
          .firstWhere((c) => c.id == 'comment-001');
      expect(c.likeCount, 5);
    });
  });

  group('통합 시나리오', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container
          .read(communityPostsProvider.notifier)
          .seedPosts(_createDummyPosts());
      container
          .read(communityCommentsProvider.notifier)
          .seedComments(_createDummyComments());
    });

    tearDown(() => container.dispose());

    test('시나리오: 글 읽기 → 좋아요 → 댓글 → 대댓글', () {
      // 1. 조회수 증가
      container
          .read(communityPostsProvider.notifier)
          .incrementViewCount('post-002');
      var post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-002');
      expect(post.viewCount, 1541);

      // 2. 게시글 좋아요
      container.read(likedPostsProvider.notifier).state = {'post-002'};
      container
          .read(communityPostsProvider.notifier)
          .toggleLike('post-002', liked: true);
      post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-002');
      expect(post.likeCount, 129);

      // 3. 댓글 작성
      final myComment = CommentModel(
        id: 'my-comment-1',
        postId: 'post-002',
        userId: 'local_user',
        authorName: '나',
        content: '좋은 정보 감사합니다!',
        createdAt: DateTime.now(),
      );
      container.read(communityCommentsProvider.notifier).addComment(myComment);
      container
          .read(communityPostsProvider.notifier)
          .incrementCommentCount('post-002');
      post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-002');
      expect(post.commentCount, 24);

      // 4. 기존 댓글에 좋아요
      container.read(likedCommentsProvider.notifier).state = {'comment-004'};
      container
          .read(communityCommentsProvider.notifier)
          .toggleCommentLike('comment-004', liked: true);
      final likedComment = container
          .read(communityCommentsProvider)
          .firstWhere((c) => c.id == 'comment-004');
      expect(likedComment.likeCount, 9);

      // 5. 대댓글 작성
      final myReply = CommentModel(
        id: 'my-reply-1',
        postId: 'post-002',
        userId: 'local_user',
        authorName: '나',
        content: '저도 해봐야겠어요!',
        parentId: 'comment-004',
        createdAt: DateTime.now(),
      );
      container.read(communityCommentsProvider.notifier).addComment(myReply);
      container
          .read(communityPostsProvider.notifier)
          .incrementCommentCount('post-002');

      // 최종 확인
      post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-002');
      expect(post.commentCount, 25);

      final post2Comments = container
          .read(communityCommentsProvider.notifier)
          .commentsForPost('post-002');
      expect(post2Comments.length, 6); // 기존 4 + 댓글 1 + 대댓글 1

      final repliesTo004 =
          post2Comments.where((c) => c.parentId == 'comment-004').toList();
      expect(repliesTo004.length, 2); // 기존 comment-007 + my-reply-1
    });

    test('시나리오: 새 글 작성 → 목록에 반영 → 댓글 달기', () {
      final newPost = PostModel(
        id: 'post-new-scenario',
        userId: 'local_user',
        authorName: '나',
        category: PostCategory.free,
        title: '테스트 게시글',
        content: '내용입니다',
        createdAt: DateTime.now(),
      );

      // 1. 글 작성
      container.read(communityPostsProvider.notifier).addPost(newPost);
      expect(container.read(communityPostsProvider).length, 11);
      expect(container.read(communityPostsProvider).first.id, 'post-new-scenario');

      // 2. 다른 사용자가 댓글
      final otherComment = CommentModel(
        id: 'other-comment-1',
        postId: 'post-new-scenario',
        userId: 'user-003',
        authorName: '바람부는언덕',
        content: '응원합니다!',
        createdAt: DateTime.now(),
      );
      container.read(communityCommentsProvider.notifier).addComment(otherComment);
      container
          .read(communityPostsProvider.notifier)
          .incrementCommentCount('post-new-scenario');

      final post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-new-scenario');
      expect(post.commentCount, 1);

      // 3. 내가 대댓글
      final myReply = CommentModel(
        id: 'my-reply-to-other',
        postId: 'post-new-scenario',
        userId: 'local_user',
        authorName: '나',
        content: '감사합니다!',
        parentId: 'other-comment-1',
        createdAt: DateTime.now(),
      );
      container.read(communityCommentsProvider.notifier).addComment(myReply);
      container
          .read(communityPostsProvider.notifier)
          .incrementCommentCount('post-new-scenario');

      final updatedPost = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-new-scenario');
      expect(updatedPost.commentCount, 2);
    });

    test('시나리오: 익명 글 작성 + 익명 댓글', () {
      final anonPost = PostModel(
        id: 'post-anon',
        userId: 'local_user',
        authorName: '나',
        category: PostCategory.horror,
        title: '익명으로 쓰는 글',
        content: '비밀입니다',
        isAnonymous: true,
        createdAt: DateTime.now(),
      );
      container.read(communityPostsProvider.notifier).addPost(anonPost);

      final anonComment = CommentModel(
        id: 'anon-comment-1',
        postId: 'post-anon',
        userId: 'user-005',
        authorName: '새벽이슬',
        content: '공감해요',
        isAnonymous: true,
        createdAt: DateTime.now(),
      );
      container.read(communityCommentsProvider.notifier).addComment(anonComment);
      container
          .read(communityPostsProvider.notifier)
          .incrementCommentCount('post-anon');

      final post = container
          .read(communityPostsProvider)
          .firstWhere((p) => p.id == 'post-anon');
      expect(post.isAnonymous, isTrue);
      expect(post.commentCount, 1);

      final comment = container
          .read(communityCommentsProvider)
          .firstWhere((c) => c.id == 'anon-comment-1');
      expect(comment.isAnonymous, isTrue);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../domain/post_model.dart';
import '../data/community_providers.dart';

/// 게시글 상세 화면
class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isAnonymousComment = false;
  String? _replyToCommentId; // 답글 대상 댓글 ID
  String? _replyToName; // 답글 대상 닉네임

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(communityPostsProvider);
    final allComments = ref.watch(communityCommentsProvider);
    final likedPosts = ref.watch(likedPostsProvider);
    final likedCommentIds = ref.watch(likedCommentsProvider);

    final post = posts.where((p) => p.id == widget.postId).firstOrNull;

    if (post == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('삭제된 글이에요')),
      );
    }

    final isLiked = likedPosts.contains(post.id);
    final comments = allComments.where((c) => c.postId == widget.postId).toList();

    // 댓글 정렬: 부모 먼저, 대댓글은 부모 바로 아래
    final rootComments = comments.where((c) => c.parentId == null).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final orderedComments = <CommentModel>[];
    for (final root in rootComments) {
      orderedComments.add(root);
      final replies = comments
          .where((c) => c.parentId == root.id)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      orderedComments.addAll(replies);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') _showReportDialog(context);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'report', child: Text('신고하기')),
              const PopupMenuItem(value: 'share', child: Text('공유하기')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),

                    // 카테고리
                    _categoryLabel(post.category),
                    const SizedBox(height: AppSpacing.sm),

                    // 제목
                    Text(post.title, style: AppTypography.headingMedium),
                    const SizedBox(height: AppSpacing.sm),

                    // 작성자 정보
                    Row(
                      children: [
                        Text(
                          post.isAnonymous ? '익명' : post.authorName,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ' · ${_timeAgo(post.createdAt)} · 조회 ${post.viewCount}',
                          style: AppTypography.labelTiny,
                        ),
                      ],
                    ),

                    const Divider(height: AppSpacing.xxl),

                    // 본문
                    Text(post.content, style: AppTypography.bodyLarge),

                    const SizedBox(height: AppSpacing.xxl),

                    // 액션 바
                    Row(
                      children: [
                        // 좋아요
                        GestureDetector(
                          onTap: () {
                            final newLiked = !isLiked;
                            final current = ref.read(likedPostsProvider);
                            if (newLiked) {
                              ref.read(likedPostsProvider.notifier).state = {...current, post.id};
                            } else {
                              ref.read(likedPostsProvider.notifier).state = {...current}..remove(post.id);
                            }
                            ref.read(communityPostsProvider.notifier)
                                .toggleLike(post.id, liked: newLiked);
                          },
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isLiked ? AppColors.danger : AppColors.textTertiary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '${post.likeCount}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxl),
                        // 댓글 수
                        Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline,
                                size: 18, color: AppColors.textTertiary),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${comments.length}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: AppSpacing.xxl),

                    // 댓글 영역
                    Text('댓글 ${comments.length}개', style: AppTypography.headingSmall),
                    const SizedBox(height: AppSpacing.lg),

                    if (orderedComments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Text(
                            '첫 댓글을 남겨보세요',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...orderedComments.map((c) => _commentItem(c, likedCommentIds)),

                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),

            // 답글 표시 바
            if (_replyToCommentId != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                color: AppColors.surfaceSecondary,
                child: Row(
                  children: [
                    Text(
                      '$_replyToName에게 답글',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() {
                        _replyToCommentId = null;
                        _replyToName = null;
                      }),
                      child: const Icon(Icons.close, size: 16, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),

            // 댓글 입력
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(
                        () => _isAnonymousComment = !_isAnonymousComment),
                    child: Icon(
                      _isAnonymousComment
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: _isAnonymousComment
                          ? AppColors.info
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: _isAnonymousComment
                            ? '익명으로 댓글 작성'
                            : '댓글을 입력해주세요',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.send,
                        size: 20, color: AppColors.info),
                    onPressed: _submitComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentItem(CommentModel comment, Set<String> likedIds) {
    final isLiked = likedIds.contains(comment.id);

    return Padding(
      padding: EdgeInsets.only(
        left: comment.parentId != null ? AppSpacing.xxl : 0,
        bottom: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.isAnonymous ? '익명' : comment.authorName,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(_timeAgo(comment.createdAt), style: AppTypography.labelTiny),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(comment.content, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              // 댓글 좋아요
              GestureDetector(
                onTap: () {
                  final newLiked = !isLiked;
                  final current = ref.read(likedCommentsProvider);
                  if (newLiked) {
                    ref.read(likedCommentsProvider.notifier).state = {...current, comment.id};
                  } else {
                    ref.read(likedCommentsProvider.notifier).state = {...current}..remove(comment.id);
                  }
                  ref.read(communityCommentsProvider.notifier)
                      .toggleCommentLike(comment.id, liked: newLiked);
                },
                child: Text(
                  '${isLiked ? "♥" : "♡"} ${comment.likeCount}',
                  style: AppTypography.labelTiny.copyWith(
                    color: isLiked ? AppColors.danger : AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // 답글 버튼
              GestureDetector(
                onTap: () {
                  // 대댓글이면 원 댓글 기준
                  final targetId = comment.parentId ?? comment.id;
                  setState(() {
                    _replyToCommentId = targetId;
                    _replyToName = comment.isAnonymous ? '익명' : comment.authorName;
                  });
                  _commentController.clear();
                  // 키보드 올리기
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Text(
                  '답글',
                  style: AppTypography.labelTiny.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryLabel(PostCategory category) {
    Color bg;
    Color text;
    switch (category) {
      case PostCategory.free:
        bg = AppColors.surfaceSecondary; text = AppColors.textSecondary;
      case PostCategory.question:
        bg = AppColors.pinkLight; text = AppColors.pinkDark;
      case PostCategory.certify:
        bg = AppColors.accentLight; text = AppColors.accentDark;
      case PostCategory.save:
        bg = AppColors.successLight; text = AppColors.success;
      case PostCategory.sidejob:
        bg = AppColors.purpleLight; text = AppColors.purpleDark;
      case PostCategory.finance:
        bg = AppColors.infoLight; text = AppColors.infoDark;
      case PostCategory.horror:
        bg = AppColors.dangerLight; text = AppColors.dangerDark;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        category.displayName,
        style: AppTypography.labelSmall.copyWith(color: text, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final comment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.postId,
      userId: 'local_user',
      authorName: '나',
      content: text,
      isAnonymous: _isAnonymousComment,
      parentId: _replyToCommentId,
      createdAt: DateTime.now(),
    );

    ref.read(communityCommentsProvider.notifier).addComment(comment);
    ref.read(communityPostsProvider.notifier).incrementCommentCount(widget.postId);

    _commentController.clear();
    setState(() {
      _replyToCommentId = null;
      _replyToName = null;
    });
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('신고하기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _reportOption('스팸/광고'),
            _reportOption('욕설/혐오'),
            _reportOption('잘못된 정보'),
            _reportOption('도배'),
            _reportOption('기타'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  Widget _reportOption(String reason) {
    return ListTile(
      title: Text(reason, style: AppTypography.bodyMedium),
      dense: true,
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('신고가 접수됐어요'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dateTime.month}/${dateTime.day}';
  }
}

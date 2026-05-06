import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_chip.dart';
import '../domain/post_model.dart';
import '../data/community_providers.dart';

/// 커뮤니티 게시판 화면
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  PostCategory? _selectedCategory;
  String _sortBy = 'latest'; // latest, popular, comments

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(communityPostsProvider);

    // 카테고리 필터
    final filtered = _selectedCategory == null
        ? posts
        : posts.where((p) => p.category == _selectedCategory).toList();

    // 정렬
    final sorted = List<PostModel>.from(filtered);
    switch (_sortBy) {
      case 'popular':
        sorted.sort((a, b) =>
            (b.likeCount + b.viewCount).compareTo(a.likeCount + a.viewCount));
        break;
      case 'comments':
        sorted.sort((a, b) => b.commentCount.compareTo(a.commentCount));
        break;
      default:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxl),
                    child:
                        Text('게시판', style: AppTypography.headingLarge),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxl),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, size: 22),
                          onPressed: () => _showSearch(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 22),
                          onPressed: () => context.push('/community/write'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 카테고리 필터 (가로 스크롤)
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                children: [
                  AppChip(
                    label: '전체',
                    isSelected: _selectedCategory == null,
                    onTap: () =>
                        setState(() => _selectedCategory = null),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ...PostCategory.values.map((cat) => Padding(
                        padding:
                            const EdgeInsets.only(right: AppSpacing.sm),
                        child: AppChip(
                          label: cat.displayName,
                          isSelected: _selectedCategory == cat,
                          onTap: () =>
                              setState(() => _selectedCategory = cat),
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 정렬
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Row(
                children: [
                  _sortChip('최신순', 'latest'),
                  const SizedBox(width: AppSpacing.sm),
                  _sortChip('인기순', 'popular'),
                  const SizedBox(width: AppSpacing.sm),
                  _sortChip('댓글많은', 'comments'),
                  const Spacer(),
                  Text(
                    '${sorted.length}글',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // 게시글 목록
            Expanded(
              child: sorted.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding),
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: AppColors.borderLight,
                      ),
                      itemBuilder: (context, index) {
                        final post = sorted[index];
                        return _postItem(context, post);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _postItem(BuildContext context, PostModel post) {
    return GestureDetector(
      onTap: () {
        // 조회수 증가
        ref.read(communityPostsProvider.notifier).incrementViewCount(post.id);
        context.push('/community/post/${post.id}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 + 특수 라벨
            Row(
              children: [
                _categoryLabel(post.category),
                if (post.isHot) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      'HOT',
                      style: AppTypography.labelTiny.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // 제목 + 댓글 수
            Row(
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (post.commentCount > 0)
                  Text(
                    ' [${post.commentCount}]',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // 메타
            Text(
              '${post.isAnonymous ? "익명" : post.authorName}'
              ' · ${_timeAgo(post.createdAt)}'
              ' · 조회 ${post.viewCount}'
              ' · ♥ ${post.likeCount}',
              style: AppTypography.labelTiny,
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryLabel(PostCategory category) {
    Color bg;
    Color text;
    switch (category) {
      case PostCategory.free:
        bg = AppColors.surfaceSecondary;
        text = AppColors.textSecondary;
        break;
      case PostCategory.question:
        bg = AppColors.pinkLight;
        text = AppColors.pinkDark;
        break;
      case PostCategory.certify:
        bg = AppColors.accentLight;
        text = AppColors.accentDark;
        break;
      case PostCategory.save:
        bg = AppColors.successLight;
        text = AppColors.success;
        break;
      case PostCategory.sidejob:
        bg = AppColors.purpleLight;
        text = AppColors.purpleDark;
        break;
      case PostCategory.finance:
        bg = AppColors.infoLight;
        text = AppColors.infoDark;
        break;
      case PostCategory.horror:
        bg = AppColors.dangerLight;
        text = AppColors.dangerDark;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        category.displayName,
        style: AppTypography.labelTiny.copyWith(
          color: text,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined,
              size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            _selectedCategory == null
                ? '아직 글이 없어요. 첫 글을 써볼래요?'
                : '${_selectedCategory!.displayName}에 글이 없어요',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('검색'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '제목 또는 내용 검색',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

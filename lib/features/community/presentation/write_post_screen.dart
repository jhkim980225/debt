import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/providers.dart';
import '../domain/post_model.dart';
import '../data/community_providers.dart';

/// 글쓰기 화면
class WritePostScreen extends ConsumerStatefulWidget {
  const WritePostScreen({super.key});

  @override
  ConsumerState<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends ConsumerState<WritePostScreen> {
  PostCategory? _selectedCategory;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isAnonymous = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedCategory != null &&
      _titleController.text.trim().length >= 5 &&
      _contentController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCloseDialog(),
        ),
        title: const Text('글쓰기'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: TextButton(
              onPressed: _canSubmit ? _submit : null,
              child: Text(
                '올리기',
                style: AppTypography.buttonMedium.copyWith(
                  color: _canSubmit
                      ? AppColors.info
                      : AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // 카테고리 선택
              Text('카테고리', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: PostCategory.values.map((cat) {
                  return AppChip(
                    label: cat.displayName,
                    isSelected: _selectedCategory == cat,
                    onTap: () =>
                        setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              ),

              // 카테고리별 가이드
              if (_selectedCategory != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _categoryGuide(_selectedCategory!),
                  style: AppTypography.labelTiny,
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // 익명 토글
              Row(
                children: [
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (v) =>
                        setState(() => _isAnonymous = v ?? false),
                    activeColor: AppColors.info,
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isAnonymous = !_isAnonymous),
                    child: Text('익명으로 작성',
                        style: AppTypography.bodyMedium),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // 제목
              TextField(
                controller: _titleController,
                maxLength: 100,
                decoration: const InputDecoration(
                  hintText: '제목 (5자 이상)',
                  counterText: '',
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 본문
              TextField(
                controller: _contentController,
                maxLines: 12,
                maxLength: 5000,
                decoration: const InputDecoration(
                  hintText: '내용을 입력해주세요',
                  alignLabelWithHint: true,
                  counterText: '',
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 글자수 표시
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_contentController.text.length} / 5000',
                  style: AppTypography.labelTiny,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryGuide(PostCategory category) {
    switch (category) {
      case PostCategory.certify:
        return '어떤 진전이 있었나요? (사진 첨부 권장)';
      case PostCategory.question:
        return '구체적으로 적어주시면 좋은 답이 와요';
      case PostCategory.save:
        return '실제로 효과 본 노하우를 공유해주세요';
      case PostCategory.finance:
        return '출처와 함께 공유하면 더 신뢰받아요';
      case PostCategory.sidejob:
        return '실제 경험을 바탕으로 작성해주세요';
      case PostCategory.horror:
        return '공감과 응원이 오가는 공간이에요';
      default:
        return '자유롭게 이야기해주세요';
    }
  }

  void _submit() {
    final user = ref.read(currentUserProvider);

    final post = PostModel(
      id: const Uuid().v4(),
      userId: user?.id ?? 'local_user',
      authorName: user?.displayName ?? '사용자',
      category: _selectedCategory!,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      isAnonymous: _isAnonymous,
      createdAt: DateTime.now(),
    );

    // 로컬 상태에 추가
    ref.read(communityPostsProvider.notifier).addPost(post);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('글이 올라갔어요'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  void _showCloseDialog() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      context.pop();
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('작성 취소'),
        content: const Text('작성 중인 내용이 사라져요. 정말 닫으시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('계속 쓰기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

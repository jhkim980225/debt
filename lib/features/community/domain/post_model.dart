/// 게시글 카테고리
enum PostCategory {
  free('자유'),
  question('질문'),
  certify('인증'),
  save('절약'),
  sidejob('부업'),
  finance('금융정보'),
  horror('공포의빚');

  final String displayName;
  const PostCategory(this.displayName);
}

/// 게시글 모델
class PostModel {
  final String id;
  final String userId;
  final String authorName;
  final PostCategory category;
  final String title;
  final String content;
  final bool isAnonymous;
  final List<String> imageUrls;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final DateTime createdAt;
  final bool isHot;
  final bool isEditorPick;

  PostModel({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.category,
    required this.title,
    required this.content,
    this.isAnonymous = false,
    this.imageUrls = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    required this.createdAt,
    this.isHot = false,
    this.isEditorPick = false,
  });

  PostModel copyWith({
    int? likeCount,
    int? commentCount,
    int? viewCount,
    bool? isHot,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      authorName: authorName,
      category: category,
      title: title,
      content: content,
      isAnonymous: isAnonymous,
      imageUrls: imageUrls,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt,
      isHot: isHot ?? this.isHot,
      isEditorPick: isEditorPick,
    );
  }
}

/// 댓글 모델
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String authorName;
  final String content;
  final bool isAnonymous;
  final int likeCount;
  final String? parentId; // 대댓글이면 부모 댓글 ID
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorName,
    required this.content,
    this.isAnonymous = false,
    this.likeCount = 0,
    this.parentId,
    required this.createdAt,
  });

  CommentModel copyWith({int? likeCount}) {
    return CommentModel(
      id: id,
      postId: postId,
      userId: userId,
      authorName: authorName,
      content: content,
      isAnonymous: isAnonymous,
      likeCount: likeCount ?? this.likeCount,
      parentId: parentId,
      createdAt: createdAt,
    );
  }
}

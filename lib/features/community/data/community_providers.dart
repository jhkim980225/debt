import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/post_model.dart';

/// 게시글 목록 상태 관리
final communityPostsProvider =
    StateNotifierProvider<CommunityPostsNotifier, List<PostModel>>((ref) {
  return CommunityPostsNotifier();
});

class CommunityPostsNotifier extends StateNotifier<List<PostModel>> {
  CommunityPostsNotifier() : super([]);

  /// 게시글 추가
  void addPost(PostModel post) {
    state = [post, ...state];
  }

  /// 게시글 좋아요 토글 (카운트 증감)
  void toggleLike(String postId, {required bool liked}) {
    state = state.map((p) {
      if (p.id == postId) {
        return p.copyWith(
          likeCount: liked ? p.likeCount + 1 : p.likeCount - 1,
        );
      }
      return p;
    }).toList();
  }

  /// 댓글 수 증가
  void incrementCommentCount(String postId) {
    state = state.map((p) {
      if (p.id == postId) {
        return p.copyWith(commentCount: p.commentCount + 1);
      }
      return p;
    }).toList();
  }

  /// 조회수 증가
  void incrementViewCount(String postId) {
    state = state.map((p) {
      if (p.id == postId) {
        return p.copyWith(viewCount: p.viewCount + 1);
      }
      return p;
    }).toList();
  }

  /// 시드 데이터 로드 (테스트/개발용)
  void seedPosts(List<PostModel> posts) {
    state = posts;
  }
}

/// 댓글 목록 상태 관리 (postId별)
final communityCommentsProvider =
    StateNotifierProvider<CommunityCommentsNotifier, List<CommentModel>>((ref) {
  return CommunityCommentsNotifier();
});

class CommunityCommentsNotifier extends StateNotifier<List<CommentModel>> {
  CommunityCommentsNotifier() : super([]);

  /// 댓글 추가
  void addComment(CommentModel comment) {
    state = [...state, comment];
  }

  /// 특정 게시글 댓글
  List<CommentModel> commentsForPost(String postId) {
    return state.where((c) => c.postId == postId).toList();
  }

  /// 댓글 좋아요 토글
  void toggleCommentLike(String commentId, {required bool liked}) {
    state = state.map((c) {
      if (c.id == commentId) {
        return c.copyWith(
          likeCount: liked ? c.likeCount + 1 : c.likeCount - 1,
        );
      }
      return c;
    }).toList();
  }

  /// 시드 데이터 (테스트/개발용)
  void seedComments(List<CommentModel> comments) {
    state = comments;
  }
}

/// 좋아요 상태 (유저가 좋아요 누른 항목 ID 집합)
final likedPostsProvider = StateProvider<Set<String>>((ref) => {});
final likedCommentsProvider = StateProvider<Set<String>>((ref) => {});

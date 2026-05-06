import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/badge_model.dart';

/// Supabase 기반 배지 저장소
class BadgeRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// 사용자 배지 목록
  Future<List<BadgeModel>> getUserBadges(String userId) async {
    final data = await _client
        .from('badges')
        .select()
        .eq('user_id', userId)
        .order('earned_at', ascending: false);

    return data.map((b) => BadgeModel(
      id: b['id'],
      userId: b['user_id'],
      earnedAt: DateTime.parse(b['earned_at']),
    )).toList();
  }

  /// 배지 획득
  Future<BadgeModel> earnBadge({
    required String badgeId,
    required String userId,
  }) async {
    // 이미 가지고 있으면 기존 배지 반환
    final existing = await _client
        .from('badges')
        .select()
        .eq('user_id', userId)
        .eq('id', badgeId)
        .maybeSingle();

    if (existing != null) {
      return BadgeModel(
        id: existing['id'],
        userId: existing['user_id'],
        earnedAt: DateTime.parse(existing['earned_at']),
      );
    }

    final now = DateTime.now();
    await _client.from('badges').insert({
      'id': badgeId,
      'user_id': userId,
      'earned_at': now.toIso8601String(),
    });

    return BadgeModel(
      id: badgeId,
      userId: userId,
      earnedAt: now,
    );
  }

  /// 특정 배지 보유 여부
  Future<bool> hasBadge(String userId, String badgeId) async {
    final data = await _client
        .from('badges')
        .select('id')
        .eq('user_id', userId)
        .eq('id', badgeId)
        .maybeSingle();

    return data != null;
  }
}

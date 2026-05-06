import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/user_model.dart';

/// Supabase 기반 인증 저장소
class AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// 이메일 회원가입
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    if (response.user == null) {
      throw Exception('회원가입에 실패했어요. 다시 시도해주세요');
    }

    // 트리거가 profiles 자동 생성, 닉네임 업데이트
    await _client
        .from('profiles')
        .update({'display_name': displayName})
        .eq('id', response.user!.id);

    return _userFromSession(response.user!, displayName: displayName);
  }

  /// 이메일 로그인
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('이메일 또는 비밀번호를 확인해주세요');
    }

    // 마지막 로그인 시간 갱신
    await _client
        .from('profiles')
        .update({'last_login_at': DateTime.now().toIso8601String()})
        .eq('id', response.user!.id);

    return await _loadProfile(response.user!.id);
  }

  /// 현재 로그인된 사용자
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      return await _loadProfile(user.id);
    } catch (_) {
      return null;
    }
  }

  /// 자동 로그인 확인
  Future<bool> isLoggedIn() async {
    return _client.auth.currentSession != null;
  }

  /// 로그아웃
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// 사용자 정보 업데이트
  Future<void> updateUser(UserModel user) async {
    await _client.from('profiles').update({
      'display_name': user.displayName,
      'streak_count': user.streakCount,
      'longest_streak': user.longestStreak,
      'strategy': user.strategy,
      'monthly_budget': user.monthlyBudget,
      'total_days_active': user.totalDaysActive,
    }).eq('id', user.id);
  }

  /// 프로필 로드
  Future<UserModel> _loadProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserModel(
      id: data['id'],
      email: data['email'],
      displayName: data['display_name'],
      profileImageUrl: data['profile_image_url'],
      authProvider: data['auth_provider'],
      createdAt: DateTime.parse(data['created_at']),
      lastLoginAt: DateTime.parse(data['last_login_at']),
      totalDaysActive: data['total_days_active'] ?? 1,
      streakCount: data['streak_count'] ?? 0,
      longestStreak: data['longest_streak'] ?? 0,
      strategy: data['strategy'] ?? 'snowball',
      monthlyBudget: data['monthly_budget'],
    );
  }

  /// Auth User → UserModel 변환 (가입 직후용)
  UserModel _userFromSession(User user, {String? displayName}) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: displayName ?? '새로운여행자',
      authProvider: 'email',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }
}

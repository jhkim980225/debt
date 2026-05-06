import 'package:hive/hive.dart';

part 'badge_model.g.dart';

@HiveType(typeId: 3)
class BadgeModel extends HiveObject {
  @HiveField(0)
  final String id; // 배지 식별자

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime earnedAt;

  BadgeModel({
    required this.id,
    required this.userId,
    required this.earnedAt,
  });
}

/// 배지 마스터 데이터
class BadgeDefinition {
  final String id;
  final String name;
  final String description;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
  });

  static const List<BadgeDefinition> all = [
    BadgeDefinition(id: 'firstStep', name: '첫 걸음', description: '첫 상환 기록'),
    BadgeDefinition(id: 'sevenDayStreak', name: '7일 연속', description: '7일 연속 상환'),
    BadgeDefinition(id: 'thirtyDayStreak', name: '30일 연속', description: '30일 연속 상환'),
    BadgeDefinition(id: 'hundredDayStreak', name: '100일 연속', description: '100일 연속 상환'),
    BadgeDefinition(id: 'tenPercentClear', name: '10% 클리어', description: '전체 빚의 10% 상환'),
    BadgeDefinition(id: 'quarterClear', name: '25% 클리어', description: '25% 상환'),
    BadgeDefinition(id: 'halfClear', name: '50% 클리어', description: '50% 상환'),
    BadgeDefinition(id: 'million', name: '100만원', description: '누적 100만원 상환'),
    BadgeDefinition(id: 'fiveMillion', name: '500만원', description: '누적 500만원 상환'),
    BadgeDefinition(id: 'tenMillion', name: '1000만원', description: '누적 1000만원 상환'),
    BadgeDefinition(id: 'interestSaver', name: '이자 절약가', description: '최소 결제 대비 이자 10만원 절약'),
    BadgeDefinition(id: 'firstGraduation', name: '첫 졸업', description: '첫 빚 완납'),
    BadgeDefinition(id: 'allCleared', name: '자유', description: '모든 빚 완납'),
    BadgeDefinition(id: 'comeback', name: '컴백', description: '7일 이상 끊긴 후 다시 시작'),
    BadgeDefinition(id: 'extraEffort', name: '한 걸음 더', description: '목표보다 많이 갚기 5회'),
    BadgeDefinition(id: 'disciplined', name: '꾸준함', description: '30일간 매일 정확히 목표 금액'),
    BadgeDefinition(id: 'earlyBird', name: '일찍 일어나는 새', description: '결제일 3일 전 미리 갚기 5회'),
    BadgeDefinition(id: 'weekendWarrior', name: '주말 전사', description: '주말에 상환 5회'),
  ];
}

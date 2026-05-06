import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  String displayName;

  @HiveField(3)
  String? profileImageUrl;

  @HiveField(4)
  final String authProvider; // email, kakao, google, apple, naver

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime lastLoginAt;

  @HiveField(7)
  int totalDaysActive;

  @HiveField(8)
  int streakCount;

  @HiveField(9)
  int longestStreak;

  @HiveField(10)
  String strategy; // snowball, avalanche

  @HiveField(11)
  int? monthlyBudget;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    required this.authProvider,
    required this.createdAt,
    required this.lastLoginAt,
    this.totalDaysActive = 1,
    this.streakCount = 0,
    this.longestStreak = 0,
    this.strategy = 'snowball',
    this.monthlyBudget,
  });
}

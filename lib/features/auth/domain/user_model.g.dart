// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      email: fields[1] as String,
      displayName: fields[2] as String,
      profileImageUrl: fields[3] as String?,
      authProvider: fields[4] as String,
      createdAt: fields[5] as DateTime,
      lastLoginAt: fields[6] as DateTime,
      totalDaysActive: fields[7] as int,
      streakCount: fields[8] as int,
      longestStreak: fields[9] as int,
      strategy: fields[10] as String,
      monthlyBudget: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.profileImageUrl)
      ..writeByte(4)
      ..write(obj.authProvider)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.lastLoginAt)
      ..writeByte(7)
      ..write(obj.totalDaysActive)
      ..writeByte(8)
      ..write(obj.streakCount)
      ..writeByte(9)
      ..write(obj.longestStreak)
      ..writeByte(10)
      ..write(obj.strategy)
      ..writeByte(11)
      ..write(obj.monthlyBudget);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

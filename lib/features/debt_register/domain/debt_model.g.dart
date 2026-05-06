// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtModelAdapter extends TypeAdapter<DebtModel> {
  @override
  final int typeId = 1;

  @override
  DebtModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DebtModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      category: fields[3] as String,
      initialAmount: fields[4] as int?,
      currentBalance: fields[5] as int,
      interestRate: fields[6] as double,
      minimumPayment: fields[7] as int?,
      targetPayment: fields[8] as int?,
      paymentDay: fields[9] as int?,
      notificationTiming: fields[10] as String,
      isPaidOff: fields[11] as bool,
      createdAt: fields[12] as DateTime,
      paidOffAt: fields[13] as DateTime?,
      priority: fields[14] as int,
      loanTermMonths: fields[15] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DebtModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.initialAmount)
      ..writeByte(5)
      ..write(obj.currentBalance)
      ..writeByte(6)
      ..write(obj.interestRate)
      ..writeByte(7)
      ..write(obj.minimumPayment)
      ..writeByte(8)
      ..write(obj.targetPayment)
      ..writeByte(9)
      ..write(obj.paymentDay)
      ..writeByte(10)
      ..write(obj.notificationTiming)
      ..writeByte(11)
      ..write(obj.isPaidOff)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.paidOffAt)
      ..writeByte(14)
      ..write(obj.priority)
      ..writeByte(15)
      ..write(obj.loanTermMonths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

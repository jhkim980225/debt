// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentModelAdapter extends TypeAdapter<PaymentModel> {
  @override
  final int typeId = 2;

  @override
  PaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      debtId: fields[2] as String,
      amount: fields[3] as int,
      principalAmount: fields[10] as int?,
      interestAmount: fields[11] as int?,
      paidAt: fields[4] as DateTime,
      note: fields[5] as String?,
      isExtra: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      balanceBefore: fields[8] as int,
      balanceAfter: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.debtId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.paidAt)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.isExtra)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.balanceBefore)
      ..writeByte(9)
      ..write(obj.balanceAfter)
      ..writeByte(10)
      ..write(obj.principalAmount)
      ..writeByte(11)
      ..write(obj.interestAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

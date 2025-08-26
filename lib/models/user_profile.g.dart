// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      xp: fields[0] as int,
      coins: fields[1] as int,
      level: fields[2] as int,
      streak: fields[3] as int,
      avatarId: fields[4] as String,
      unlockedThemes: (fields[5] as List).cast<String>(),
      unlockedQuotes: (fields[6] as List).cast<String>(),
      lastCompletionDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.xp)
      ..writeByte(1)
      ..write(obj.coins)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.streak)
      ..writeByte(4)
      ..write(obj.avatarId)
      ..writeByte(5)
      ..write(obj.unlockedThemes)
      ..writeByte(6)
      ..write(obj.unlockedQuotes)
      ..writeByte(7)
      ..write(obj.lastCompletionDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

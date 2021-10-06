// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthenticationModelAdapter extends TypeAdapter<AuthenticationModel> {
  @override
  final int typeId = 1;

  @override
  AuthenticationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthenticationModel(
      accessToken: fields[0] as String?,
      pid: fields[2] as String?,
      ucsdaffiliation: fields[3] as String?,
      expiration: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthenticationModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(2)
      ..write(obj.pid)
      ..writeByte(3)
      ..write(obj.ucsdaffiliation)
      ..writeByte(4)
      ..write(obj.expiration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthenticationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

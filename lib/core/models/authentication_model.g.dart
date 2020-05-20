// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthenticationModelAdapter extends TypeAdapter<AuthenticationModel> {
  @override
  final typeId = 1;

  @override
  AuthenticationModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthenticationModel(
      accessToken: fields[0] as String,
      refreshToken: fields[1] as String,
      pid: fields[2] as String,
      ucsdaffiliation: fields[3] as String,
      expiration: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AuthenticationModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.pid)
      ..writeByte(3)
      ..write(obj.ucsdaffiliation)
      ..writeByte(4)
      ..write(obj.expiration);
  }
}

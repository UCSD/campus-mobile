// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final typeId = 2;

  @override
  UserProfileModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      selectedLots: (fields[0] as List)?.cast<String>(),
      selectedOccuspaceLocations: (fields[1] as List)?.cast<String>(),
      subscribedTopics: (fields[2] as List)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.selectedLots)
      ..writeByte(1)
      ..write(obj.selectedOccuspaceLocations)
      ..writeByte(2)
      ..write(obj.subscribedTopics);
  }
}

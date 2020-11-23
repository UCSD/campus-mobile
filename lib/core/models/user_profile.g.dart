// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 2;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      selectedLots: (fields[0] as List)?.cast<String>(),
      selectedOccuspaceLocations: (fields[1] as List)?.cast<String>(),
      subscribedTopics: (fields[2] as List)?.cast<String>(),
      selectedParkingSpots: (fields[3] as Map)?.cast<String, bool>(),
      selectedParkingLots: (fields[4] as Map)?.cast<String, bool>(),
      selectedStops: (fields[5] as List)?.cast<int>(),
      surveyCompletion: (fields[6] as List)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.selectedLots)
      ..writeByte(1)
      ..write(obj.selectedOccuspaceLocations)
      ..writeByte(2)
      ..write(obj.subscribedTopics)
      ..writeByte(3)
      ..write(obj.selectedParkingSpots)
      ..writeByte(4)
      ..write(obj.selectedParkingLots)
      ..writeByte(5)
      ..write(obj.selectedStops)
      ..writeByte(6)
      ..write(obj.surveyCompletion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

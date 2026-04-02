// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_persistent.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessagePersistentAdapter extends TypeAdapter<ChatMessagePersistent> {
  @override
  final int typeId = 3;

  @override
  ChatMessagePersistent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessagePersistent(
      id: fields[0] as String,
      text: fields[1] as String,
      authorId: fields[2] as String,
      createdAt: fields[3] as int,
      isFromUser: fields[4] as bool,
      sessionId: fields[5] as String?,
      parentMessageId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessagePersistent obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.authorId)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isFromUser)
      ..writeByte(5)
      ..write(obj.sessionId)
      ..writeByte(6)
      ..write(obj.parentMessageId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessagePersistentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

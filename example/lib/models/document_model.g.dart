// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedDocumentAdapter extends TypeAdapter<SavedDocument> {
  @override
  final int typeId = 0;

  @override
  SavedDocument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedDocument(
      id: fields[0] as String,
      title: fields[1] as String,
      html: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      wordCount: fields[5] as int? ?? 0,
      charCount: fields[6] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, SavedDocument obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.html)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.wordCount)
      ..writeByte(6)
      ..write(obj.charCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedDocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}


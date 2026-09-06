import 'package:hive/hive.dart';

part 'document_model.g.dart';

@HiveType(typeId: 3)
class DocumentModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String folderId;

  @HiveField(2)
  late String profileId;

  @HiveField(3)
  late String name;

  @HiveField(4)
  late String mimeType;

  /// Path to the encrypted file on disk
  @HiveField(5)
  late String encryptedPath;

  @HiveField(6)
  late int fileSizeBytes;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  DateTime? updatedAt;

  @HiveField(9)
  String? description;

  @HiveField(10)
  String? thumbnailPath;

  DocumentModel({
    required this.id,
    required this.folderId,
    required this.profileId,
    required this.name,
    required this.mimeType,
    required this.encryptedPath,
    required this.fileSizeBytes,
    required this.createdAt,
    this.updatedAt,
    this.description,
    this.thumbnailPath,
  });

  DocumentModel copyWith({
    String? name,
    String? description,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      id: id,
      folderId: folderId,
      profileId: profileId,
      name: name ?? this.name,
      mimeType: mimeType,
      encryptedPath: encryptedPath,
      fileSizeBytes: fileSizeBytes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      thumbnailPath: thumbnailPath,
    );
  }

  bool get isImage => mimeType.startsWith('image/');
  bool get isPdf => mimeType == 'application/pdf';
  bool get isVideo => mimeType.startsWith('video/');

  String get fileExtension {
    if (isImage) return mimeType.split('/').last;
    if (isPdf) return 'pdf';
    if (isVideo) return mimeType.split('/').last;
    return 'file';
  }
}

import 'package:hive/hive.dart';

part 'folder_model.g.dart';

@HiveType(typeId: 2)
class FolderModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String profileId;

  @HiveField(2)
  late String name;

  @HiveField(3)
  late String icon;

  @HiveField(4)
  late int colorValue;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  String? description;

  FolderModel({
    required this.id,
    required this.profileId,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.createdAt,
    this.description,
  });

  FolderModel copyWith({
    String? name,
    String? icon,
    int? colorValue,
    String? description,
  }) {
    return FolderModel(
      id: id,
      profileId: profileId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      description: description ?? this.description,
    );
  }
}

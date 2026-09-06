import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 1)
class ProfileModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String userId;

  @HiveField(2)
  late String name;

  @HiveField(3)
  late String emoji;

  @HiveField(4)
  late int colorValue;

  @HiveField(5)
  late String relationship;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  String? dateOfBirth;

  @HiveField(8)
  String? notes;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.emoji,
    required this.colorValue,
    required this.relationship,
    required this.createdAt,
    this.dateOfBirth,
    this.notes,
  });

  ProfileModel copyWith({
    String? name,
    String? emoji,
    int? colorValue,
    String? relationship,
    String? dateOfBirth,
    String? notes,
  }) {
    return ProfileModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      relationship: relationship ?? this.relationship,
      createdAt: createdAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      notes: notes ?? this.notes,
    );
  }
}

import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String name;

  @HiveField(3)
  late String passwordHash;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime lastLoginAt;

  @HiveField(6)
  bool biometricEnabled;

  @HiveField(7)
  bool appLockEnabled;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
    required this.createdAt,
    required this.lastLoginAt,
    this.biometricEnabled = false,
    this.appLockEnabled = false,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? passwordHash,
    DateTime? lastLoginAt,
    bool? biometricEnabled,
    bool? appLockEnabled,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    );
  }
}

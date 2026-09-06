import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';
import '../models/folder_model.dart';
import '../models/document_model.dart';
import '../../core/constants/app_constants.dart';

/// Hive-backed local database service
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  late Box<UserModel> _userBox;
  late Box<ProfileModel> _profileBox;
  late Box<FolderModel> _folderBox;
  late Box<DocumentModel> _documentBox;
  late Box<dynamic> _settingsBox;

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDir.path);

    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ProfileModelAdapter());
    Hive.registerAdapter(FolderModelAdapter());
    Hive.registerAdapter(DocumentModelAdapter());

    _userBox = await Hive.openBox<UserModel>(AppConstants.userBox);
    _profileBox = await Hive.openBox<ProfileModel>(AppConstants.profileBox);
    _folderBox = await Hive.openBox<FolderModel>(AppConstants.folderBox);
    _documentBox = await Hive.openBox<DocumentModel>(AppConstants.documentBox);
    _settingsBox = await Hive.openBox<dynamic>(AppConstants.settingsBox);
  }

  // ─── Users ──────────────────────────────────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    await _userBox.put(user.id, user);
  }

  UserModel? getUserById(String id) => _userBox.get(id);

  UserModel? getUserByEmail(String email) {
    try {
      return _userBox.values.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  List<UserModel> getAllUsers() => _userBox.values.toList();

  Future<void> deleteUser(String id) async {
    await _userBox.delete(id);
  }

  // ─── Profiles ───────────────────────────────────────────────────────────────

  Future<void> saveProfile(ProfileModel profile) async {
    await _profileBox.put(profile.id, profile);
  }

  ProfileModel? getProfile(String id) => _profileBox.get(id);

  List<ProfileModel> getProfilesForUser(String userId) {
    return _profileBox.values
        .where((p) => p.userId == userId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> deleteProfile(String id) async {
    await _profileBox.delete(id);
  }

  // ─── Folders ────────────────────────────────────────────────────────────────

  Future<void> saveFolder(FolderModel folder) async {
    await _folderBox.put(folder.id, folder);
  }

  FolderModel? getFolder(String id) => _folderBox.get(id);

  List<FolderModel> getFoldersForProfile(String profileId) {
    return _folderBox.values
        .where((f) => f.profileId == profileId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> deleteFolder(String id) async {
    await _folderBox.delete(id);
  }

  // ─── Documents ──────────────────────────────────────────────────────────────

  Future<void> saveDocument(DocumentModel doc) async {
    await _documentBox.put(doc.id, doc);
  }

  DocumentModel? getDocument(String id) => _documentBox.get(id);

  List<DocumentModel> getDocumentsForFolder(String folderId) {
    return _documentBox.values
        .where((d) => d.folderId == folderId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<DocumentModel> getDocumentsForProfile(String profileId) {
    return _documentBox.values
        .where((d) => d.profileId == profileId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteDocument(String id) async {
    await _documentBox.delete(id);
  }

  int getDocumentCountForFolder(String folderId) {
    return _documentBox.values.where((d) => d.folderId == folderId).length;
  }

  int getTotalFileSizeForProfile(String profileId) {
    return _documentBox.values
        .where((d) => d.profileId == profileId)
        .fold(0, (sum, d) => sum + d.fileSizeBytes);
  }

  // ─── Settings ───────────────────────────────────────────────────────────────

  T? getSetting<T>(String key) => _settingsBox.get(key) as T?;

  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  // ─── Misc ────────────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _userBox.clear();
    await _profileBox.clear();
    await _folderBox.clear();
    await _documentBox.clear();
    await _settingsBox.clear();
  }
}

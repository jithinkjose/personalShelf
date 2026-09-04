import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../data/models/document_model.dart';
import '../data/models/folder_model.dart';
import '../data/models/profile_model.dart';
import '../data/services/file_service.dart';
import '../data/services/storage_service.dart';

class VaultProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  final FileService _fileService = FileService.instance;
  final _uuid = const Uuid();

  List<ProfileModel> _profiles = [];
  ProfileModel? _selectedProfile;
  List<FolderModel> _folders = [];
  FolderModel? _selectedFolder;
  List<DocumentModel> _documents = [];

  List<ProfileModel> get profiles => _profiles;
  ProfileModel? get selectedProfile => _selectedProfile;
  List<FolderModel> get folders => _folders;
  FolderModel? get selectedFolder => _selectedFolder;
  List<DocumentModel> get documents => _documents;

  // ─── Profiles ───────────────────────────────────────────────────────────────

  void loadProfiles(String userId) {
    _profiles = _storage.getProfilesForUser(userId);
    notifyListeners();
  }

  Future<ProfileModel> createProfile({
    required String userId,
    required String name,
    required String emoji,
    required int colorValue,
    required String relationship,
    String? dateOfBirth,
  }) async {
    final profile = ProfileModel(
      id: _uuid.v4(),
      userId: userId,
      name: name,
      emoji: emoji,
      colorValue: colorValue,
      relationship: relationship,
      createdAt: DateTime.now(),
      dateOfBirth: dateOfBirth,
    );
    await _storage.saveProfile(profile);
    _profiles = _storage.getProfilesForUser(userId);
    notifyListeners();

    // Create default folders
    for (int i = 0; i < AppConstants.defaultFolders.length; i++) {
      await createFolder(
        profileId: profile.id,
        name: AppConstants.defaultFolders[i],
        icon: _defaultFolderIcon(AppConstants.defaultFolders[i]),
        colorValue: AppColors.profileColors[i % AppColors.profileColors.length].value,
      );
    }
    return profile;
  }

  Future<void> updateProfile(ProfileModel updated) async {
    await _storage.saveProfile(updated);
    _profiles = _storage.getProfilesForUser(updated.userId);
    if (_selectedProfile?.id == updated.id) _selectedProfile = updated;
    notifyListeners();
  }

  Future<void> deleteProfile(ProfileModel profile, String userId) async {
    // Delete all documents in all folders
    final allDocs = _storage.getDocumentsForProfile(profile.id);
    for (final doc in allDocs) {
      await _fileService.deleteDocument(doc);
    }
    // Delete all folders
    final allFolders = _storage.getFoldersForProfile(profile.id);
    for (final f in allFolders) {
      await _storage.deleteFolder(f.id);
    }
    await _storage.deleteProfile(profile.id);
    _profiles = _storage.getProfilesForUser(userId);
    if (_selectedProfile?.id == profile.id) _selectedProfile = null;
    notifyListeners();
  }

  void selectProfile(ProfileModel profile) {
    _selectedProfile = profile;
    loadFolders(profile.id);
  }

  // ─── Folders ────────────────────────────────────────────────────────────────

  void loadFolders(String profileId) {
    _folders = _storage.getFoldersForProfile(profileId);
    notifyListeners();
  }

  Future<FolderModel> createFolder({
    required String profileId,
    required String name,
    required String icon,
    required int colorValue,
    String? description,
  }) async {
    final folder = FolderModel(
      id: _uuid.v4(),
      profileId: profileId,
      name: name,
      icon: icon,
      colorValue: colorValue,
      createdAt: DateTime.now(),
      description: description,
    );
    await _storage.saveFolder(folder);
    _folders = _storage.getFoldersForProfile(profileId);
    notifyListeners();
    return folder;
  }

  Future<void> updateFolder(FolderModel updated) async {
    await _storage.saveFolder(updated);
    _folders = _storage.getFoldersForProfile(updated.profileId);
    if (_selectedFolder?.id == updated.id) _selectedFolder = updated;
    notifyListeners();
  }

  Future<void> deleteFolder(FolderModel folder) async {
    final docs = _storage.getDocumentsForFolder(folder.id);
    for (final doc in docs) {
      await _fileService.deleteDocument(doc);
    }
    await _storage.deleteFolder(folder.id);
    _folders = _storage.getFoldersForProfile(folder.profileId);
    if (_selectedFolder?.id == folder.id) _selectedFolder = null;
    notifyListeners();
  }

  void selectFolder(FolderModel folder) {
    _selectedFolder = folder;
    loadDocuments(folder.id);
  }

  int docCountForFolder(String folderId) =>
      _storage.getDocumentCountForFolder(folderId);

  // ─── Documents ──────────────────────────────────────────────────────────────

  void loadDocuments(String folderId) {
    _documents = _storage.getDocumentsForFolder(folderId);
    notifyListeners();
  }

  Future<void> addDocuments(List<DocumentModel> docs) async {
    if (docs.isEmpty) return;
    _documents = _storage.getDocumentsForFolder(docs.first.folderId);
    notifyListeners();
  }

  Future<void> deleteDocument(DocumentModel doc) async {
    await _fileService.deleteDocument(doc);
    _documents = _storage.getDocumentsForFolder(doc.folderId);
    notifyListeners();
  }

  Future<void> renameDocument(DocumentModel doc, String newName) async {
    final updated = doc.copyWith(name: newName, updatedAt: DateTime.now());
    await _storage.saveDocument(updated);
    _documents = _storage.getDocumentsForFolder(doc.folderId);
    notifyListeners();
  }

  int totalSizeForProfile(String profileId) =>
      _storage.getTotalFileSizeForProfile(profileId);

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _defaultFolderIcon(String name) {
    switch (name.toLowerCase()) {
      case 'identity': return '🪪';
      case 'medical': return '🏥';
      case 'education': return '🎓';
      case 'financial': return '💰';
      case 'insurance': return '🛡️';
      case 'legal': return '⚖️';
      case 'travel': return '✈️';
      default: return '📁';
    }
  }
}

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/document_model.dart';
import 'encryption_service.dart';
import 'storage_service.dart';

class FileService {
  static FileService? _instance;
  static FileService get instance => _instance ??= FileService._();
  FileService._();

  final _uuid = const Uuid();
  final _encryption = EncryptionService.instance;
  final _storage = StorageService.instance;

  Future<String> _getVaultDir(String profileId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/vault/$profileId');
    await dir.create(recursive: true);
    return dir.path;
  }

  /// Pick file(s) from device and encrypt them into the vault.
  Future<List<DocumentModel>> pickAndStoreFiles({
    required String profileId,
    required String folderId,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp', 'mp4'],
    );
    if (result == null || result.files.isEmpty) return [];

    final docs = <DocumentModel>[];
    for (final file in result.files) {
      if (file.path == null) continue;
      final doc = await _storeFile(
        sourceFile: File(file.path!),
        profileId: profileId,
        folderId: folderId,
        originalName: file.name,
      );
      if (doc != null) docs.add(doc);
    }
    return docs;
  }

  /// Pick image from camera or gallery and encrypt into vault.
  Future<DocumentModel?> pickImageAndStore({
    required String profileId,
    required String folderId,
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return null;
    return _storeFile(
      sourceFile: File(picked.path),
      profileId: profileId,
      folderId: folderId,
      originalName: p.basename(picked.path),
    );
  }

  Future<DocumentModel?> _storeFile({
    required File sourceFile,
    required String profileId,
    required String folderId,
    required String originalName,
  }) async {
    final bytes = await sourceFile.readAsBytes();
    final mimeType = lookupMimeType(sourceFile.path) ?? 'application/octet-stream';
    final encName = EncryptionService.generateEncryptedFileName();
    final vaultDir = await _getVaultDir(profileId);
    final encPath = '$vaultDir/$encName.enc';

    await _encryption.encryptFile(bytes, encPath);

    final doc = DocumentModel(
      id: _uuid.v4(),
      folderId: folderId,
      profileId: profileId,
      name: originalName,
      mimeType: mimeType,
      encryptedPath: encPath,
      fileSizeBytes: bytes.length,
      createdAt: DateTime.now(),
    );

    await _storage.saveDocument(doc);
    return doc;
  }

  /// Decrypt a document to a temp path for viewing.
  Future<String?> decryptForViewing(DocumentModel doc) async {
    try {
      final ext = doc.isPdf ? 'pdf' : doc.mimeType.split('/').last;
      return await _encryption.decryptToTemp(doc.encryptedPath, '${doc.id}.$ext');
    } catch (e) {
      return null;
    }
  }

  /// Decrypt and share a document via the OS share sheet.
  Future<void> shareDocument(DocumentModel doc) async {
    final tmpPath = await decryptForViewing(doc);
    if (tmpPath == null) return;
    final xFile = XFile(tmpPath, mimeType: doc.mimeType, name: doc.name);
    await Share.shareXFiles([xFile], text: doc.name);
  }

  /// Delete a stored document: removes the encrypted file and DB entry.
  Future<void> deleteDocument(DocumentModel doc) async {
    final file = File(doc.encryptedPath);
    if (await file.exists()) await file.delete();
    await _storage.deleteDocument(doc.id);
  }

  /// Clean up temp files older than 10 minutes.
  Future<void> cleanTempFiles() async {
    final tmp = Directory.systemTemp;
    final cutoff = DateTime.now().subtract(const Duration(minutes: 10));
    await for (final entity in tmp.list()) {
      if (entity is File) {
        final name = entity.path.split('/').last;
        if (name.startsWith('fv_tmp_')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
          }
        }
      }
    }
  }
}

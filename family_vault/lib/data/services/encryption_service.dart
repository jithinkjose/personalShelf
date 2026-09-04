import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

/// AES-256-CBC encryption for all stored files.
/// The key is generated once per install and stored in the secure keychain.
class EncryptionService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static EncryptionService? _instance;
  static EncryptionService get instance => _instance ??= EncryptionService._();
  EncryptionService._();

  enc.Key? _key;

  Future<void> init() async {
    _key = await _loadOrCreateKey();
  }

  Future<enc.Key> _loadOrCreateKey() async {
    final stored = await _secureStorage.read(key: AppConstants.encryptionKeyKey);
    if (stored != null) {
      return enc.Key.fromBase64(stored);
    }
    final newKey = enc.Key.fromSecureRandom(32); // 256-bit
    await _secureStorage.write(
      key: AppConstants.encryptionKeyKey,
      value: newKey.base64,
    );
    return newKey;
  }

  /// Encrypt raw [bytes] and write to [destinationPath].
  /// Returns the path to the encrypted file.
  Future<String> encryptFile(Uint8List bytes, String destinationPath) async {
    assert(_key != null, 'EncryptionService not initialised');
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(_key!, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);

    // File format: [16 bytes IV][encrypted data]
    final output = BytesBuilder();
    output.add(iv.bytes);
    output.add(encrypted.bytes);

    final file = File(destinationPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(output.toBytes());
    return destinationPath;
  }

  /// Decrypt file at [sourcePath] and return the raw bytes.
  Future<Uint8List> decryptFile(String sourcePath) async {
    assert(_key != null, 'EncryptionService not initialised');
    final bytes = await File(sourcePath).readAsBytes();
    if (bytes.length < 16) throw Exception('Encrypted file is corrupted');

    final iv = enc.IV(bytes.sublist(0, 16));
    final cipherBytes = bytes.sublist(16);
    final encrypter = enc.Encrypter(enc.AES(_key!, mode: enc.AESMode.cbc));
    final decrypted = encrypter.decryptBytes(enc.Encrypted(cipherBytes), iv: iv);
    return Uint8List.fromList(decrypted);
  }

  /// Write decrypted bytes to a temp file and return its path for viewing.
  Future<String> decryptToTemp(String sourcePath, String fileName) async {
    final bytes = await decryptFile(sourcePath);
    final tmpDir = Directory.systemTemp;
    final tmpFile = File('${tmpDir.path}/fv_tmp_$fileName');
    await tmpFile.writeAsBytes(bytes);
    return tmpFile.path;
  }

  Future<void> deleteKey() async {
    await _secureStorage.delete(key: AppConstants.encryptionKeyKey);
    _key = null;
  }

  /// Generate a random file name for the encrypted blob
  static String generateEncryptedFileName() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

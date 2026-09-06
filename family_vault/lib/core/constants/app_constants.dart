class AppConstants {
  static const appName = 'Family Vault';
  static const appVersion = '1.0.0';

  // Hive box names
  static const userBox = 'users';
  static const profileBox = 'profiles';
  static const folderBox = 'folders';
  static const documentBox = 'documents';
  static const settingsBox = 'settings';

  // Secure storage keys
  static const encryptionKeyKey = 'vault_encryption_key';
  static const currentUserKey = 'current_user_id';
  static const sessionTokenKey = 'session_token';

  // Settings keys
  static const biometricEnabledKey = 'biometric_enabled';
  static const appLockEnabledKey = 'app_lock_enabled';
  static const gridViewKey = 'grid_view';

  // File limits
  static const maxFileSizeMB = 50;
  static const maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;

  // Supported MIME types
  static const supportedImageTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/heic'];
  static const supportedDocTypes = ['application/pdf'];
  static const supportedVideoTypes = ['video/mp4', 'video/quicktime'];

  // Folder default names
  static const defaultFolders = [
    'Identity',
    'Medical',
    'Education',
    'Financial',
    'Insurance',
    'Legal',
    'Travel',
    'Other',
  ];

  // Profile emojis
  static const profileEmojis = [
    '👤', '👨', '👩', '🧒', '👦', '👧',
    '🧑', '👴', '👵', '🧔', '👶', '🧑‍💼',
    '🧑‍🎓', '🧑‍⚕️', '👮', '🧑‍🍳', '🧑‍🔬', '🎅',
  ];
}
